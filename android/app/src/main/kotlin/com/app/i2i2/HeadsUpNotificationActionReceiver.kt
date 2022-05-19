package com.app.i2i2

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import app.i2i2.MainActivity

/**
 * Created by NguyenLinh on 26,May,2020
 */

class HeadsUpNotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        Log.i("My_Lifecycle", "onReceive: ")
        if (intent != null && intent.extras != null) {
            val action = intent.getStringExtra(ConfigKey.CALL_RESPONSE_ACTION_KEY)
            val data = intent.getBundleExtra(ConfigKey.FCM_DATA_KEY)
            action?.let { performClickAction(context, it, data) }

            // Close the notification after the click action is performed.

            val pm: PackageManager = context.packageManager
            val componentName =
                ComponentName(context, HeadsUpNotificationActionReceiver::class.java)
            pm.setComponentEnabledSetting(
                componentName, PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
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
            openIntent = Intent(context, MainActivity::class.java)
            openIntent.putExtra(context.packageName, "NOTIFICATION_ID")
            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(openIntent)
            context.stopService(
                Intent(
                    context,
                    HeadsUpNotificationService::class.java
                )
            )
        } else if (action == ConfigKey.CALL_CANCEL_ACTION) {
            context.stopService(
                Intent(
                    context,
                    HeadsUpNotificationService::class.java
                )
            )
            val pm: PackageManager = context.packageManager
            val componentName =
                ComponentName(context, HeadsUpNotificationActionReceiver::class.java)
            pm.setComponentEnabledSetting(
                componentName, PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
