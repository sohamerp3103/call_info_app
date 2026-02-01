package com.soham.callinfo.call_info_app

import android.content.Context

object CallDetailsStore {
    private const val PREFS_NAME = "call_info_store"
    private const val KEY_LAST_NUMBER = "last_phone_number"

    fun saveLastNumber(context: Context, phoneNumber: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_LAST_NUMBER, phoneNumber)
            .apply()
    }

    fun getLastNumber(context: Context): String? {
        return context
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_LAST_NUMBER, null)
    }
}
