package app.i2i2

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import com.app.i2i2.ConfigKey
import com.app.i2i2.HeadsUpNotificationService
import com.app.i2i2.notification.NotificationBuilder
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var notificationManager: NotificationManager? = null
    private var incomingCallNotificationBuilder: NotificationBuilder? = null

    companion object {
        var channel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.e("notification", "configureFlutterEngine registred.: ")
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app.2i2i/notification"
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            FirebaseApp.initializeApp(this)
            val firebaseAppCheck = FirebaseAppCheck.getInstance()
            firebaseAppCheck.installAppCheckProviderFactory(
                DebugAppCheckProviderFactory.getInstance()
            )
            requestAppBackground()
            incomingCallNotificationBuilder = NotificationBuilder(this)
            notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(11)
            onNewIntent(intent);

        } catch (e: Exception) {
            Log.e("notification", "onCreate Exception: ${e.message}")
        }
        super.onCreate(savedInstanceState)
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

    override fun onNewIntent(intent: Intent) {
        val places = intent.getSerializableExtra("CALL_ACCEPT_DATA") as HashMap<String, String>?
        if (intent.action != null && intent.action.equals(ConfigKey.CALL_ACCEPT)) {
            try {
                channel?.invokeMethod("ANSWER", places);
                notificationManager?.cancel(11)
                (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(11)
                application.stopService(
                    Intent(
                        this,
                        HeadsUpNotificationService::class.java
                    )
                )
            } catch (e: Exception) {
                Log.e("notification", "onNewIntent Exception: ", e);
            }
        }
    }
}