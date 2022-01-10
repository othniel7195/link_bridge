package com.shuinfo.link_bridge

//
//  android
//  com.jimmy.link_bridge
//
//  Created by jimmy on 2022/1/9.
//

import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import org.json.JSONObject
import java.lang.Exception

class FlutterChannelError(val errorCode: Int, val errorMessage: String, val detail: Any?) {
    enum class ErrorCode(val value: Int) {
        functionCallInProgress(1000),
        argsInvalid(1001)
    }

    var userInfo = mutableMapOf<String, Any>()

    fun dictionaryRepresentation(): Map<String, Any> {
        var dict =
            mutableMapOf<String, Any>("errorCode" to errorCode, "errorMessage" to errorMessage)
        for (t in userInfo) {
            dict[t.key] = t.value
        }
        return dict
    }

    companion object {
        fun invalidParameter(error: Exception): FlutterChannelError {
            return FlutterChannelError(
                errorCode = ErrorCode.argsInvalid.value,
                errorMessage = "Invalid Parameter. $error",
                detail = null
            )
        }

        val functionCallInProgress = FlutterChannelError(
            errorCode = ErrorCode.functionCallInProgress.value,
            errorMessage = "Function call in progress, no reentrant allowed.",
            detail = null
        )
    }

}


private typealias FlutterChannelHandler = (String, Any?, MethodChannel.Result) -> Unit

class FlutterBridge {
    companion object {
        var handler: FlutterChannelHandler? = null
    }
}

class FlutterChannelCallback(var methodName: String, var result: MethodChannel.Result) {

    private var isInvalidated = false

    fun resolve(response: Map<String, Any>?) {
        if (isInvalidated) {
            return
        }
        isInvalidated = true
        if (response != null) {
            val resultString = response.toString()
            Log.d(
                "[Flutter Channel]",
                "FlutterChannelBridge $methodName resolve with result: $resultString"
            )
            result.success(resultString)
        } else {
            Log.d("[Flutter Channel]", "FlutterChannelBridge $methodName resolve with no result")
            result.success("")
        }
    }

    fun reject(error: FlutterChannelError) {
        if (isInvalidated) {
            return
        }
        isInvalidated = true
        val errorString = error.dictionaryRepresentation().toString()
        Log.d(
            "[Flutter Channel]",
            "FlutterChannelBridge $methodName reject with error: $errorString"
        )
        result.error(error.errorCode.toString(), errorString, error.detail)
    }

}


class KotlinFlutterBridgeHandler {
    private var isInvalidated = false
    private var methodName = ""

    constructor(methodName: String, handler: (FlutterChannelCallback) -> Unit) {
        this.methodName = methodName
        KotlinFlutterBridgeDispatcher.shared.addHandler(methodName, handler = { _, result ->
            Log.d("[Flutter Channel]", "call method $methodName")
            handler(FlutterChannelCallback(methodName, result))
        })
    }

    constructor(methodName: String, handler: (JSONObject, FlutterChannelCallback) -> Unit) {
        this.methodName = methodName
        KotlinFlutterBridgeDispatcher.shared.addHandler(methodName, handler = { params, result ->
            val callback = FlutterChannelCallback(methodName, result)
            val arg = params as? String
            if (arg != null) {
                try {
                    val obj = JSONObject(arg)
                    handler(obj, callback)
                } catch (e: JSONException) {

                    callback.reject(FlutterChannelError.invalidParameter(e))
                }
            } else {
                callback.reject(
                    FlutterChannelError(
                        FlutterChannelError.ErrorCode.argsInvalid.value,
                        errorMessage = "Invalid Parameter. Params needed but not found.",
                        detail = params
                    )
                )
            }
        })
    }

    fun invalidate() {
        if (isInvalidated) {
            return
        } else {
            isInvalidated = true
            KotlinFlutterBridgeDispatcher.shared.removeHandler(methodName)
        }
    }

}

private class KotlinFlutterBridgeDispatcher {
    companion object {
        val shared = KotlinFlutterBridgeDispatcher()
    }

    private var handlerDict = mutableMapOf<String, (Any?, MethodChannel.Result) -> Unit>()

    init {
        FlutterBridge.handler = { methodName, argString, result ->
            val handler = handlerDict[methodName]
            if (null != handler) {
                handler(argString, result)
            }
        }
    }

    fun addHandler(methodName: String, handler: (Any?, MethodChannel.Result) -> Unit) {
        handlerDict[methodName] = handler
    }

    fun removeHandler(methodName: String) {
        handlerDict.remove(methodName)
    }
}

class FlutterEnviromentStreamHandler : EventChannel.StreamHandler {
    var streamEvent: EventChannel.EventSink? = null
    var beginListenCallback: (() -> Unit)? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        streamEvent = events
        beginListenCallback?.let { it() }
    }

    override fun onCancel(arguments: Any?) {
    }

}