//
//  TestChannel.swift
//  Runner
//
//  Created by jimmy on 2022/1/9.
//

import Foundation
import link_bridge

struct LinkTestData: Decodable {
    let t1: String
    let t2: String
}

class FlutterLinkTest: FlutterChannelLink {
    var methodChannel: FlutterMethodChannel?
    var timer: Timer?
    
    var eventChannel: FlutterEventChannel?
    
    required init() {
    }
    
    var handlers: [SwiftFlutterBridgeHandler] = []
    
    var methodChannelName: String? {
        return "com.jjimmy.link_test_action"
    }
    
    var eventChannelName: String? {
        return "com.jimmy.link_test_event"
    }
    
    var streamHandler: FlutterEnvironmentStreamHandler?
    func registerMethodHandlers() {
        handlers = [
            SwiftFlutterBridgeHandler(methodName: "link_action_1", handler: { callback in
            callback.resolve(["link_action_1" : "native_ok"])
        }),
            SwiftFlutterBridgeHandler(methodName: "link_action_2", handler: { (param: LinkTestData, callback) in
                NSLog("[Link Tag] flutter notify native data:\(param.t1) ->\(param.t2)")
                let st = "[Link Tag] flutter notify native data:\(param.t1) ->\(param.t2)"
                callback.resolve(["link_action_2" : st])
            })
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.methodChannel?.invokeMethod("link_action_3", arguments: ["link_action_3": "link_action_3 notify ok"])
            if #available(iOS 10.0, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
                    self.streamHandler?.streamEvent?(["event": "yuyuiio"])
                })
            } else {
                // Fallback on earlier versions
            }
            
        }
        
        
    }
    
    func registerStreamHandlers() {
        
    }
}

