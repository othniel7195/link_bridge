package com.jimmy.link_bridge

import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

//
//  android
//  com.jimmy.link_bridge
//
//  Created by jimmy on 2022/1/9.
//

interface FlutterChannelLink {
    var handlers: List<KotlinFlutterBridgeHandler>
    var methodChannel: MethodChannel?
    var methodChannelName: String?
    var eventChannel: EventChannel?
    var eventChannelName: String?
    var streamHandler: FlutterEnviromentStreamHandler?

    fun registerStreamHandlers()
    fun registerMethodHandlers()
    fun setup(binaryMessenger: BinaryMessenger) {
        if (methodChannelName == null && eventChannelName == null) {
            throw IllegalArgumentException("MethodChannelName and eventChannelName cannot be empty at the same time!")
        }
        val methodChannelName = methodChannelName
        if (methodChannelName != null) {
            methodChannel = MethodChannel(binaryMessenger, methodChannelName)
            registerMethodHandlers()
            methodChannel?.setMethodCallHandler { call, result ->
                Log.d("[Flutter Channel]", "Channel: \\(methodChannelName) method: ${call.method} and arguments: ${call.arguments}")
                callHandlers(call, result)
            }
        }

        val eventChannelName = eventChannelName
        if (eventChannelName != null) {
            streamHandler = FlutterEnviromentStreamHandler()
            if(streamHandler != null) {
                eventChannel = EventChannel(binaryMessenger, eventChannelName)
                eventChannel?.setStreamHandler(streamHandler)
                registerStreamHandlers()
            } else {
                throw IllegalArgumentException("StreamHandler can not be nil.")
            }
        }

    }
    fun clearData() {}
    fun channelWillUnregister() {
        handlers.forEach { it.invalidate() }
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }

    private fun callHandlers(call: MethodCall, result: MethodChannel.Result) {
        val handler = FlutterBridge.handler
        if (handler != null) {
            handler(call.method, call.arguments, result)
        }
    }
}

