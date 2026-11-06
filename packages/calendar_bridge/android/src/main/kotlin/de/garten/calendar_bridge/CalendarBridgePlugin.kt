package de.garten.calendar_bridge

import android.accounts.Account
import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.CalendarContract
import android.provider.CalendarContract.Calendars
import android.provider.CalendarContract.Colors
import android.provider.CalendarContract.Events
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Reads and writes the phone's calendars (Android Calendar Provider).
 * Google sync then uploads the events to Google Calendar.
 * The calendar permission is requested on the Dart side.
 */
class CalendarBridgePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    // Calendar queries can be slow, so they run off the main thread.
    private val worker = Executors.newSingleThreadExecutor()
    private val mainThread = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "de.garten.calendar_bridge")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        worker.execute {
            try {
                val value: Any? = when (call.method) {
                    "writableCalendars" -> writableCalendars()
                    "eventColors" -> eventColors(call.argument<String>("calendarId")!!)
                    "insertEvent" -> insertEvent(call.argument<String>("calendarId")!!, call.argument("event")!!)
                    // These return nothing; Flutter can't send Kotlin's Unit, so send null.
                    "updateEvent" -> { updateEvent(call.argument<String>("eventId")!!, call.argument("event")!!); null }
                    "deleteEvent" -> { deleteEvent(call.argument<String>("eventId")!!); null }
                    "eventExists" -> eventExists(call.argument<String>("eventId")!!)
                    "enableSync" -> { enableSync(call.argument<String>("calendarId")!!); null }
                    "requestSync" -> { requestSync(call.argument<String>("calendarId")); null }
                    else -> {
                        mainThread.post { result.notImplemented() }
                        return@execute
                    }
                }
                mainThread.post { result.success(value) }
            } catch (e: SecurityException) {
                mainThread.post { result.error("NO_PERMISSION", "Calendar permission missing", null) }
            } catch (e: Exception) {
                mainThread.post { result.error("CALENDAR_ERROR", e.message, null) }
            }
        }
    }

    private val resolver: ContentResolver get() = context.contentResolver

    /**
     * Calendars the app may add events to, sorted by account. Includes
     * calendars that aren't synced to this phone yet (`synced` = false):
     * Google adds new calendars switched off until they're turned on.
     */
    private fun writableCalendars(): List<Map<String, Any?>> {
        val calendars = mutableListOf<Map<String, Any?>>()
        resolver.query(
            Calendars.CONTENT_URI,
            arrayOf(
                Calendars._ID, Calendars.CALENDAR_DISPLAY_NAME, Calendars.ACCOUNT_NAME,
                Calendars.ACCOUNT_TYPE, Calendars.CALENDAR_COLOR, Calendars.SYNC_EVENTS,
            ),
            "${Calendars.CALENDAR_ACCESS_LEVEL} >= ?",
            arrayOf(Calendars.CAL_ACCESS_CONTRIBUTOR.toString()),
            "${Calendars.ACCOUNT_NAME}, ${Calendars.CALENDAR_DISPLAY_NAME}",
        )?.use { c ->
            while (c.moveToNext()) {
                calendars += mapOf(
                    "id" to c.getLong(0).toString(),
                    "name" to c.getString(1),
                    "accountName" to c.getString(2),
                    "accountType" to c.getString(3),
                    "color" to c.getInt(4),
                    "synced" to (c.getInt(5) == 1),
                )
            }
        }
        return calendars
    }

    /** Event colors the calendar's account offers (Google: the 11 Google Calendar colors). */
    private fun eventColors(calendarId: String): List<Map<String, Any?>> {
        val account = account(calendarId) ?: return emptyList()
        val colors = mutableListOf<Map<String, Any?>>()
        resolver.query(
            Colors.CONTENT_URI,
            arrayOf(Colors.COLOR_KEY, Colors.COLOR),
            "${Colors.ACCOUNT_NAME} = ? AND ${Colors.ACCOUNT_TYPE} = ? AND ${Colors.COLOR_TYPE} = ?",
            arrayOf(account.first, account.second, Colors.TYPE_EVENT.toString()),
            null,
        )?.use { c ->
            while (c.moveToNext()) {
                colors += mapOf("key" to c.getString(0), "color" to c.getInt(1))
            }
        }
        return colors
    }

    /** Turns on syncing (and showing) a calendar, as its sync switch in Google Calendar does. */
    private fun enableSync(calendarId: String) {
        val values = ContentValues().apply {
            put(Calendars.SYNC_EVENTS, 1)
            put(Calendars.VISIBLE, 1)
        }
        resolver.update(
            ContentUris.withAppendedId(Calendars.CONTENT_URI, calendarId.toLong()),
            values, null, null,
        )
    }

    /**
     * Asks Android to sync the calendar's account now (e.g. upload changes to
     * Google). Without a calendar: every account that has calendars, so new
     * calendars show up.
     */
    private fun requestSync(calendarId: String?) {
        val accounts = if (calendarId != null) {
            listOfNotNull(account(calendarId))
        } else {
            val all = mutableSetOf<Pair<String, String>>()
            resolver.query(
                Calendars.CONTENT_URI,
                arrayOf(Calendars.ACCOUNT_NAME, Calendars.ACCOUNT_TYPE),
                null, null, null,
            )?.use { c -> while (c.moveToNext()) all += c.getString(0) to c.getString(1) }
            all.toList()
        }
        val extras = Bundle().apply {
            putBoolean(ContentResolver.SYNC_EXTRAS_MANUAL, true)
            putBoolean(ContentResolver.SYNC_EXTRAS_EXPEDITED, true)
        }
        for ((name, type) in accounts) {
            if (type == CalendarContract.ACCOUNT_TYPE_LOCAL) continue // nothing to sync with
            ContentResolver.requestSync(Account(name, type), CalendarContract.AUTHORITY, extras)
        }
    }

    private fun account(calendarId: String): Pair<String, String>? {
        resolver.query(
            ContentUris.withAppendedId(Calendars.CONTENT_URI, calendarId.toLong()),
            arrayOf(Calendars.ACCOUNT_NAME, Calendars.ACCOUNT_TYPE),
            null, null, null,
        )?.use { c ->
            if (c.moveToFirst()) return c.getString(0) to c.getString(1)
        }
        return null
    }

    private fun insertEvent(calendarId: String, event: Map<String, Any?>): String {
        val values = eventValues(event).apply { put(Events.CALENDAR_ID, calendarId.toLong()) }
        val uri = resolver.insert(Events.CONTENT_URI, values)
            ?: throw IllegalStateException("Event could not be created")
        return ContentUris.parseId(uri).toString()
    }

    private fun updateEvent(eventId: String, event: Map<String, Any?>) {
        resolver.update(eventUri(eventId), eventValues(event), null, null)
    }

    private fun deleteEvent(eventId: String) {
        resolver.delete(eventUri(eventId), null, null)
    }

    /** False if the event is gone or was deleted (e.g. in Google Calendar). */
    private fun eventExists(eventId: String): Boolean {
        resolver.query(eventUri(eventId), arrayOf(Events.DELETED), null, null, null)?.use { c ->
            return c.moveToFirst() && c.getInt(0) == 0
        }
        return false
    }

    private fun eventUri(eventId: String) = ContentUris.withAppendedId(Events.CONTENT_URI, eventId.toLong())

    private fun eventValues(event: Map<String, Any?>) = ContentValues().apply {
        put(Events.TITLE, event["title"] as String)
        put(Events.DESCRIPTION, event["description"] as String?)
        put(Events.EVENT_LOCATION, event["location"] as String?)
        put(Events.DTSTART, (event["startMs"] as Number).toLong())
        put(Events.DTEND, (event["endMs"] as Number).toLong())
        put(Events.EVENT_TIMEZONE, event["timeZone"] as String)
        put(Events.HAS_ALARM, 0) // no calendar reminders, the app reminds by itself
        put(Events.AVAILABILITY, Events.AVAILABILITY_BUSY)
        val colorKey = event["colorKey"] as String?
        if (colorKey != null) {
            put(Events.EVENT_COLOR_KEY, colorKey)
        } else {
            // Back to the calendar's own color
            putNull(Events.EVENT_COLOR_KEY)
            putNull(Events.EVENT_COLOR)
        }
    }
}
