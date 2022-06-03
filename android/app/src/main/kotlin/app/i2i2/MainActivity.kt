package app.i2i2

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import com.app.i2i2.HeadsUpNotificationService
import com.app.i2i2.notification.NotificationBuilder
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var notificationManager: NotificationManager? = null
    private var incomingCallNotificationBuilder: NotificationBuilder? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        FirebaseApp.initializeApp(this)
        val firebaseAppCheck = FirebaseAppCheck.getInstance()
        firebaseAppCheck.installAppCheckProviderFactory(
            DebugAppCheckProviderFactory.getInstance()
        )
        incomingCallNotificationBuilder = NotificationBuilder(this)
        notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(11)
        requestAppBackground()
        super.onCreate(savedInstanceState)

    }

    override fun onResume() {
        try {
            notificationManager?.cancel(11)
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(11)
            application.stopService(
                Intent(
                    this,
                    HeadsUpNotificationService::class.java
                )
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
        super.onResume()
    }

    private fun requestAppBackground() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent()
            val packageName = packageName
            val pm =
                getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            }
        }
    }
}