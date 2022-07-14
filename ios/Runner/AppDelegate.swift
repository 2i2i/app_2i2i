import UIKit
import Flutter
import CallKit
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CXProviderDelegate  {
    
    var notificationChannel: FlutterMethodChannel? = nil
    
    
    var provider: CXProvider? = nil
    var uuid = UUID()
    
    var args:Dictionary<String, Any>? = nil
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        notificationChannel = FlutterMethodChannel(name: "app.2i2i/notification",
                                                   binaryMessenger: controller.binaryMessenger)
        notificationChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if(call.method == "INCOMING_CALL"){
                self.args = call.arguments as? Dictionary<String, Any>
                self.createNotification(value:   self.args?["title"] as! String)
            }else if(call.method == "CUT_CALL"){
                self.provider?.reportCall(with: self.uuid, endedAt: Date(), reason: .remoteEnded)
            }else if(call.method == "ANSWER"){
                if(self.args!=nil){
                    self.notificationChannel?.invokeMethod("ANSWER", arguments: self.args)
        
                }
            }
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
        
        
        provider = CXProvider(configuration: config)
        provider?.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        
        update.remoteHandle = CXHandle(type: .generic, value: value)
        update.hasVideo = true
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = false
        update.supportsDTMF = false
        
        provider?.reportNewIncomingCall(with: uuid, update: update, completion: { error in })
        
        
    }
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        notificationChannel?.invokeMethod("ANSWER", arguments:   self.args)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        notificationChannel?.invokeMethod("CUT", arguments:   self.args)
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        notificationChannel?.invokeMethod("MUTE", arguments: "CALL MUTE")
    }
    
    
}
