package com.app.i2i2.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import app.i2i2.MainActivity
import app.i2i2.R
import com.app.i2i2.ConfigKey
import com.app.i2i2.HeadsUpNotificationService
import java.util.*

class NotificationBuilder(private val context: Context) {
    private val vibrationPattern = longArrayOf(1000, 1000)
    private val soundUri: Uri = Uri.Builder()
        .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
        .authority(context.packageName)
        .path(R.raw.video_call.toString())
        .build()


    private fun createNotificationChannel() {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                NOTIFICATION_CHANEL_ID,
                "2i2i",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationChannel.description = "2i2i call notification..."
            notificationChannel.vibrationPattern = vibrationPattern
            notificationChannel.enableVibration(true)
            notificationChannel.lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            notificationChannel.setSound(
                soundUri,
                AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .build()
            )
            notificationManager.createNotificationChannel(notificationChannel)
        }
    }


    fun build(hashMap: HashMap<String, String>): Notification {

        val incomingCallIntent = Intent(
            context,
            MainActivity::class.java
        )
        val incomingCallPendingIntent = PendingIntent.getActivity(
            context, INCOMING_CALL_REQUEST_ID,
            incomingCallIntent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )
        val notification: Notification = NotificationCompat.Builder(
            context, NOTIFICATION_CHANEL_ID
        ).setSmallIcon(android.R.drawable.sym_call_incoming)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setContentIntent(incomingCallPendingIntent)
            .setSound(soundUri)
            .setOngoing(true)
            .setAutoCancel(true)
            .setVibrate(vibrationPattern)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(getIncomingCallNotificationView(hashMap, true))
            .setCustomBigContentView(getIncomingCallNotificationView(hashMap, false))
            .build()
        notification.flags = notification.flags or NotificationCompat.FLAG_INSISTENT
        return notification
    }

    private fun getIncomingCallNotificationView(
        hashMap: HashMap<String, String>,
        isCollapse: Boolean
    ): RemoteViews {
        val incomingCallNotificationView: RemoteViews = if (isCollapse) {
            RemoteViews(context.packageName, R.layout.activity_incoming_call_collapsed)
        } else {
            RemoteViews(context.packageName, R.layout.activity_incoming_call)
        }


        val answerCallIntent: Intent = Intent(context, MainActivity::class.java)
        val hangUpIntent: Intent = Intent(context, HeadsUpNotificationService::class.java)
        incomingCallNotificationView.setTextViewText(R.id.user_title, hashMap["title"] ?: "2i2i")

        hangUpIntent.action = ConfigKey.CALL_DECLINE
        val hangUpPendingIntent = PendingIntent.getService(
            context,
            0,
            hangUpIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        answerCallIntent.action = ConfigKey.CALL_ACCEPT
        answerCallIntent.putExtra("CALL_ACCEPT_DATA", hashMap)
        answerCallIntent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        val answerCallPendingIntent = PendingIntent.getActivity(
            context,
            0,
            answerCallIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        incomingCallNotificationView.setOnClickPendingIntent(
            R.id.btn_accept,
            answerCallPendingIntent
        )
        incomingCallNotificationView.setOnClickPendingIntent(
            R.id.btn_cut,
            hangUpPendingIntent
        )
        return incomingCallNotificationView
    }

    companion object {
        const val NOTIFICATION_CHANEL_ID = "INCOMING_CALL_NOTIFICATION_CHANEL_ID"
        const val INCOMING_CALL_REQUEST_ID = 11
    }

    init {
        createNotificationChannel()
    }
}