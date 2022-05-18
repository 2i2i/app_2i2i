package com.app.i2i2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle

/**
 * Created by NguyenLinh on 26,May,2020
 */
class HeadsUpNotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent != null && intent.extras != null) {
            val action = intent.getStringExtra(ConfigKey.CALL_RESPONSE_ACTION_KEY)
            val data = intent.getBundleExtra(ConfigKey.FCM_DATA_KEY)
            action?.let { performClickAction(context, it, data) }

            // Close the notification after the click action is performed.
            val it = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
            context.sendBroadcast(it)
            context.stopService(
                Intent(
                    context,
                    HeadsUpNotificationService::class.java
                )
            )
        }
    }

    private fun performClickAction(
        context: Context,
        action: String,
        data: Bundle?
    ) {
        if (action == ConfigKey.CALL_RECEIVE_ACTION) {
            var openIntent: Intent? = null
            openIntent = Intent(context, NotificationActivity::class.java)
            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(openIntent)
        } else if (action == ConfigKey.CALL_CANCEL_ACTION) {
            context.stopService(
                Intent(
                    context,
                    HeadsUpNotificationService::class.java
                )
            )
            val it = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
            context.sendBroadcast(it)
        }
    }
}
