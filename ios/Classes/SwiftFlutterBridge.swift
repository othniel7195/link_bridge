//
//  SwiftFlutterBridge.swift
//  link_bridge
//
//  Created by jimmy on 2022/1/7.
//

import Foundation

public struct FlutterChannelError: Error {
    enum ErrorCode: Int {
        case functionCallInProgress = 1000
        case argsInvalid = 1001
    }
    let errorCode: Int
    let errorMessage: String
    let detail: Any?
    var userInfo: [String: Any]
    public init(errorCode: Int, errorMessage: String, detail: Any?) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.detail = detail
        userInfo = [:]
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dict: [String: Any] = ["errorCode": errorCode, "errorMessage": errorMessage]
        for (key, value) in userInfo {
            dict[key] = value
        }
        return dict
    }
    
    public static func invalidParameter(error: Error) -> FlutterChannelError {
        return FlutterChannelError(errorCode: ErrorCode.argsInvalid.rawValue, errorMessage: "Invalid Parameter. \(error)", detail: nil)
    }
    public static let functionCallInProgress = FlutterChannelError(errorCode: ErrorCode.functionCallInProgress.rawValue,
                                                                   errorMessage: "Function call in progress, no reentrant allowed.", detail: nil)
}


public final class FlutterChannelCallback {
    private var methodName: String
    private var result: FlutterResult
    private(set) var isInvalidated = false
    
    fileprivate init(methodName: String, result: @escaping FlutterResult) {
        self.methodName = methodName
        self.result = result
    }
    
    public func resolve(_ response: Encodable? = nil) {
        resolve(response?.dictionaryRepresentation())
    }
    
    public func resolve(_ response: [String: Any]?) {
        guard !isInvalidated else { return }
        isInvalidated = true
        if let resultDict = response {
            let resultString = resultDict.stringify()
            debugPrint("[Flutter Channel] FlutterChannelBridge \(methodName) resolve with result: \(resultString)")
            result(resultString)
        } else {
            debugPrint("[Flutter Channel] FlutterChannelBridge \(methodName) resolve with no result")
            result("")
        }
    }
    
    public func reject(error: FlutterChannelError) {
        guard !isInvalidated else { return }
        isInvalidated = true
        let errorString = error.dictionaryRepresentation().stringify()
        debugPrint("[Flutter Channel] FlutterChannelBridge \(methodName) reject with error: \(errorString)")
        
        result(FlutterError(code: String(error.errorCode), message: error.errorMessage, details: error.detail))
    }
    
}

public final class SwiftFlutterBridgeHandler {
    private(set) var isInvalidated = false
    let methodName: String
    deinit {
        invalidate()
    }
    
    public init(methodName: String, handler: @escaping (FlutterChannelCallback) -> Void) {
        self.methodName = methodName
        
        SwiftFlutterBridgeDispatcher.shared.addHandler(methodName: methodName) { (_, result) in
            debugPrint("[Flutter Channel]  call method \(methodName)")
            handler(FlutterChannelCallback(methodName: methodName, result: result))
        }
    }
    
    public init<T: Decodable>(methodName: String, handler: @escaping (T, FlutterChannelCallback) -> Void) {
        self.methodName = methodName
        
        SwiftFlutterBridgeDispatcher.shared.addHandler(methodName: methodName) { (params, result) in
            debugPrint("[Flutter Channel]  call method \(methodName)")
            let callback = FlutterChannelCallback(methodName: methodName, result: result)
            guard let arg = (params as? String) else {
                callback.reject(error: FlutterChannelError(errorCode: FlutterChannelError.ErrorCode.argsInvalid.rawValue, errorMessage: "Invalid Parameter. Params needed but not found.", detail: params))
                return
            }
            do {
                let obj = try arg.mapJSONObject(T.self)
                handler(obj, callback)
            } catch {
                callback.reject(error: FlutterChannelError.invalidParameter(error: error))
            }
        }
    }
    
    func invalidate() {
        guard !isInvalidated else { return }
        isInvalidated = true
        SwiftFlutterBridgeDispatcher.shared.removeHandler(methodName: methodName)
    }
}

typealias FlutterChannelHandler = (String, Any?, @escaping FlutterResult) -> Void

class FlutterBridge {
    static var handler: FlutterChannelHandler? = nil
}

class SwiftFlutterBridgeDispatcher {
    static var shared: SwiftFlutterBridgeDispatcher = SwiftFlutterBridgeDispatcher()
    private var handlerDict: [String: (Any?, @escaping FlutterResult) -> Void] = [:]
    
    private init() {
        FlutterBridge.handler = { [weak self] methodName, argString, result in
            guard let self = self,
                  let handler = self.handlerDict[methodName] else {
                      return
                  }
            
            handler(argString, result)
        }
    }
    
    func addHandler(methodName: String, handler: @escaping (Any?, @escaping FlutterResult) -> Void) {
        handlerDict[methodName] = handler
    }
    
    func removeHandler(methodName: String) {
        handlerDict[methodName] = nil
    }
}

public class FlutterEnvironmentStreamHandler: NSObject, FlutterStreamHandler {
    
    public var streamEvent: FlutterEventSink?
    public var beginListenCallback: (() -> Void)? = nil
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        streamEvent = events
        beginListenCallback?()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
