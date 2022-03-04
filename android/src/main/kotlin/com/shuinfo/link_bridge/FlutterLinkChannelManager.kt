package com.shuinfo.link_bridge

//
//  android
//  com.jimmy.link_bridge
//
//  Created by jimmy on 2022/1/9.
//


class FlutterLinkChannelManager {
    companion object {
        private var flutterLinkChannels = mutableListOf<FlutterChannelLink>()
        fun addChannel(channel: FlutterChannelLink) {
            flutterLinkChannels.add(channel)
        }

        fun getAllChannel(): List<FlutterChannelLink> {
            return flutterLinkChannels
        }

        fun  clear(){
            flutterLinkChannels.clear()
        }
    }
}