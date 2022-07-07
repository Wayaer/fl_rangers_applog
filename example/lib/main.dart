import 'dart:async';

import 'package:fl_rangers_applog/fl_rangers_applog.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: _HomePage()));

class _HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String sdkVersion = 'Unknown';
  String did = 'Unknown';
  String listenText = 'Unknown';
  String deviceId = 'Unknown';
  String abSdkVersion = 'Unknown';
  dynamic abConfigValue;
  Map<String, String>? allABConfigs;

  Future<void> _initAppLog() async {
    FlRangersAppLog.initialize("189693", "local_test");
    _getABTestConfigValueForKey();
    FlRangersAppLog.addHandler(onABTest: (value) {
      listenText = "onABTest=$value";
      setState(() {});
    }, onABTestVidsChanged: (List<String>? value) {
      listenText = "onABTestVidsChanged=$value";
      setState(() {});
    });
  }

  Future<void> _getDid() async {
    did = await FlRangersAppLog.getDeviceId() ?? 'Unknown';
    setState(() {});
  }

  Future<void> _getDeviceID() async {
    deviceId = await FlRangersAppLog.getDeviceId() ?? 'Unknown';
    setState(() {});
  }

  Future<void> _getAbSdkVersion() async {
    abSdkVersion = await FlRangersAppLog.getAbSdkVersion() ?? 'Unknown';
    setState(() {});
  }

  Future<void> _getAllAbTestConfig() async {
    allABConfigs = await FlRangersAppLog.getAllAbTestConfig();
    setState(() {});
  }

  Future<void> _getABTestConfigValueForKey() async {
    abConfigValue = await FlRangersAppLog.getABTestConfigValueForKey(
        'home_style', "ab_default_val");
    setState(() {});
  }

  static int uuid = 2020;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Fl Ranger AppLog example')),
        body: ListView(children: <Widget>[
          ListTile(title: Text("init AppLog $listenText"), onTap: _initAppLog),
          ListTile(
              title: Text("Test get device_id $deviceId"), onTap: _getDeviceID),
          ListTile(
              title: Text("Test get ab_sdk_version $abSdkVersion"),
              onTap: _getAbSdkVersion),
          ListTile(
              title: Text('getAllAbTestConfig $allABConfigs'),
              onTap: _getAllAbTestConfig),
          ListTile(
              title: Text("Test get abTestConfigValue $abConfigValue"),
              onTap: _getABTestConfigValueForKey),
          ListTile(
              title: const Text("Test onEventV3"),
              onTap: () {
                FlRangersAppLog.onEventV3(
                    "event_v3_name", {"key1": "value1", "key2": "value2"});
              }),
          ListTile(
              title: const Text("Test setHeaderInfo"),
              onTap: () {
                FlRangersAppLog.setHeaderInfo({
                  "header_key1": "header_value1",
                  "header_key2": "header_value2",
                });
              }),
          ListTile(
              title: const Text("Test removeHeaderInfo"),
              onTap: () {
                FlRangersAppLog.removeHeaderInfo("header_key1");
                FlRangersAppLog.removeHeaderInfo("header_key2");
              }),
          ListTile(
              title: const Text("Test setUserUniqueId"),
              onTap: () {
                FlRangersAppLog.setUserUniqueId(uuid.toString());
                uuid++;
              }),
          ListTile(title: Text("RangersApplog SDK Version $sdkVersion")),
          ListTile(title: Text("Test call did $did "), onTap: _getDid),
          ListTile(
              title: const Text("Test call eventV3 "),
              onTap: () {
                FlRangersAppLog.onEventV3("test_event", {"key": "value"});
              }),
        ]));
  }
}
