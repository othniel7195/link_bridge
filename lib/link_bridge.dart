import 'dart:async';

import 'package:flutter/services.dart';

class LinkBridge {
  static const MethodChannel _channel = MethodChannel('link_bridge');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('linkBridgeTest');
    return version;
  }
}
