import Flutter
import UIKit

public class SwiftLinkBridgePlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "link_bridge", binaryMessenger: registrar.messenger())
        let instance = SwiftLinkBridgePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        ///注册所有channel
        let bridgeChannels = FlutterLinkCannnelManger.getAllChannel().map({$0.init()})
        bridgeChannels.forEach { $0.setup(with: registrar.messenger())}
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
