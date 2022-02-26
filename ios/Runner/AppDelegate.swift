import UIKit
import Flutter
import CallKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CXProviderDelegate  {
    
    var notificationChannel: FlutterMethodChannel? = nil
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        notificationChannel = FlutterMethodChannel(name: "app.2i2i/notification",
                                                       binaryMessenger: controller.binaryMessenger)
        notificationChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let args = call.arguments as? Dictionary<String, Any>
            self.createNotification(value: args?["name"] as! String)
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func createNotification(value: String) {
        let config = CXProviderConfiguration(localizedName: "2i2i")
        if #available(iOS 11.0, *) {
            config.includesCallsInRecents = false
        } else {
            // Fallback on earlier versions
        };
        config.supportsVideo = false;
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        
        
        let provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: value)
        update.hasVideo = true
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = false
        update.supportsDTMF = false
        
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
        
    }
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        notificationChannel?.invokeMethod("ANSWER", arguments: "Call ANSWER")
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        notificationChannel?.invokeMethod("CUT", arguments: "CALL CUT")
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        notificationChannel?.invokeMethod("MUTE", arguments: "CALL MUTE")
    }
}
