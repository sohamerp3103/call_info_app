package com.soham.callinfo.call_info_app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object CallEventLogStore {
    private const val PREFS_NAME = "call_info_logs"
    private const val KEY_LOGS = "event_logs"
    private const val MAX_LOGS = 50

    fun appendLog(
        context: Context,
        callState: String,
        phoneNumber: String?,
        source: String
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_LOGS, "[]") ?: "[]"
        val array = JSONArray(existing)
        val entry = JSONObject()
        entry.put("callState", callState)
        entry.put("phoneNumber", phoneNumber ?: JSONObject.NULL)
        entry.put("source", source)
        entry.put("timestamp", System.currentTimeMillis())
        array.put(entry)

        while (array.length() > MAX_LOGS) {
            val trimmed = JSONArray()
            for (i in 1 until array.length()) {
                trimmed.put(array.getJSONObject(i))
            }
            prefs.edit().putString(KEY_LOGS, trimmed.toString()).apply()
            return
        }

        prefs.edit().putString(KEY_LOGS, array.toString()).apply()
    }

    fun getLogs(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_LOGS, "[]") ?: "[]"
    }

    fun clearLogs(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().remove(KEY_LOGS).apply()
    }
}
