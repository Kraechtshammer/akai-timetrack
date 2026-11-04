package de.garten.akaitimetrack

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
    }

    /** The enabled launcher alias (see AndroidManifest.xml), by icon name. */
    private fun currentIcon(): String = ICONS.entries.firstOrNull { (_, alias) ->
        when (packageManager.getComponentEnabledSetting(component(alias))) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            // Not changed yet: the manifest default, "Rund".
            PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> alias == ICONS.getValue("round")
            else -> false
        }
    }?.key ?: "round"

    /** Enables the alias for [icon] and disables the others. */
    private fun setIcon(icon: String) {
        for ((name, alias) in ICONS) {
            packageManager.setComponentEnabledSetting(
                component(alias),
                if (name == icon) {
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                } else {
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                },
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    // Alias names in the manifest are relative to the namespace (this class's package), which
    // may differ from the applicationId.
    private fun component(alias: String) =
        ComponentName(this, "${MainActivity::class.java.`package`!!.name}$alias")

    companion object {
        private val ICONS = mapOf(
            "round" to ".IconRound",
            "squircle" to ".IconSquircle",
            "small" to ".IconSmall",
        )
    }
}
