//
//  link_channel_test.dart
//  link_bridge
//
//  Created by jimmy on 2022/1/9.
//

import 'dart:convert';

import 'package:flutter/services.dart';

class LinkChannelTest {
  static const MethodChannel channel =
      MethodChannel('com.jjimmy.link_test_action');

  static const EventChannel echannel =
      EventChannel("com.jimmy.link_test_event");

  static Future<void> link_action_1() async {
    var r = await channel.invokeMethod('link_action_1');
    print(r);
  }

  static Future<void> link_action_2() async {
    var r = await channel.invokeMethod(
        'link_action_2', json.encode({"t1": "t1 hahah", "t2": "t2 yyt"}));
    print(r);
  }

  static void link_action_3() {
    channel.setMethodCallHandler(
      (call) async {
        print("link_action_3  callback ${call.method}  -> ${call.arguments}");
      },
    );
  }

  static void link_event() {
    echannel.receiveBroadcastStream().listen(
      (data) {
        print("link_event => $data");
      },
    );
  }
}
