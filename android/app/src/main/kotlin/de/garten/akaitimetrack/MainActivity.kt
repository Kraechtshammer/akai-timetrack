package de.garten.akaitimetrack

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private var updaterChannel: MethodChannel? = null
    private var installReceiver: BroadcastReceiver? = null
    private val installExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "de.garten.akaitimetrack/app_icon")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "current" -> result.success(currentIcon())
                    "set" -> {
                        val icon = call.argument<String>("icon")
                        if (icon !in ICONS) {
                            result.error("UNKNOWN_ICON", "Unknown icon $icon", null)
                        } else {
                            setIcon(icon!!)
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        val updater = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UPDATER_CHANNEL)
        updaterChannel = updater
        updater.setMethodCallHandler { call, result ->
            when (call.method) {
                "installedVersion" -> result.success(installedVersion())
                "canInstall" -> result.success(packageManager.canRequestPackageInstalls())
                "openInstallPermission" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:$packageName"),
                        ),
                    )
                    result.success(null)
                }
                "install" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INSTALL_ERROR", "Missing path", null)
                    } else {
                        installApk(File(path), result)
                    }
                }
                else -> result.notImplemented()
            }
        }
        registerInstallReceiver()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        unregisterInstallReceiver()
        updaterChannel?.setMethodCallHandler(null)
        updaterChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    /** This app's versionName, so Dart can compare it with the latest release. */
    private fun installedVersion(): String {
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(packageName, 0)
        }
        return info.versionName ?: ""
    }

    /**
     * Installs [apk] through a PackageInstaller session. The copy runs off the main thread (the
     * APK is tens of MB); [result] is answered once the session is committed. The user confirms
     * in the system dialog, which [installReceiver] starts.
     */
    private fun installApk(apk: File, result: MethodChannel.Result) {
        installExecutor.execute {
            val installer = packageManager.packageInstaller
            var sessionId = -1
            try {
                // A restarted update must not collide with an old half-finished session.
                for (old in installer.mySessions) {
                    try {
                        installer.abandonSession(old.sessionId)
                    } catch (_: Exception) {
                    }
                }
                val size = apk.length()
                val params = PackageInstaller.SessionParams(
                    PackageInstaller.SessionParams.MODE_FULL_INSTALL,
                )
                params.setAppPackageName(packageName)
                params.setSize(size)
                sessionId = installer.createSession(params)
                installer.openSession(sessionId).use { session ->
                    session.openWrite("base.apk", 0, size).use { out ->
                        apk.inputStream().use { it.copyTo(out) }
                        session.fsync(out)
                    }
                    // Mutable: the system adds the status extras to this intent.
                    val pending = PendingIntent.getBroadcast(
                        this,
                        0,
                        Intent(INSTALL_STATUS_ACTION).setPackage(packageName),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
                    )
                    session.commit(pending.intentSender)
                }
                mainHandler.post { result.success(null) }
            } catch (e: Exception) {
                if (sessionId != -1) {
                    try {
                        installer.abandonSession(sessionId)
                    } catch (_: Exception) {
                    }
                }
                mainHandler.post { result.error("INSTALL_ERROR", e.message ?: e.toString(), null) }
            }
        }
    }

    /**
     * Receives the installer's status: opens the system confirmation when needed, passes every
     * other status on to Dart.
     */
    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    private fun registerInstallReceiver() {
        unregisterInstallReceiver()
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val status = intent.getIntExtra(
                    PackageInstaller.EXTRA_STATUS,
                    PackageInstaller.STATUS_FAILURE,
                )
                val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)
                if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
                    val confirm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra<Intent>(Intent.EXTRA_INTENT)
                    }
                    if (confirm != null) {
                        confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(confirm)
                    }
                } else {
                    updaterChannel?.invokeMethod(
                        "installResult",
                        mapOf("status" to status, "message" to message),
                    )
                }
            }
        }
        val filter = IntentFilter(INSTALL_STATUS_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
        installReceiver = receiver
    }

    private fun unregisterInstallReceiver() {
        val receiver = installReceiver ?: return
        installReceiver = null
        try {
            unregisterReceiver(receiver)
        } catch (_: IllegalArgumentException) {
        }
    }

    /** The enabled launcher alias (see AndroidManifest.xml), by icon name. */
    private fun currentIcon(): String = ICONS.entries.firstOrNull { (_, alias) ->
        when (packageManager.getComponentEnabledSetting(component(alias))) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            // Not changed yet: the manifest default, the round cloche.
            PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> alias == ICONS.getValue(DEFAULT_ICON)
            else -> false
        }
    }?.key ?: DEFAULT_ICON

    /** Enables the alias for [icon] first, then disables the others. */
    private fun setIcon(icon: String) {
        fun set(alias: String, state: Int) = packageManager.setComponentEnabledSetting(
            component(alias),
            state,
            PackageManager.DONT_KILL_APP,
        )
        set(ICONS.getValue(icon), PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
        for ((name, alias) in ICONS) {
            if (name != icon) set(alias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
        }
    }

    // Alias names in the manifest are relative to the namespace (this class's package), which
    // may differ from the applicationId.
    private fun component(alias: String) =
        ComponentName(this, "${MainActivity::class.java.`package`!!.name}$alias")

    companion object {
        private const val UPDATER_CHANNEL = "de.garten.akaitimetrack/updater"
        private const val INSTALL_STATUS_ACTION = "de.gartenpa.timetrack.INSTALL_STATUS"

        // Icon keys ("design.shape", lib/domain/app_icons.dart) to launcher aliases. The cloche
        // keeps the alias names the AKAI sign had until 1.4.0, so existing installs move to it.
        private const val DEFAULT_ICON = "cloche.round"
        private val ICONS = mapOf(
            "cloche.round" to ".IconRound",
            "cloche.squircle" to ".IconSquircle",
            "cloche.small" to ".IconSmall",
            "akai.round" to ".IconAkaiRound",
            "akai.squircle" to ".IconAkaiSquircle",
            "akai.small" to ".IconAkaiSmall",
            "penguinBlack.round" to ".IconPenguinBlackRound",
            "penguinBlack.squircle" to ".IconPenguinBlackSquircle",
            "penguinBlack.small" to ".IconPenguinBlackSmall",
            "penguinNavy.round" to ".IconPenguinNavyRound",
            "penguinNavy.squircle" to ".IconPenguinNavySquircle",
            "penguinNavy.small" to ".IconPenguinNavySmall",
        )
    }
}
