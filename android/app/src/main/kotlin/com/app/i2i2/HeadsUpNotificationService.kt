package com.app.i2i2

import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import com.app.i2i2.notification.NotificationBuilder
import java.util.*
import android.app.NotificationChannel
import android.content.Context
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class HeadsUpNotificationService : Service() {
    private val timer = Timer()
    private var hashMap = HashMap<String, String>()

    private var notificationManager: NotificationManager? = null

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        try {
            timer.cancel()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        try {
            if (intent.extras != null) {
                hashMap =
                    intent.getSerializableExtra(ConfigKey.FCM_DATA_KEY) as HashMap<String, String>
            }
            if (intent.action.equals(ConfigKey.CALL_NEW_NOTIFICATION)) {
                notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
               /* notificationManager?.notify(
                    11,
                    NotificationBuilder(this).build()
                )*/

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
                startForeground(9999, NotificationBuilder(this).build(hashMap))
                val task: TimerTask = object : TimerTask() {
                    override fun run() {
                        disposeNotification()
                    }
                }
                timer.schedule(task, 15000)
            } else if (intent.action.equals(ConfigKey.CALL_ACCEPT) || intent.action.equals(ConfigKey.CALL_DECLINE)) {
                disposeNotification()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return START_STICKY
    }

    override fun onCreate() {
        createNotificationChannel()
        super.onCreate()
    }

    private fun createNotificationChannel() {
        val notificationManager =
            application.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                NotificationBuilder.NOTIFICATION_CHANEL_ID,
                "2i2i",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationChannel.description = "2i2i call notification..."
            notificationChannel.enableVibration(true)
            notificationChannel.lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            notificationManager.createNotificationChannel(notificationChannel)
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        try {
            timer.cancel()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun disposeNotification() {
        notificationManager?.cancel(11)
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(11)
        stopForeground(true)
        stopSelf()
    }
}
