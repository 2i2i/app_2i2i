package com.app.i2i2

import android.content.Intent
import android.os.Build
import android.util.Log
import com.app.i2i2.MyApplication.Companion.isBackground
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * Created by NguyenLinh on 26,May,2020
 */
class FirebaseService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.i("My_Lifecycle", "remoteMessage.notification.toString()")
        if (remoteMessage.notification != null) {
            val title =

                (if (remoteMessage.notification == null) "" else remoteMessage.notification!!.title)!!
            val body =
                (if (remoteMessage.notification == null) "" else remoteMessage.notification!!.body)!!
            // sendNotification(title, body);
        } else {
            val hashMap = HashMap<String, String>()
            hashMap["title"] = remoteMessage.data["title"] ?: ""
            hashMap["body"] = remoteMessage.data["body"] ?: ""
            hashMap["type"] = remoteMessage.data["type"] ?: ""
            if ((remoteMessage.data["type"] ?: "").equals(
                    ConfigKey.FCM_CALL_TYPE,
                    ignoreCase = true
                )
            ) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && isBackground) {
                    application.startForegroundService(
                        Intent(
                            this,
                            HeadsUpNotificationService::class.java
                        ).putExtra(ConfigKey.FCM_DATA_KEY, hashMap)
                            .setAction(ConfigKey.CALL_NEW_NOTIFICATION)
                    )
                }/* else {
                val intent = Intent(this, NotificationActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                intent.putExtra(ConfigKey.FCM_DATA_KEY, remoteMessage)
                intent.action = "android.intent.action.MAIN"
                intent.addCategory("android.intent.category.LAUNCHER")
                application.startActivity(intent)
            }*/
            }
        }
    }

    companion object {
        private const val TAG = "MyFirebaseMsgService"
    }
}