package com.jimmy.link_bridge_example

import android.app.Activity
import com.shuinfo.link_bridge.FlutterChannelLink
import com.shuinfo.link_bridge.FlutterEnviromentStreamHandler
import com.shuinfo.link_bridge.KotlinFlutterBridgeHandler
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.concurrent.schedule
import kotlin.concurrent.timerTask

//
//  android
//  com.jimmy.link_bridge_example
//
//  Created by jimmy on 2022/1/9.
//
class TestChannel(val activity: Activity): FlutterChannelLink {

    private var  t = Timer()

    override var methodChannel: MethodChannel? = null
    override var eventChannel: EventChannel? = null
    override var handlers: List<KotlinFlutterBridgeHandler> = listOf<KotlinFlutterBridgeHandler>()
    override var methodChannelName: String?
        get() = "com.jjimmy.link_test_action"
        set(value) {}

    override var eventChannelName: String?
        get() = "com.jimmy.link_test_event"
        set(value) {}

    override var streamHandler: FlutterEnviromentStreamHandler? = null

    override fun registerMethodHandlers() {
        handlers = listOf(
            KotlinFlutterBridgeHandler("link_action_1", handler = { callback ->
                callback.resolve(mapOf("link_action_1" to "native_ok"))
        }),
            KotlinFlutterBridgeHandler("link_action_2", handler = { params, callback ->
                val st = "[Link Tag] flutter notify native data: $params"
                callback.resolve(mapOf("link_action_2" to st))
            })
        )

        Timer().schedule(10000) {
            activity.runOnUiThread {
                methodChannel?.invokeMethod("link_action_3", mapOf("link_action_3" to "link_action_3 notify ok"))
            }
        }

    }

    override fun registerStreamHandlers() {
        Timer().schedule(10000) {
            t.schedule(timerTask {
                activity.runOnUiThread {
                    streamHandler?.streamEvent?.success(mapOf("event" to "yuyuiio"))
                }

            }, Date(), 2000)
        }
    }
}