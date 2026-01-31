package com.example.eye_care_app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

class MainActivity : FlutterActivity() {

    private val USAGE_CHANNEL = "eye_care/usage_stats"
    private val SCREEN_CHANNEL = "eye_care/screen_usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            USAGE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "openUsageSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }

                "hasUsagePermission" -> {
                    result.success(hasUsagePermission())
                }

                "getUsageStats" -> {
                    if (!hasUsagePermission()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        result.success(getUsageStats())
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_CHANNEL
        ).setMethodCallHandler { call, result ->

            val pref = getSharedPreferences("screen_usage", Context.MODE_PRIVATE)

            when (call.method) {
                "getTodayReport" -> {
                    var totalMs = pref.getLong("screen_on_ms", 0)
                    val isScreenOn = pref.getBoolean("is_screen_on", true)

                    if (isScreenOn) {
                        val lastOn = pref.getLong("last_on_time", 0)
                        if (lastOn > 0) {
                            totalMs += (System.currentTimeMillis() - lastOn)
                        }
                    }

                    val data = mapOf(
                        "screenOnMs" to totalMs,
                        "screenOnCount" to pref.getInt("screen_on_count", 0)
                    )
                    result.success(data)
                }

                "getWeeklyScreenTime" -> {
                    result.success(getWeeklyScreenTime())
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getUsageStats(): List<Map<String, Any?>> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val usageMap = HashMap<String, Long>()

        for (usage in stats) {
            val total = usage.totalTimeInForeground
            val pkg = usage.packageName

            if (total > 0 &&
                !pkg.startsWith("com.android") &&
                pkg != packageName
            ) {
                usageMap[pkg] =
                    usageMap.getOrDefault(pkg, 0L) + total
            }
        }

        val packageManager = applicationContext.packageManager

        return usageMap.entries
            .sortedByDescending { it.value }
            .take(5)
            .map {
                val appName = try {
                    packageManager.getApplicationLabel(packageManager.getApplicationInfo(it.key, 0)).toString()
                } catch (e: Exception) {
                    it.key
                }

                val appIcon = try {
                    val drawable = packageManager.getApplicationIcon(it.key)
                    val bitmap = if (drawable is BitmapDrawable) {
                        drawable.bitmap
                    } else {
                        val bmp = Bitmap.createBitmap(
                            drawable.intrinsicWidth,
                            drawable.intrinsicHeight,
                            Bitmap.Config.ARGB_8888
                        )
                        val canvas = Canvas(bmp)
                        drawable.setBounds(0, 0, canvas.width, canvas.height)
                        drawable.draw(canvas)
                        bmp
                    }
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    stream.toByteArray()
                } catch (e: Exception) {
                    null
                }

                mapOf(
                    "package" to it.key,
                    "appName" to appName,
                    "minutes" to (it.value / 1000 / 60),
                    "appIcon" to appIcon
                )
            }
    }
    private fun getWeeklyScreenTime(): List<Map<String, Any>> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        val weeklyData = ArrayList<Map<String, Any>>()
        val dayFormat = SimpleDateFormat("E", Locale.getDefault())

        for (i in 6 downTo 0) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_YEAR, -i)

            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            val start = calendar.timeInMillis

            calendar.set(Calendar.HOUR_OF_DAY, 23)
            calendar.set(Calendar.MINUTE, 59)
            calendar.set(Calendar.SECOND, 59)
            val end = calendar.timeInMillis

            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                start,
                end
            )

            var totalDayMs = 0L
            for (usage in stats) {
                totalDayMs += usage.totalTimeInForeground
            }

            weeklyData.add(
                mapOf(
                    "label" to dayFormat.format(calendar.time).substring(0, 1),
                    "usageMs" to totalDayMs
                )
            )
        }
        return weeklyData
    }
}
