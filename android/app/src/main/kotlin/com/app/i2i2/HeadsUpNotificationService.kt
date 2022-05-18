package com.app.i2i2

import android.annotation.SuppressLint
import android.app.*
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import app.i2i2.R
import java.util.*

/**
 * Created by NguyenLinh on 26,May,2020
 */
class HeadsUpNotificationService : Service() {
    private val timer = Timer()
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    @SuppressLint("InvalidWakeLockTag")
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        var data: Bundle? = null
        if (intent != null && intent.extras != null) {
            data =
                intent.getBundleExtra(ConfigKey.FCM_DATA_KEY)
        }
        try {
            val receiveCallAction = Intent(
                application,
                HeadsUpNotificationActionReceiver::class.java
            )
            receiveCallAction.putExtra(
                ConfigKey.CALL_RESPONSE_ACTION_KEY,
                ConfigKey.CALL_RECEIVE_ACTION
            )
            receiveCallAction.putExtra(
                ConfigKey.FCM_DATA_KEY,
                data
            )
            receiveCallAction.action = "RECEIVE_CALL"
            val cancelCallAction = Intent(
                application,
                HeadsUpNotificationActionReceiver::class.java
            )
            cancelCallAction.putExtra(
                ConfigKey.CALL_RESPONSE_ACTION_KEY,
                ConfigKey.CALL_CANCEL_ACTION
            )
            cancelCallAction.putExtra(
                ConfigKey.FCM_DATA_KEY,
                data
            )
            cancelCallAction.action = "CANCEL_CALL"
            val receiveCallPendingIntent = PendingIntent.getBroadcast(
                application,
                1200,
                receiveCallAction,
                PendingIntent.FLAG_UPDATE_CURRENT
            )
            val cancelCallPendingIntent = PendingIntent.getBroadcast(
                application,
                1201,
                cancelCallAction,
                PendingIntent.FLAG_UPDATE_CURRENT
            )
            val fullScreenIntent = Intent(this, NotificationActivity::class.java)
            val fullScreenPendingIntent = PendingIntent.getActivity(
                this, 0,
                fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT
            )
            createChannel()
            // setFullScreenIntent
            val ACTION_NOTIFICATION_EXITACTIVITY =
                "com.android.demopushincomingcall.IncomingActivity"
            val exitIntent = Intent()
            exitIntent.action = ACTION_NOTIFICATION_EXITACTIVITY
            val pExitIntent = PendingIntent.getBroadcast(this, 1, exitIntent, 0)

            val view = RemoteViews(packageName, R.layout.activity_incoming_call)
            var notificationBuilder: NotificationCompat.Builder? = null
            notificationBuilder = NotificationCompat.Builder(
                this,
                ConfigKey.CHANNEL_ID
            )
                .setContentText("Test Call ")
                .setContentTitle("Incoming Voice Call")
                .setSmallIcon(android.R.drawable.sym_call_incoming)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_CALL)

                .addAction(
                    android.R.drawable.ic_menu_close_clear_cancel,
                    "Decline",
                    cancelCallPendingIntent
                )
                .addAction(
                    android.R.drawable.sym_action_call,
                    "Accept",
                    receiveCallPendingIntent
                )
                .setAutoCancel(true)
                .setOngoing(true).setContent(view)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setDefaults(NotificationCompat.DEFAULT_SOUND or NotificationCompat.DEFAULT_VIBRATE)
                .setSound(Uri.parse("android.resource://" + application.packageName + "/" + R.raw.video_call))
            //.setFullScreenIntent(fullScreenPendingIntent, false);
            var incomingCallNotification: Notification? = null
            if (notificationBuilder != null) {
                incomingCallNotification = notificationBuilder.build()
            }
            val pm =
                applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
            val isScreenOn = pm.isInteractive
            Log.e("screen on.......", "" + isScreenOn)
            if (!isScreenOn) {
                pm.newWakeLock(
                    PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
                    "MyLock"
                )
                    .acquire(10000)
                pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyCpuLock")
                    .acquire(10000)
            }
            startForeground(9999, incomingCallNotification)
            val task: TimerTask = object : TimerTask() {
                override fun run() {
                    val notificationManager =
                        applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    notificationManager.cancel(9999)
                    val it = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
                    sendBroadcast(it)
                    stopSelf()
                    Log.d("TimerTask", "Cancel Notification")
                }
            }
            timer.schedule(task, 15000)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        timer.cancel()
    }

    /*
      Create noticiation channel if OS version is greater than or eqaul to Oreo
    */
    fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                ConfigKey.CHANNEL_ID,
                ConfigKey.CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = ConfigKey.CHANNEL_NAME
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            channel.setSound(
                Uri.parse("android.resource://" + application.packageName + "/" + R.raw.video_call),
                AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setLegacyStreamType(AudioManager.STREAM_RING)
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION).build()
            )
            Objects.requireNonNull(
                application.getSystemService(
                    NotificationManager::class.java
                )
            ).createNotificationChannel(channel)
        }
    }
}
