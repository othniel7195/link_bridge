//
//  FlutterChannelLink.swift
//  link_bridge
//
//  Created by jimmy on 2022/1/7.
//

import Foundation
import Flutter

public protocol FlutterChannelLink: AnyObject {
    var handlers: [SwiftFlutterBridgeHandler] { get set }
    
    var methodChannel: FlutterMethodChannel? { get set }
    var methodChannelName: String? { get }
    var eventChannel: FlutterEventChannel? { get set }
    var eventChannelName: String? { get }
    var streamHandler: FlutterEnvironmentStreamHandler? { set get }
    
    init()
    func registerStreamHandlers()
    func registerMethodHandlers()
    func setup(with binaryMessenger: FlutterBinaryMessenger)
    func clearData()
    func moduleWillUnregister()
}


public extension FlutterChannelLink {
    func callHandlers(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let handler = FlutterBridge.handler else {
            return
        }
        
        handler(call.method, call.arguments, result)
    }
    
    func setup(with binaryMessenger: FlutterBinaryMessenger) {
        if (methodChannelName == nil && eventChannelName == nil) {
            fatalError("MethodChannelName and eventChannelName cannot be empty at the same time!")
        }
        
        if let methodChannelName = methodChannelName {
            methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: binaryMessenger)
            registerMethodHandlers()
            methodChannel?.setMethodCallHandler({ (call, result) in
                debugPrint("[Flutter Channel] Channel: \(methodChannelName) method: \(call.method) and arguments: \(String(describing: call.arguments))")
                self.callHandlers(call: call, result: result)
            })
        }
        
        if let eventChannelName = eventChannelName {
            streamHandler = FlutterEnvironmentStreamHandler()
            guard let streamHandler = streamHandler else {
                fatalError("StreamHandler can not be nil.")
            }
            
            eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: binaryMessenger)
            eventChannel?.setStreamHandler(streamHandler)
            registerStreamHandlers()
        }
    }
    
    func moduleWillUnregister() {}
    func clearData() {}
}
