package de.garten.running_progress

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Moves the progress bar of the "Erfassung läuft" notification forward.
 *
 * The app (flutter_local_notifications) posts that notification with its
 * buttons. This plugin only updates it in place every few minutes, rebuilt
 * from the shown notification, so the buttons stay as they are. It runs
 * without Flutter: an alarm wakes [ProgressTickReceiver], which updates the
 * notification and sets the next alarm until the planned end is reached.
 *
 * On Android 16 the notification becomes a Live Update (promoted ongoing
 * notification with ProgressStyle); before that it gets a plain progress bar.
 */
class RunningProgressPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "de.garten.running_progress")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> RunningProgress.start(
                    context,
                    notificationId = call.argument<Int>("notificationId")!!,
                    startMs = call.argument<Number>("startMs")!!.toLong(),
                    endMs = call.argument<Number>("endMs")!!.toLong(),
                    color = call.argument<Number>("color")!!.toInt(),
                )
                "stop" -> RunningProgress.stop(context)
                else -> return result.notImplemented()
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("RUNNING_PROGRESS", e.message, null)
        }
    }
}

object RunningProgress {
    private const val PREFS = "running_progress"
    private const val STEPS = 1000
    private const val INTERVAL_MS = 5 * 60_000L
    private const val EXTRA_REQUEST_PROMOTED_ONGOING = "android.requestPromotedOngoing"

    fun start(context: Context, notificationId: Int, startMs: Long, endMs: Long, color: Int) {
        prefs(context).edit()
            .putInt("id", notificationId)
            .putLong("start", startMs)
            .putLong("end", endMs)
            .putInt("color", color)
            .apply()
        update(context)
    }

    fun stop(context: Context) {
        prefs(context).edit().clear().apply()
        alarms(context).cancel(tickIntent(context))
    }

    /** Updates the shown notification and sets the next alarm. */
    fun update(context: Context) {
        val prefs = prefs(context)
        if (!prefs.contains("id")) return
        val id = prefs.getInt("id", 0)
        val startMs = prefs.getLong("start", 0)
        val endMs = prefs.getLong("end", 0)
        val color = prefs.getInt("color", 0)

        val manager = context.getSystemService(NotificationManager::class.java)
        val shown = manager.activeNotifications.firstOrNull { it.id == id && it.tag == null }
        if (shown == null) {
            // Recording was stopped (or the notification removed): nothing to update.
            stop(context)
            return
        }

        val now = System.currentTimeMillis()
        val total = (endMs - startMs).coerceAtLeast(1)
        val progress = ((now - startMs) * STEPS / total).coerceIn(0, STEPS.toLong()).toInt()

        val builder = Notification.Builder.recoverBuilder(context, shown.notification)
        if (Build.VERSION.SDK_INT >= 36) {
            builder.setStyle(
                Notification.ProgressStyle()
                    .setProgressSegments(
                        listOf(Notification.ProgressStyle.Segment(STEPS).setColor(color)),
                    )
                    .setProgress(progress),
            )
            // Same as setRequestPromotedOngoing(true), which the API 36 SDK
            // doesn't have yet (it only sets this extra).
            builder.extras.putBoolean(EXTRA_REQUEST_PROMOTED_ONGOING, true)
        } else {
            builder.setProgress(STEPS, progress, false)
        }
        builder.setColor(color)
        manager.notify(shown.tag, shown.id, builder.build())

        // Once the planned end is reached the bar is full; no more updates needed.
        if (now < endMs) {
            schedule(context, minOf(now + INTERVAL_MS, endMs))
        } else {
            alarms(context).cancel(tickIntent(context))
        }
    }

    private fun schedule(context: Context, atMs: Long) {
        val alarms = alarms(context)
        val intent = tickIntent(context)
        if (Build.VERSION.SDK_INT < 31 || alarms.canScheduleExactAlarms()) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, intent)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, intent)
        }
    }

    private fun tickIntent(context: Context) = PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, ProgressTickReceiver::class.java),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    private fun alarms(context: Context) = context.getSystemService(AlarmManager::class.java)

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}

/** Woken by the alarm: moves the progress bar forward. */
class ProgressTickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // An exception escaping an alarm receiver would crash the process.
        try {
            RunningProgress.update(context)
        } catch (e: Exception) {
            android.util.Log.w("RunningProgress", "Progress tick failed", e)
        }
    }
}
