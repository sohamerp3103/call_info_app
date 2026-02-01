package com.soham.callinfo.call_info_app

object CallStateTracker {
    var pendingNotificationWithoutNumber: Boolean = false
    var lastCallState: String? = null
}
