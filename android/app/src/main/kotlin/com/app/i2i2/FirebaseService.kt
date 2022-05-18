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
    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.i("My_Lifecycle", "remoteMessage.notification.toString()")
        if (remoteMessage.notification != null) {
            val title = (if (remoteMessage.notification == null) "" else remoteMessage.notification!!.title)!!
            val body = (if (remoteMessage.notification == null) "" else remoteMessage.notification!!.body)!!
            // sendNotification(title, body);
        } else {
            //In background we use getData.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && isBackground) {
                startForegroundService(Intent(this, HeadsUpNotificationService::class.java))
            } else {
                val intent = Intent(this, NotificationActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                intent.putExtra(ConfigKey.FCM_DATA_KEY, remoteMessage)
                intent.action = "android.intent.action.MAIN"
                intent.addCategory("android.intent.category.LAUNCHER")
                application.startActivity(intent)
            }
        }
    }

    companion object {
        private const val TAG = "MyFirebaseMsgService"
    }
}