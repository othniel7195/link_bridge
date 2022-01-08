import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_bridge/link_bridge.dart';

void main() {
  const MethodChannel channel = MethodChannel('link_bridge');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LinkBridge.platformVersion, '42');
  });
}
