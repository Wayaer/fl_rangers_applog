import 'dart:async';

import 'package:flutter/services.dart';

typedef ABTestCallback = void Function(dynamic value);
typedef AbVidChangeCallback = void Function(List<String>? value);

class FlRangersAppLog {
  FlRangersAppLog._();

  static const MethodChannel _channel = MethodChannel('com.fl.rangers.app.log');

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
  static Future<bool?> initialize(String appId, String channel,
      {bool enableAb = false,
      bool enableEncrypt = false,
      bool enableLog = false,
      String? host}) {
    assert(appId.isNotEmpty);
    assert(channel.isNotEmpty);
    final arg = {
      "appId": appId,
      "channel": channel,
      "enable_ab": enableAb,
      "enable_encrypt": enableEncrypt,
      "enable_log": enableLog,
      "host": host
    };
    return _channel.invokeMethod('initialize', arg);
  }

  static void addHandler({
    ABTestCallback? onABTestSuccess,
    AbVidChangeCallback? onABTestVidsChanged,
  }) {
    _channel.setMethodCallHandler(null);
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onABTestSuccess':
          onABTestSuccess?.call(call.arguments);
          break;
        case 'onABTestVidsChanged':
          onABTestVidsChanged?.call(call.arguments);
          break;
      }
    });
  }

  /// get device_id
  /// @returns device_id
  /// Usage：
  /// String value = await FlRangersAppLogPlugin.getDeviceId();
  static Future<String?> getDeviceId() => _channel.invokeMethod('getDeviceId');

  /* AB Test */

  /// get ab_sdk_version
  /// @returns ab_sdk_version
  /// Usage：
  /// String value = await FlRangersAppLogPlugin.getAbSdkVersion();
  static Future<String?> getAbSdkVersion() =>
      _channel.invokeMethod('getAbSdkVersion');

  /// get all ab config
  /// This method will not trigger exposure.
  /// Note: Only avaliable on iOS!
  /// Usage example：
  /// Map<String, String> d = await FlRangersAppLogPlugin.getAllAbTestConfig();
  static Future<Map<dynamic, dynamic>?> getAllAbTestConfig() =>
      _channel.invokeMethod<Map<dynamic, dynamic>?>('getAllAbTestConfig');

  /// get the abConfigValue of the corresponding `key`
  /// @param key  String
  /// @returns corresponding abConfigValue
  /// Usage：
  /// String value = await FlRangersAppLogPlugin.getABTestConfigValueForKey('ab_test_key');
  static Future<String?> getABTestConfigValueForKey(
          String key, String defaultValue) =>
      _channel.invokeMethod(
          'getABTestConfigValueForKey', {'key': key, 'default': defaultValue});

  /// track events
  /// @param eventName  String
  /// @param params Map<String, dynamic> event properties
  /// Usage：
  /// FlRangersAppLogPlugin.onEventV3('flutter_start',{'key1':'value1','key2':'value2'});
  static Future<bool?> onEventV3(
          String eventName, Map<String, String>? params) =>
      _channel.invokeMethod("onEventV3", {'event': eventName, 'param': params});

  /* Login and Logout */

  /// set user_unique_id
  /// @param userUniqueID String Pass the userID you want to log in. Pass `null` to log out.
  /// Usage：
  /// FlRangersAppLogPlugin.setUserUniqueId('123');
  static Future<bool?> setUserUniqueId(String userUniqueID) =>
      _channel.invokeMethod('setUserUniqueId', userUniqueID);

  /* Custom Header */

  /// custom header info
  /// @param params Map<String, dynamic> header信息.
  /// Usage：
  /// FlRangersAppLogPlugin.setHeaderInfo({'key1':'value1','key2':'value2'});
  static Future<bool?> setHeaderInfo(Map<String, String> customHeader) =>
      _channel.invokeMethod("setHeaderInfo", customHeader);

  static Future<bool?> removeHeaderInfo(String key) =>
      _channel.invokeMethod('removeHeaderInfo', key);

// /* Profile */
// static Future<bool?> profileSet(Map<String, String> profileDict) =>
//     _channel.invokeMethod('profileSet', profileDict);
//
// static Future<bool?> profileSetOnce(Map<String, String> profileDict) =>
//     _channel.invokeMethod('profileSetOnce', profileDict);
//
// static Future<bool?> profileUnset(String key) =>
//     _channel.invokeMethod('profileUnset', key);
//
// static Future<bool?> profileIncrement(Map<String, String> profileDict) =>
//     _channel.invokeMethod('profileIncrement', profileDict);
//
// static Future<bool?> profileAppend(Map<String, String> profileDict) =>
//     _channel.invokeMethod('profileAppend', profileDict);
}
