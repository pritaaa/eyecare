package com.example.eye_care_app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
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
    private val TAG = "EyeCareApp"
    
    // Constants untuk tracking yang lebih akurat
    private val MIN_SESSION_MS = 1_000L
    private val SCREEN_OFF_TIMEOUT = 5_000L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            USAGE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "openUsageSettings" -> {
                    try {
                        // CRITICAL FIX: Android 15 butuh URI untuk langsung ke app
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
                            // Android 15+ (API 35)
                            Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                            }
                        } else {
                            // Android 14 dan dibawah
                            Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                        }
                        
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error opening usage settings", e)
                        // Fallback
                        try {
                            startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            })
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("ERROR", "Cannot open settings: ${e2.message}", null)
                        }
                    }
                }

                "hasUsagePermission" -> {
                    val hasPermission = hasUsagePermission()
                    Log.d(TAG, "Permission check: $hasPermission (Android ${Build.VERSION.SDK_INT})")
                    result.success(hasPermission)
                }

                "getUsageStats" -> {
                    val targetPackages = call.argument<List<String>>("targetPackages")
                    if (!hasUsagePermission()) {
                        Log.w(TAG, "Permission not granted")
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        try {
                            result.success(getUsageStats(targetPackages))
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting usage stats", e)
                            result.error("ERROR", e.message, null)
                        }
                    }
                }

                "getInstalledApps" -> {
                    try {
                        result.success(getInstalledApps())
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting installed apps", e)
                        result.error("ERROR", e.message, null)
                    }
                }

                "getTodayScreenTime" -> {
                    if (!hasUsagePermission()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access not granted",
                            null
                        )
                    } else {
                        try {
                            result.success(getTodayScreenTime())
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting today screen time", e)
                            result.error("ERROR", e.message, null)
                        }
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
                        try {
                            result.success(getWeeklyScreenTime())
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting weekly screen time", e)
                            result.error("ERROR", e.message, null)
                        }
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
                        try {
                            result.success(debugUsageStats())
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting debug stats", e)
                            result.error("ERROR", e.message, null)
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    /**
     * CRITICAL: Permission check yang robust untuk Android 15
     * Android 15 sangat ketat - harus double check dengan actual query
     */
    private fun hasUsagePermission(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
            if (appOps == null) {
                Log.e(TAG, "AppOpsManager is null")
                return false
            }

            // CRITICAL: Android 10+ harus pakai unsafeCheckOpNoThrow
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    packageName
                )
            }

            val modeAllowed = mode == AppOpsManager.MODE_ALLOWED
            Log.d(TAG, "AppOps mode: $mode, allowed: $modeAllowed")

            // CRITICAL: Double check dengan actual query untuk Android 15
            // Android 15 kadang return MODE_ALLOWED tapi query tetap gagal
            if (modeAllowed) {
                return try {
                    val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                    if (usageStatsManager == null) {
                        Log.e(TAG, "UsageStatsManager is null")
                        return false
                    }

                    // Test query 24 jam terakhir
                    val endTime = System.currentTimeMillis()
                    val startTime = endTime - (24 * 60 * 60 * 1000)
                    
                    val stats = usageStatsManager.queryUsageStats(
                        UsageStatsManager.INTERVAL_DAILY,
                        startTime,
                        endTime
                    )
                    
                    // Jika stats null atau empty, permission belum benar-benar granted
                    val hasData = stats != null && stats.isNotEmpty()
                    Log.d(TAG, "Query test - hasData: $hasData, size: ${stats?.size ?: 0}")
                    
                    hasData
                } catch (e: Exception) {
                    Log.e(TAG, "Error verifying permission", e)
                    false
                }
            }

            false
        } catch (e: Exception) {
            Log.e(TAG, "Error checking permission", e)
            false
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        
        // CRITICAL: Android 13+ butuh ResolveInfoFlags
        val apps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(intent, 0)
        }

        return apps.mapNotNull { resolveInfo ->
            try {
                val activityInfo = resolveInfo.activityInfo
                val packageName = activityInfo.packageName
                val label = resolveInfo.loadLabel(pm).toString()
                val icon = getAppIcon(packageName)
                mapOf("appName" to label, "packageName" to packageName, "appIcon" to icon)
            } catch (e: Exception) {
                Log.w(TAG, "Error getting app info: ${e.message}")
                null
            }
        }.distinctBy { it["packageName"] as String }
          .sortedBy { it["appName"] as String }
    }

    /**
     * Menggunakan event-based tracking untuk akurasi lebih baik
     */
    private fun getUsageStats(targetPackages: List<String>?): List<Map<String, Any?>> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        // Event-based tracking lebih akurat daripada aggregated stats
        val usageMap = getAppUsageByEvents(startTime, endTime)

        val resultList = if (targetPackages != null && targetPackages.isNotEmpty()) {
            targetPackages.map { pkg ->
                val total = usageMap[pkg] ?: 0L
                pkg to total
            }
        } else {
            usageMap.entries
                .sortedByDescending { it.value }
                .take(5)
                .map { it.key to it.value }
        }

        val packageManager = applicationContext.packageManager

        return resultList.mapNotNull { (pkg, duration) ->
            try {
                val appName = try {
                    val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        packageManager.getApplicationInfo(pkg, PackageManager.ApplicationInfoFlags.of(0))
                    } else {
                        @Suppress("DEPRECATION")
                        packageManager.getApplicationInfo(pkg, 0)
                    }
                    packageManager.getApplicationLabel(appInfo).toString()
                } catch (e: Exception) {
                    pkg
                }

                val appIcon = getAppIcon(pkg)

                mapOf(
                    "package" to pkg,
                    "appName" to appName,
                    "minutes" to (duration / 1000 / 60),
                    "appIcon" to appIcon
                )
            } catch (e: Exception) {
                Log.w(TAG, "Error processing package $pkg: ${e.message}")
                null
            }
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
            Log.w(TAG, "Error getting app icon for $packageName: ${e.message}")
            null
        }
    }

    private fun getTodayScreenTime(): Map<String, Any> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        
        val start = calendar.timeInMillis
        val end = System.currentTimeMillis()
        
        // Gunakan event-based calculation untuk akurasi lebih baik
        val totalMs = calculateScreenTimeByEvents(start, end)

        return mapOf(
            "totalMs" to totalMs,
            "hours" to (totalMs / 1000 / 60 / 60),
            "minutes" to ((totalMs / 1000 / 60) % 60)
        )
    }

    /**
     * Event-based calculation - lebih akurat dari aggregated stats
     * Menggunakan ACTIVITY_RESUMED, ACTIVITY_PAUSED, SCREEN events
     */
    private fun calculateScreenTimeByEvents(startTime: Long, endTime: Long): Long {
        if (!hasUsagePermission()) return 0L
        
        return try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val events = usageStatsManager.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()

            val excludedPackages = getExcludedPackages()

            var currentPackage: String? = null
            var sessionStartTime = 0L
            var totalTime = 0L
            var lastEventTime = 0L

            while (events.hasNextEvent()) {
                events.getNextEvent(event)

                // Deteksi screen off dari gap waktu
                if (lastEventTime > 0 && (event.timeStamp - lastEventTime) > SCREEN_OFF_TIMEOUT) {
                    if (currentPackage != null && sessionStartTime > 0) {
                        val duration = lastEventTime - sessionStartTime
                        if (duration >= MIN_SESSION_MS) {
                            totalTime += duration
                        }
                    }
                    currentPackage = null
                    sessionStartTime = 0L
                }

                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        if (!isTrackableApp(event.packageName, excludedPackages)) continue

                        // Tutup sesi app sebelumnya
                        if (currentPackage != null && currentPackage != event.packageName && sessionStartTime > 0) {
                            val duration = event.timeStamp - sessionStartTime
                            if (duration >= MIN_SESSION_MS) {
                                totalTime += duration
                            }
                        }

                        currentPackage = event.packageName
                        sessionStartTime = event.timeStamp
                    }

                    UsageEvents.Event.ACTIVITY_PAUSED -> {
                        if (event.packageName == currentPackage && sessionStartTime > 0) {
                            val duration = event.timeStamp - sessionStartTime
                            if (duration >= MIN_SESSION_MS) {
                                totalTime += duration
                            }
                            sessionStartTime = 0L
                        }
                    }

                    UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                        if (currentPackage != null && sessionStartTime > 0) {
                            val duration = event.timeStamp - sessionStartTime
                            if (duration >= MIN_SESSION_MS) {
                                totalTime += duration
                            }
                        }
                        currentPackage = null
                        sessionStartTime = 0L
                    }
                }

                lastEventTime = event.timeStamp
            }

            // Tutup sesi terakhir
            if (currentPackage != null && sessionStartTime > 0) {
                val duration = endTime - sessionStartTime
                if (duration >= MIN_SESSION_MS && duration < SCREEN_OFF_TIMEOUT) {
                    totalTime += duration
                }
            }

            totalTime
        } catch (e: Exception) {
            Log.e(TAG, "Error calculating screen time", e)
            0L
        }
    }

    /**
     * Mendapatkan usage per app dengan event-based tracking
     */
    private fun getAppUsageByEvents(startTime: Long, endTime: Long): Map<String, Long> {
        return try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val events = usageStatsManager.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()

            val excludedPackages = getExcludedPackages()
            val usageMap = mutableMapOf<String, Long>()

            var currentPackage: String? = null
            var sessionStartTime = 0L
            var lastEventTime = 0L

            while (events.hasNextEvent()) {
                events.getNextEvent(event)

                // Deteksi screen off
                if (lastEventTime > 0 && (event.timeStamp - lastEventTime) > SCREEN_OFF_TIMEOUT) {
                    if (currentPackage != null && sessionStartTime > 0) {
                        val duration = lastEventTime - sessionStartTime
                        if (duration >= MIN_SESSION_MS) {
                            usageMap[currentPackage!!] = (usageMap[currentPackage!!] ?: 0L) + duration
                        }
                    }
                    currentPackage = null
                    sessionStartTime = 0L
                }

                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        if (!isTrackableApp(event.packageName, excludedPackages)) continue

                        if (currentPackage != null && currentPackage != event.packageName && sessionStartTime > 0) {
                            val duration = event.timeStamp - sessionStartTime
                            if (duration >= MIN_SESSION_MS) {
                                usageMap[currentPackage!!] = (usageMap[currentPackage!!] ?: 0L) + duration
                            }
                        }

                        currentPackage = event.packageName
                        sessionStartTime = event.timeStamp
                    }

                    UsageEvents.Event.ACTIVITY_PAUSED -> {
                        if (event.packageName == currentPackage && sessionStartTime > 0) {
                            val duration = event.timeStamp - sessionStartTime
                            if (duration >= MIN_SESSION_MS) {
                                usageMap[currentPackage!!] = (usageMap[currentPackage!!] ?: 0L) + duration
                            }
                            sessionStartTime = 0L
                        }
                    }

                    UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                        if (currentPackage != null && sessionStartTime > 0) {
                            val duration = event.timeStamp - sessionStartTime
                            if (duration >= MIN_SESSION_MS) {
                                usageMap[currentPackage!!] = (usageMap[currentPackage!!] ?: 0L) + duration
                            }
                        }
                        currentPackage = null
                        sessionStartTime = 0L
                    }
                }

                lastEventTime = event.timeStamp
            }

            // Tutup sesi terakhir
            if (currentPackage != null && sessionStartTime > 0) {
                val duration = endTime - sessionStartTime
                if (duration >= MIN_SESSION_MS && duration < SCREEN_OFF_TIMEOUT) {
                    usageMap[currentPackage!!] = (usageMap[currentPackage!!] ?: 0L) + duration
                }
            }

            usageMap
        } catch (e: Exception) {
            Log.e(TAG, "Error getting app usage by events", e)
            emptyMap()
        }
    }

    private fun getExcludedPackages(): Set<String> {
        val excluded = HashSet<String>()
        
        excluded.add(packageName)
        
        val homeIntent = Intent(Intent.ACTION_MAIN)
        homeIntent.addCategory(Intent.CATEGORY_HOME)
        
        // CRITICAL: Android 13+ butuh ResolveInfoFlags
        val launchers = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                homeIntent,
                PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(homeIntent, PackageManager.MATCH_DEFAULT_ONLY)
        }
        
        for (launcher in launchers) {
            excluded.add(launcher.activityInfo.packageName)
        }
        
        // System apps
        excluded.add("com.android.systemui")
        excluded.add("com.android.launcher")
        excluded.add("com.android.launcher2")
        excluded.add("com.android.launcher3")
        
        // Google services
        excluded.add("com.google.android.gms")
        excluded.add("com.google.android.gsf")
        
        // Keyboards
        excluded.add("com.android.inputmethod.latin")
        excluded.add("com.google.android.inputmethod.latin")
        excluded.add("com.samsung.android.honeyboard")
        excluded.add("com.samsung.android.bixby.agent")
        
        // System utilities
        excluded.add("android")
        excluded.add("com.android.settings")
        excluded.add("com.android.packageinstaller")
        excluded.add("com.android.providers.downloads")
        excluded.add("com.android.phone")
        excluded.add("com.android.contacts")
        excluded.add("com.android.vending")
        
        return excluded
    }

    private fun isTrackableApp(pkg: String, excludedPackages: Set<String>): Boolean {
        if (excludedPackages.contains(pkg)) return false
        
        return try {
            val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getApplicationInfo(pkg, PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getApplicationInfo(pkg, 0)
            }
            
            // System apps harus punya launch intent
            if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                val launchIntent = packageManager.getLaunchIntentForPackage(pkg)
                return launchIntent != null
            }
            
            true
            
        } catch (e: PackageManager.NameNotFoundException) {
            false
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

            val totalMs = calculateScreenTimeByEvents(start, end)

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
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()
        
        // Gunakan event-based tracking
        val usageMap = getAppUsageByEvents(startTime, endTime)
        val excludedPackages = getExcludedPackages()
        
        return usageMap.entries
            .filter { it.value > 0 }
            .sortedByDescending { it.value }
            .mapNotNull { (pkg, duration) ->
                try {
                    val appName = try {
                        val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            packageManager.getApplicationInfo(pkg, PackageManager.ApplicationInfoFlags.of(0))
                        } else {
                            @Suppress("DEPRECATION")
                            packageManager.getApplicationInfo(pkg, 0)
                        }
                        packageManager.getApplicationLabel(appInfo).toString()
                    } catch (e: Exception) {
                        pkg
                    }
                    
                    mapOf(
                        "package" to pkg,
                        "appName" to appName,
                        "minutes" to (duration / 1000 / 60),
                        "seconds" to ((duration / 1000) % 60),
                        "isTracked" to true,
                        "isExcluded" to excludedPackages.contains(pkg)
                    )
                } catch (e: Exception) {
                    Log.w(TAG, "Error in debug stats for $pkg: ${e.message}")
                    null
                }
            }
    }
}