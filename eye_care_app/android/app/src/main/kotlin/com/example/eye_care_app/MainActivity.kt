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
                    // KONSEP BARU: Hitung total dari UsageStatsManager (Jumlah semua aplikasi)
                    val calendar = Calendar.getInstance()
                    calendar.set(Calendar.HOUR_OF_DAY, 0)
                    calendar.set(Calendar.MINUTE, 0)
                    calendar.set(Calendar.SECOND, 0)
                    calendar.set(Calendar.MILLISECOND, 0)
                    
                    val start = calendar.timeInMillis
                    val end = System.currentTimeMillis()
                    
                    // Hitung total durasi aplikasi hari ini
                    val totalMs = calculateTotalUsage(start, end)
                    
                    // Ambil count dari prefs (opsional, jika masih ingin menampilkan jumlah buka layar)
                    val count = pref.getInt("screen_on_count", 0)

                    val data = mapOf(
                        "screenOnMs" to totalMs,
                        "screenOnCount" to count
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

    // HELPER BARU: Menghitung total durasi semua aplikasi dalam rentang waktu tertentu
    private fun calculateTotalUsage(startTime: Long, endTime: Long): Long {
        if (!hasUsagePermission()) return 0L
        
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)
        
        var totalMs = 0L
        for ((pkg, usage) in stats) {
            val duration = usage.totalTimeInForeground
            // Filter standar untuk menghindari aplikasi sistem background (sesuai logika getUsageStats)
            if (duration > 0 && 
                !pkg.startsWith("com.android") && 
                pkg != packageName) {
                totalMs += duration
            }
        }
        return totalMs
    }

    private fun getWeeklyScreenTime(): List<Map<String, Any>> {
        val weeklyData = ArrayList<Map<String, Any>>()
        val sdfDay = SimpleDateFormat("E", Locale.getDefault())

        for (i in 6 downTo 0) {
            val cal = Calendar.getInstance()
            cal.add(Calendar.DAY_OF_YEAR, -i)
            
            // Set Start of Day (00:00:00)
            cal.set(Calendar.HOUR_OF_DAY, 0)
            cal.set(Calendar.MINUTE, 0)
            cal.set(Calendar.SECOND, 0)
            cal.set(Calendar.MILLISECOND, 0)
            val start = cal.timeInMillis
            
            // Set End of Day (23:59:59) atau Sekarang jika hari ini
            val end = if (i == 0) {
                System.currentTimeMillis()
            } else {
                cal.set(Calendar.HOUR_OF_DAY, 23)
                cal.set(Calendar.MINUTE, 59)
                cal.set(Calendar.SECOND, 59)
                cal.set(Calendar.MILLISECOND, 999)
                cal.timeInMillis
            }

            // Hitung total usage untuk hari tersebut
            val totalMs = calculateTotalUsage(start, end)

            weeklyData.add(
                mapOf(
                    "label" to sdfDay.format(cal.time).substring(0, 1),
                    "usageMs" to totalMs
                )
            )
        }
        return weeklyData
    }
}
