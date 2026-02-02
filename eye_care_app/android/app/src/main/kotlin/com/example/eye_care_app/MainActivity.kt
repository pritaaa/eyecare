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
import java.util.AbstractMap
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
                    val targetPackages = call.argument<List<String>>("targetPackages")
                    if (!hasUsagePermission()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        result.success(getUsageStats(targetPackages))
                    }
                }

                "getInstalledApps" -> {
                    result.success(getInstalledApps())
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
                    // FIX: Cek reset tanggal sebelum ambil data (untuk kasus midnight saat layar nyala)
                    ScreenUsageManager.checkDateReset(applicationContext)

                    var totalMs = pref.getLong("screen_on_ms", 0)
                    val isScreenOn = pref.getBoolean("is_screen_on", true)
                    var lastOn = pref.getLong("last_on_time", 0)

                    // FIX: Jika baru install (lastOn 0) tapi layar nyala, set waktu mulai sekarang
                    if (isScreenOn && lastOn == 0L) {
                        lastOn = System.currentTimeMillis()
                        pref.edit().putLong("last_on_time", lastOn).apply()
                    }

                    if (isScreenOn) {
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

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        val apps = pm.queryIntentActivities(intent, 0)

        return apps.map { resolveInfo ->
            val activityInfo = resolveInfo.activityInfo
            val packageName = activityInfo.packageName
            val label = resolveInfo.loadLabel(pm).toString()
            val icon = getAppIcon(packageName)
            mapOf("appName" to label, "packageName" to packageName, "appIcon" to icon)
        }.distinctBy { it["packageName"] as String }.sortedBy { it["appName"] as String }
    }

    private fun getUsageStats(targetPackages: List<String>?): List<Map<String, Any?>> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usageStatsManager.queryAndAggregateUsageStats(
            startTime,
            endTime
        )

        val resultList = if (targetPackages != null && targetPackages.isNotEmpty()) {
            // Jika user memilih aplikasi spesifik
            targetPackages.map { pkg ->
                val usage = stats[pkg]
                val total = usage?.totalTimeInForeground ?: 0L
                AbstractMap.SimpleEntry(pkg, total)
            }
        } else {
            // Default: Top 5 aplikasi hari ini
            val usageMap = HashMap<String, Long>()
            for ((pkg, usage) in stats) {
                val total = usage.totalTimeInForeground
                if (total > 0 &&
                    usage.lastTimeUsed >= startTime &&
                    !pkg.startsWith("com.android") &&
                    pkg != packageName
                ) {
                    usageMap[pkg] = total
                }
            }
            usageMap.entries.sortedByDescending { it.value }.take(5).toList()
        }

        val packageManager = applicationContext.packageManager

        return resultList
            .map {
                val appName = try {
                    packageManager.getApplicationLabel(packageManager.getApplicationInfo(it.key, 0)).toString()
                } catch (e: Exception) {
                    it.key
                }

                val appIcon = getAppIcon(it.key)

                mapOf(
                    "package" to it.key,
                    "appName" to appName,
                    "minutes" to (it.value / 1000 / 60),
                    "appIcon" to appIcon
                )
            }
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val drawable = packageManager.getApplicationIcon(packageName)
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
    }

    private fun getWeeklyScreenTime(): List<Map<String, Any>> {
        ScreenUsageManager.checkDateReset(applicationContext)
        
        val pref = getSharedPreferences("screen_usage", Context.MODE_PRIVATE)
        val weeklyData = ArrayList<Map<String, Any>>()
        
        val sdfDate = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val sdfDay = SimpleDateFormat("E", Locale.getDefault())
        val calendar = Calendar.getInstance()

        // Ambil data live hari ini
        val currentMs = pref.getLong("screen_on_ms", 0)
        val isScreenOn = pref.getBoolean("is_screen_on", false)
        val lastOn = pref.getLong("last_on_time", 0)
        
        // Hitung tambahan waktu real-time jika layar sedang nyala
        val liveAddition = if (isScreenOn && lastOn > 0L) {
            System.currentTimeMillis() - lastOn
        } else {
            0L
        }

        for (i in 6 downTo 0) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_YEAR, -i)
            val dateString = sdfDate.format(calendar.time)
            
            var totalMs = 0L
            
            if (i == 0) {
                // Hari ini: Ambil dari screen_on_ms + live duration
                totalMs = currentMs + liveAddition
            } else {
                // Hari lalu: Ambil dari history yang disimpan ScreenUsageManager
                // Jika tidak ada data (sebelum install), otomatis 0
                totalMs = pref.getLong("history_$dateString", 0)
            }

            weeklyData.add(
                mapOf(
                    "label" to sdfDay.format(calendar.time).substring(0, 1),
                    "usageMs" to totalMs
                )
            )
        }
        return weeklyData
    }
}
