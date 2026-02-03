package com.example.yapeapplication

import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel

class YapeNotificationListenerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val text = extras.getCharSequence("android.text")?.toString()
        if (!text.isNullOrBlank()) {
            val data = mapOf(
                "text" to text,
                "timestamp" to System.currentTimeMillis()
            )
            StreamHandler.sendEvent(data)
        }
    }

    companion object {
        val StreamHandler = NotificationStreamHandler()

        fun hasNotificationAccess(context: Context): Boolean {
            val enabledListeners = android.provider.Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            )
            return enabledListeners?.contains(context.packageName) == true
        }
    }
}

class NotificationStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendEvent(data: Map<String, Any>) {
        eventSink?.success(data)
    }
}
