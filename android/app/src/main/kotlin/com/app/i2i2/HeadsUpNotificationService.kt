package com.app.i2i2

import android.app.*
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import app.i2i2.MainActivity
import app.i2i2.R
import java.util.*


/**
 * Created by NguyenLinh on 26,May,2020
 */


class HeadsUpNotificationService : Service() {
    val timer = Timer()

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        var hashMap = HashMap<String, String>()

        if (intent.extras != null) {
            Log.i("My_Lifecycle", "onStartCommand: ")
            hashMap = intent.getSerializableExtra(ConfigKey.FCM_DATA_KEY) as HashMap<String, String>
        }
        createChannel()
        showNotification(hashMap)
        if (intent.action.equals(ConfigKey.CALL_ACCEPT)) {
            var openIntent: Intent? = null
            openIntent = Intent(application, MainActivity::class.java)
            openIntent.putExtra(application.packageName, "NOTIFICATION_ID")
            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            application.startActivity(openIntent)
            disposeNotification()
            stopSelf()
        } else if (intent.action.equals(ConfigKey.CALL_DECLINE)) {
            disposeNotification()
            stopForeground(true)
            stopSelf()
        }
        return START_STICKY
    }

    private fun showNotification(hashMap: HashMap<String, String>) {

        val views = RemoteViews(
            packageName,
            R.layout.activity_incoming_call
        )
        val callDecline = Intent(this, HeadsUpNotificationService::class.java)
        callDecline.action = ConfigKey.CALL_DECLINE
        val callDeclineIntent = PendingIntent.getService(
            this, 0,
            callDecline, 0
        )
        views.setOnClickPendingIntent(R.id.btn_cut, callDeclineIntent)


        val callAccept = Intent(this, HeadsUpNotificationService::class.java)
        callAccept.action = ConfigKey.CALL_ACCEPT
        val callAcceptIntent = PendingIntent.getService(
            this, 0,
            callAccept, 0
        )
        views.setOnClickPendingIntent(R.id.btn_accept, callAcceptIntent)


        var notificationBuilder: NotificationCompat.Builder? = null
        notificationBuilder = NotificationCompat.Builder(
            this,
            ConfigKey.CHANNEL_ID
        ).setContentText(hashMap["title"] ?: "2i2i")
            .setContentTitle(hashMap["body"] ?: "mobile")
            .setSmallIcon(android.R.drawable.sym_call_incoming)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setOngoing(true).setContent(views)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setDefaults(NotificationCompat.DEFAULT_SOUND or NotificationCompat.DEFAULT_VIBRATE)
            .setSound(Uri.parse("android.resource://" + application.packageName + "/" + R.raw.video_call))
        var incomingCallNotification: Notification? = null
        if (notificationBuilder != null) {
            incomingCallNotification = notificationBuilder.build()
        }
        if ((hashMap["type"] ?: "").lowercase() == ConfigKey.FCM_CALL_TYPE.lowercase()) {
            val view = RemoteViews(packageName, R.layout.activity_incoming_call)
            view.setTextViewText(R.id.user_title, hashMap["title"] ?: "2i2i")
            notificationBuilder.setCustomContentView(view)
        } else {
            notificationBuilder.addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Reject",
                callDeclineIntent
            ).addAction(
                android.R.drawable.sym_action_call,
                "Accept",
                callAcceptIntent
            )
        }
        val pm =
            applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
        val isScreenOn = pm.isInteractive
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
                disposeNotification()
                stopSelf()
            }


        }
        timer.schedule(task, 15000)
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        timer.cancel()
    }

    private fun disposeNotification() {
        val pm: PackageManager = application.packageManager
        val componentName =
            ComponentName(application, HeadsUpNotificationActionReceiver::class.java)
        pm.setComponentEnabledSetting(
            componentName, PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
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
