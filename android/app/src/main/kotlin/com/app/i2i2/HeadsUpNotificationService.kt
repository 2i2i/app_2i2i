package com.app.i2i2

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import app.i2i2.MainActivity
import app.i2i2.R
import java.util.*


/**
 * Created by NguyenLinh on 26,May,2020
 */


class HeadsUpNotificationService : Service() {
    val timer = Timer()
    var hashMap = HashMap<String, String>()
    var incomingCallNotification: Notification? = null
    var mediaPlayer: MediaPlayer? = null


    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        timer.cancel()
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        if (intent.extras != null) {
            hashMap = intent.getSerializableExtra(ConfigKey.FCM_DATA_KEY) as HashMap<String, String>
        }
        if (intent.action.equals(ConfigKey.CALL_NEW_NOTIFICATION)) {
            createChannel()
            showNotification(hashMap)
        } else if (intent.action.equals(ConfigKey.CALL_ACCEPT)) {
            disposeNotification()
            var openIntent: Intent? = null
            openIntent = Intent(this, MainActivity::class.java)
            openIntent.putExtra(this.packageName, "NOTIFICATION_ID")
            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(openIntent)

        } else if (intent.action.equals(ConfigKey.CALL_DECLINE)) {
            disposeNotification()
            stopForeground(true)
        }
        return START_STICKY
    }

    private fun showNotification(hashMap: HashMap<String, String>) {

        val notificationDismiss = Intent(this, HeadsUpNotificationService::class.java)
        notificationDismiss.action = ConfigKey.CALL_DECLINE
        val notificationDismissIntent = PendingIntent.getService(
            this, 0,
            notificationDismiss, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val callAccept = Intent(this, HeadsUpNotificationService::class.java)
        callAccept.action = ConfigKey.CALL_ACCEPT
        val callAcceptIntent = PendingIntent.getService(
            this, 0,
            callAccept, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )


        mediaPlayer = MediaPlayer.create(applicationContext, R.raw.video_call)
        mediaPlayer?.start()
        var notificationBuilder: NotificationCompat.Builder? = null
        notificationBuilder = NotificationCompat.Builder(
            this,
            ConfigKey.CHANNEL_ID
        ).setContentText(hashMap["title"] ?: "2i2i")
            .setContentTitle(hashMap["body"] ?: "mobile")
            .setSmallIcon(android.R.drawable.sym_call_incoming)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setOngoing(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setDefaults(NotificationCompat.DEFAULT_SOUND or NotificationCompat.DEFAULT_VIBRATE)
        if ((hashMap["type"] ?: "").lowercase() == ConfigKey.FCM_CALL_TYPE.lowercase()) {
            val views = RemoteViews(
                packageName,
                R.layout.activity_incoming_call
            )
            views.setTextViewText(R.id.user_title, hashMap["title"] ?: "2i2i")
            notificationBuilder.setCustomContentView(views)
            notificationBuilder.setCustomBigContentView(views)

            val callDecline = Intent(this, HeadsUpNotificationService::class.java)
            callDecline.action = ConfigKey.CALL_DECLINE
            val callDeclineIntent = PendingIntent.getService(
                this, 0,
                callDecline, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_cut, callDeclineIntent)
            views.setOnClickPendingIntent(R.id.btn_accept, callAcceptIntent)
        } else {
            notificationBuilder.setContentText(hashMap["title"] ?: "2i2i")
                .setContentTitle(hashMap["body"] ?: "mobile")
            notificationBuilder.addAction(
                android.R.drawable.stat_notify_chat,
                "View",
                callAcceptIntent
            ).addAction(
                android.R.drawable.stat_notify_chat,
                "Dismiss",
                notificationDismissIntent
            )
        }

        incomingCallNotification = notificationBuilder.build()

        val pm = applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
        val isScreenOn = pm.isInteractive
        if (!isScreenOn) {
            pm.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
                "MyLock"
            ).acquire(10000)
            pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyCpuLock")
                .acquire(10000)
        }
        startForeground(9999, incomingCallNotification)
        val task: TimerTask = object : TimerTask() {
            override fun run() {
                disposeNotification()
            }
        }
        timer.schedule(task, 15000)
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        timer.cancel()
    }

    private fun disposeNotification() {
        NotificationManagerCompat.from(this).cancel(null, 1)
        mediaPlayer?.stop()
        mediaPlayer?.prepare()
        val myService: Intent = Intent(
            this,
            HeadsUpNotificationService::class.java
        )

        stopService(myService)
        stopSelf()
    }

    private fun createChannel() {
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
