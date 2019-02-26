import 'dart:async';

import 'package:flutter/services.dart';

class FlutterOpenNative {
  static const MethodChannel _channel =
      const MethodChannel('flutter_open_native');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> test() async {
    final String testString = await _channel.invokeMethod("test");
    return testString;
  }

  static Future<String> openWebView() async {
    final String result = await _channel.invokeMethod("open_webview");
    return result;
  }

  static Future<String> ping() async {
    final String result = await _channel.invokeMethod("ping");
    return result;
  }
}
