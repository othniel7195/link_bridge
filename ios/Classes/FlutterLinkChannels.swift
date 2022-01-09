//
//  FlutterLinkChannels.swift
//  link_bridge
//
//  Created by jimmy on 2022/1/9.
//

import Foundation

private var flutterLinkChannels = [FlutterChannelLink.Type]()

public class FlutterLinkChannelManger {
    
    public static func  addChannel(channel: FlutterChannelLink.Type) {
        flutterLinkChannels.append(channel)
    }
    
    public static func getAllChannel() -> [FlutterChannelLink.Type] {
        return flutterLinkChannels
    }
}
