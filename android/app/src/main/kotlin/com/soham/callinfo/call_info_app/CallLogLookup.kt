package com.soham.callinfo.call_info_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.provider.CallLog
import androidx.core.content.ContextCompat

object CallLogLookup {
    fun getLastNumber(context: Context): String? {
        if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_CALL_LOG
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }

        val projection = arrayOf(CallLog.Calls.NUMBER)
        val cursor = context.contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            projection,
            null,
            null,
            "${CallLog.Calls.DATE} DESC"
        )

        cursor?.use {
            if (it.moveToFirst()) {
                return it.getString(0)
            }
        }

        return null
    }
}
