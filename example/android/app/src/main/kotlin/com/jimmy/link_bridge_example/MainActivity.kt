package com.jimmy.link_bridge_example

import com.jimmy.link_bridge.FlutterLinkChannelManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    init {
        FlutterLinkChannelManager.addChannel(TestChannel(this))
    }
}
