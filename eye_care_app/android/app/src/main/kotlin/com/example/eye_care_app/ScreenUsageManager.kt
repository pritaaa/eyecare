package com.example.eye_care_app

import android.content.Context
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object ScreenUsageManager {

    private const val PREF = "screen_usage"

    fun onScreenOn(context: Context) {
        val pref = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val today = getToday()

        checkDateReset(pref, today)

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

    private fun checkDateReset(pref: SharedPreferences, today: String) {
        val lastDate = pref.getString("last_date", "")
        if (lastDate != today) {
            // Simpan data hari sebelumnya ke history (format key: history_YYYY-MM-DD)
            if (lastDate != "") {
                val previousTotal = pref.getLong("screen_on_ms", 0)
                pref.edit().putLong("history_$lastDate", previousTotal).apply()
            }

            pref.edit()
                .putLong("screen_on_ms", 0)
                .putInt("screen_on_count", 0)
                .putString("last_date", today)
                .apply()
        }
    }

    private fun getToday(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(Date())
    }
}
