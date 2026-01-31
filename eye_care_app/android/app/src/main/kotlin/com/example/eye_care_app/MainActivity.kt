package com.example.eye_care_app



import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import java.util.*


class MainActivity : FlutterActivity() {
    private val CHANNEL = "usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openUsageSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

private fun getUsageStats(): List<Map<String, Any>> {
    val usageStatsManager =
        getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    val endTime = System.currentTimeMillis()
    val startTime = endTime - (7 * 24 * 60 * 60 * 1000L)

    val stats = usageStatsManager.queryUsageStats(
        UsageStatsManager.INTERVAL_DAILY,
        startTime,
        endTime
    )

    val usageMap = HashMap<String, Long>()

    for (usage in stats) {
        val total = usage.totalTimeInForeground
        if (total > 0) {
            usageMap[usage.packageName] =
                usageMap.getOrDefault(usage.packageName, 0L) + total
        }
    }

    return usageMap.entries
        .sortedByDescending { it.value }
        .take(5)
        .map {
            mapOf(
                "package" to it.key,
                "minutes" to (it.value / 1000 / 60)
            )
        }
}
