package com.example.eye_care_app

import android.content.Context
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import android.util.Log // Tambahkan import ini

object ScreenUsageManager {

    private const val PREF = "screen_usage"

    fun onScreenOn(context: Context) {
        val pref = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        
        checkDateReset(context, pref)

        val count = pref.getInt("screen_on_count", 0)
        pref.edit()
            .putLong("last_on_time", System.currentTimeMillis())
            .putInt("screen_on_count", count + 1)
            .putBoolean("is_screen_on", true)
            .apply()
    }

    fun onScreenOff(context: Context) {
        val pref = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val lastOn = pref.getLong("last_on_time", -1)

        if (lastOn != -1L) {
            val duration = System.currentTimeMillis() - lastOn
            val total = pref.getLong("screen_on_ms", 0)
            pref.edit()
                .putLong("screen_on_ms", total + duration)
                .putBoolean("is_screen_on", false)
                .apply()
        }
    }

    fun checkDateReset(context: Context, pref: SharedPreferences? = null) {
        val sharedPref = pref ?: context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val today = getToday()
        val lastDate = sharedPref.getString("last_date", "")

        Log.d("ScreenUsage", "Cek Reset: Today=$today, LastDate=$lastDate")

        if (lastDate != "" && lastDate != today) {
            // Cek jika layar menyala saat pergantian hari (Midnight Crossing)
            val isScreenOn = sharedPref.getBoolean("is_screen_on", false)
            val lastOn = sharedPref.getLong("last_on_time", 0)
            var previousTotal = sharedPref.getLong("screen_on_ms", 0)

            if (isScreenOn && lastOn > 0) {
                val calendar = Calendar.getInstance()
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                calendar.set(Calendar.MILLISECOND, 0)
                val midnight = calendar.timeInMillis

                // Jika waktu nyala terakhir sebelum tengah malam hari ini
                if (lastOn < midnight) {
                    val durationYesterday = midnight - lastOn
                    Log.d("ScreenUsage", "Midnight Crossing terdeteksi! Tambah ke kemarin: $durationYesterday ms")
                    previousTotal += durationYesterday
                    // Update last_on_time jadi 00:00 hari ini agar hitungan hari ini mulai dari 0
                    sharedPref.edit().putLong("last_on_time", midnight).apply()
                }
            }

            sharedPref.edit().putLong("history_$lastDate", previousTotal).apply()
            Log.d("ScreenUsage", "RESET SUKSES. Data $lastDate disimpan: $previousTotal ms")

            sharedPref.edit()
                .putLong("screen_on_ms", 0)
                .putInt("screen_on_count", 0)
                .putString("last_date", today)
                .apply()
        } else if (lastDate == "") {
            sharedPref.edit().putString("last_date", today).apply()
        }
    }

    private fun getToday(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(Date())
    }
}
