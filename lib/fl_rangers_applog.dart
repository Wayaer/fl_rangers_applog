import 'dart:async';

import 'package:flutter/services.dart';

class FlRangersAppLog {
  FlRangersAppLog._();

  static const MethodChannel _channel =
      const MethodChannel('com.fl.rangers.app.log');

/* 提示：可以到[Rangers官网](https://datarangers.com.cn/)查看更详细的文档
 * Note: Refer to more detailed docs at https://datarangers.com/
*/

  /// Init SDK，expected to be called as early as possible.
  /// Note: You can also choose to init SDK in native side (say, using Java or Objective-C). If so, this method is not expected to be called.
  /// @param appid  String AppID of Rangers.
  /// @param channel  String.
  /// @host private report URL. e.g. https://myprivateurl.com/ Pass `null` if you dont know what this is.
  /// Usage：(replace 123456 with your appid)
  /// FlRangersAppLogPlugin.initRangersAppLog('123456','test_channel', true, true, false, null);
  static void initRangersAppLog(String appid, String channel, bool enableAb,
      bool enableEncrypt, bool enableLog, String? host) {
    assert(appid.isNotEmpty);
    assert(channel.isNotEmpty);
    _channel.invokeMethod('initRangersAppLog', {
      "appid": appid,
      "channel": channel,
      "enable_ab": enableAb,
      "enable_encrypt": enableEncrypt,
      "enable_log": enableLog,
      "host": host
    });
    FlRangersAppLogEvent.init();
  }

  /// get device_id
  /// @returns device_id
  /// Usage：
  /// String value = await FlRangersAppLogPlugin.getDeviceId();
  static Future<String?> getDeviceId() async {
    return await _channel.invokeMethod('getDeviceId');
  }

  /* AB Test */

  /// get ab_sdk_version
  /// @returns ab_sdk_version
  /// Usage：
  /// String value = await FlRangersAppLogPlugin.getAbSdkVersion();
  static Future<String?> getAbSdkVersion() async {
    return await _channel.invokeMethod('getAbSdkVersion');
  }

  /// get all ab config
  /// This method will not trigger exposure.
  /// Note: Only avaliable on iOS!
  /// Usage example：
  /// Map<dynamic, dynamic> d = await FlRangersAppLogPlugin.getAllAbTestConfig();
  static Future<Map<dynamic, dynamic>?> getAllAbTestConfig() async {
    return await _channel.invokeMethod('getAllAbTestConfig');
  }

  /// get the abConfigValue of the corresponding `key`
  /// @param key  String
  /// @returns corresponding abConfigValue
  /// Usage：
  /// String value = await FlRangersAppLogPlugin.getABTestConfigValueForKey('ab_test_key');
  static Future<dynamic> getABTestConfigValueForKey(
      String key, dynamic defaultValue) async {
    return await _channel.invokeMethod(
        'getABTestConfigValueForKey', {'key': key, 'default': defaultValue});
  }

  /// track events
  /// @param eventName  String
  /// @param params Map<String, dynamic> event properties
  /// Usage：
  /// FlRangersAppLogPlugin.onEventV3('flutter_start',{'key1':'value1','key2':'value2'});
  static void onEventV3(String eventName, Map<String, dynamic>? params) {
    _channel.invokeMethod("onEventV3", {'event': eventName, 'param': params});
  }

  /* Login and Logout */

  /// set user_unique_id
  /// @param userUniqueID String Pass the userID you want to log in. Pass `null` to log out.
  /// Usage：
  /// FlRangersAppLogPlugin.setUserUniqueId('123');
  static void setUserUniqueId(String? userUniqueID) {
    _channel.invokeMethod('setUserUniqueId', {'uuid': userUniqueID});
  }

  /* Custom Header */

  /// custom header info
  /// @param params Map<String, dynamic> header信息.
  /// Usage：
  /// FlRangersAppLogPlugin.setHeaderInfo({'key1':'value1','key2':'value2'});
  static void setHeaderInfo(Map<String, dynamic> customHeader) {
    _channel.invokeMethod("setHeaderInfo", {'customHeader': customHeader});
  }

  static void removeHeaderInfo(String key) {
    _channel.invokeMethod('removeHeaderInfo', {'key': key});
  }

  /* Profile */
  static void profileSet(Map<String, dynamic> profileDict) {
    _channel.invokeMethod('profileSet', {'profileDict': profileDict});
  }

  static void profileSetOnce(Map<String, dynamic> profileDict) {
    _channel.invokeMethod('profileSetOnce', {'profileDict': profileDict});
  }

  static void profileUnset(String key) {
    _channel.invokeMethod('profileUnset', {'key': key});
  }

  static void profileIncrement(Map<String, dynamic> profileDict) {
    _channel.invokeMethod('profileIncrement', {'profileDict': profileDict});
  }

  static void profileAppend(Map<String, dynamic> profileDict) {
    _channel.invokeMethod('profileAppend', {'profileDict': profileDict});
  }

  /// Sets up a broadcast stream for receiving ABTestConfig events.
  /// May receive multiple events.
  /// You can get the latest ABTestConfig by [getABTestConfigValueForKey].
  static Stream<void> receiveABTestConfigStream() {
    return FlRangersAppLogEvent.receiveABTestConfigStream();
  }

  /// Sets up a broadcast stream for receiving ABVidsChange events.
  /// Triggered when ABTest is exposed
  static Stream<void> receiveABVidsChangeStream() {
    return FlRangersAppLogEvent.receiveABVidsChangeStream();
  }
}

class FlRangersAppLogEvent {
  FlRangersAppLogEvent._();

  static const EventChannel _eventChannel =
      const EventChannel("com.fl.rangers.app.log/event");

  static late Stream _eventChannelStream;
  static late Stream _abTestConfigStream;
  static late Stream _abVidsChangeStream;
  static bool _init = false;

  static init() {
    _ensureInit();
  }

  static dispose() {}

  static _ensureInit() {
    if (!_init) {
      _eventChannelStream = _eventChannel.receiveBroadcastStream();
      _abTestConfigStream = _eventChannelStream.where((event) {
        return event == "onABTestSuccess";
      });
      _abVidsChangeStream = _eventChannelStream.where((event) {
        return event == "onABTestVidsChanged";
      });
      _init = true;
    }
  }

  static Stream<dynamic> receiveABTestConfigStream() {
    _ensureInit();
    return _abTestConfigStream;
  }

  static Stream<dynamic> receiveABVidsChangeStream() {
    _ensureInit();
    return _abVidsChangeStream;
  }
}
