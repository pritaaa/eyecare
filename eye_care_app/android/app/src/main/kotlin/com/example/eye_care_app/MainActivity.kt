package com.example.eye_care_app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
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

                "getTodayScreenTime" -> {
                    if (!hasUsagePermission()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        result.success(getTodayScreenTime())
                    }
                }

                "getWeeklyScreenTime" -> {
                    if (!hasUsagePermission()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        result.success(getWeeklyScreenTime())
                    }
                }

                "debugUsageStats" -> {
                    if (!hasUsagePermission()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        result.success(debugUsageStats())
                    }
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
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)

        val resultList = if (targetPackages != null && targetPackages.isNotEmpty()) {
            targetPackages.map { pkg ->
                val usage = stats[pkg]
                val total = usage?.totalTimeInForeground ?: 0L
                AbstractMap.SimpleEntry(pkg, total)
            }
        } else {
            val usageMap = HashMap<String, Long>()
            val excludedPackages = getExcludedPackages()

            for ((pkg, usage) in stats) {
                val total = usage.totalTimeInForeground
                if (total > 0 &&
                    usage.lastTimeUsed >= startTime &&
                    isTrackableApp(pkg, excludedPackages)
                ) {
                    usageMap[pkg] = total
                }
            }
            usageMap.entries.sortedByDescending { it.value }.take(5).toList()
        }

        val packageManager = applicationContext.packageManager

        return resultList.map {
            val appName = try {
                packageManager.getApplicationLabel(
                    packageManager.getApplicationInfo(it.key, 0)
                ).toString()
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

    /**
     * Mendapatkan total screen time hari ini dari total semua app usage
     */
    private fun getTodayScreenTime(): Map<String, Any> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        
        val start = calendar.timeInMillis
        val end = System.currentTimeMillis()
        
        val totalMs = calculateTotalUsage(start, end)

        return mapOf(
            "totalMs" to totalMs,
            "hours" to (totalMs / 1000 / 60 / 60),
            "minutes" to ((totalMs / 1000 / 60) % 60)
        )
    }

    private fun calculateTotalUsage(startTime: Long, endTime: Long): Long {
        if (!hasUsagePermission()) return 0L
        
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)
        val excludedPackages = getExcludedPackages()
        
        var totalMs = 0L
        for ((pkg, usage) in stats) {
            val duration = usage.totalTimeInForeground
            if (duration > 0 && isTrackableApp(pkg, excludedPackages)) {
                totalMs += duration
            }
        }
        return totalMs
    }

    private fun getExcludedPackages(): Set<String> {
        val excluded = HashSet<String>()
        
        excluded.add(packageName)
        
        val homeIntent = Intent(Intent.ACTION_MAIN)
        homeIntent.addCategory(Intent.CATEGORY_HOME)
        val launchers = packageManager.queryIntentActivities(
            homeIntent, 
            PackageManager.MATCH_DEFAULT_ONLY
        )
        for (launcher in launchers) {
            excluded.add(launcher.activityInfo.packageName)
        }
        
        excluded.add("com.android.systemui")
        excluded.add("com.android.launcher")
        excluded.add("com.android.launcher2")
        excluded.add("com.android.launcher3")
        
        excluded.add("com.google.android.gms")
        excluded.add("com.google.android.gsf")
        
        excluded.add("com.android.inputmethod.latin")
        excluded.add("com.google.android.inputmethod.latin")
        excluded.add("com.samsung.android.honeyboard")
        
        excluded.add("android")
        excluded.add("com.android.settings")
        excluded.add("com.android.packageinstaller")
        excluded.add("com.android.providers.downloads")
        excluded.add("com.android.phone")
        excluded.add("com.android.contacts")
        
        return excluded
    }

    private fun isTrackableApp(pkg: String, excludedPackages: Set<String>): Boolean {
        if (excludedPackages.contains(pkg)) return false
        
        try {
            val appInfo = packageManager.getApplicationInfo(pkg, 0)
            
            if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                val launchIntent = packageManager.getLaunchIntentForPackage(pkg)
                if (launchIntent == null) {
                    return false
                }
            }
            
            val launchIntent = packageManager.getLaunchIntentForPackage(pkg)
            if (launchIntent == null) return false
            
            return true
            
        } catch (e: PackageManager.NameNotFoundException) {
            return false
        }
    }

    private fun getWeeklyScreenTime(): List<Map<String, Any>> {
        val weeklyData = ArrayList<Map<String, Any>>()
        val sdfDay = SimpleDateFormat("E", Locale.getDefault())

        for (i in 6 downTo 0) {
            val cal = Calendar.getInstance()
            cal.add(Calendar.DAY_OF_YEAR, -i)
            
            cal.set(Calendar.HOUR_OF_DAY, 0)
            cal.set(Calendar.MINUTE, 0)
            cal.set(Calendar.SECOND, 0)
            cal.set(Calendar.MILLISECOND, 0)
            val start = cal.timeInMillis
            
            val end = if (i == 0) {
                System.currentTimeMillis()
            } else {
                cal.set(Calendar.HOUR_OF_DAY, 23)
                cal.set(Calendar.MINUTE, 59)
                cal.set(Calendar.SECOND, 59)
                cal.set(Calendar.MILLISECOND, 999)
                cal.timeInMillis
            }

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

    private fun debugUsageStats(): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        
        val stats = usageStatsManager.queryAndAggregateUsageStats(
            calendar.timeInMillis,
            System.currentTimeMillis()
        )
        
        val excludedPackages = getExcludedPackages()
        
        return stats.entries
            .filter { it.value.totalTimeInForeground > 0 }
            .sortedByDescending { it.value.totalTimeInForeground }
            .map { (pkg, usage) ->
                val appName = try {
                    packageManager.getApplicationLabel(
                        packageManager.getApplicationInfo(pkg, 0)
                    ).toString()
                } catch (e: Exception) {
                    pkg
                }
                
                mapOf(
                    "package" to pkg,
                    "appName" to appName,
                    "minutes" to (usage.totalTimeInForeground / 1000 / 60),
                    "isTracked" to isTrackableApp(pkg, excludedPackages),
                    "isExcluded" to excludedPackages.contains(pkg)
                )
            }
    }
}