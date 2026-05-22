package com.screentrainer.screen_trainer

import android.app.usage.UsageStatsManager
import android.content.Context
import android.app.usage.UsageEvents
import android.app.usage.UsageEvents.Event
import android.app.usage.UsageStats
import android.app.AppOpsManager
import android.os.Process
import java.util.*

object UsageStatsHelper {
    fun hasUsagePermission(context: Context): Boolean {
        try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
            return mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            return false
        }
    }

    fun getTodayUsageMs(context: Context, packageName: String): Long {
        try {
            val now = System.currentTimeMillis()
            val cal = Calendar.getInstance()
            cal.timeInMillis = now
            cal.set(Calendar.HOUR_OF_DAY, 0)
            cal.set(Calendar.MINUTE, 0)
            cal.set(Calendar.SECOND, 0)
            cal.set(Calendar.MILLISECOND, 0)
            val start = cal.timeInMillis

            val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val stats: List<UsageStats> = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, now)
            var total: Long = 0
            for (s in stats) {
                if (s.packageName == packageName) {
                    total += s.totalTimeInForeground
                }
            }
            return total
        } catch (e: Exception) {
            return 0L
        }
    }
}
