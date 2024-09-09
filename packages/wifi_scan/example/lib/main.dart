import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'nearby_wifi_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => GetNearbyWifiService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with AfterLayoutMixin {
  @override
  Future<void> afterFirstLayout(BuildContext context) async {}

  @override
  void dispose() {
    super.dispose();
    // GetNearbyWifiService.to.onCloseScan();
  }

  String? _ssid;

  _showNearbyWifi() async {
    bool openPermission = await GetNearbyWifiService.to.onStartScan();
    if (openPermission) {
      final ssid = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('附近的WiFi'),
            content: Obx(() {
              if (GetNearbyWifiService.to.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final accessPoints = GetNearbyWifiService.to.accessPoints;
              if (accessPoints.isEmpty) {
                return const Center(child: Text("没有可用的WiFi"));
              }
              return SizedBox(
                width: 300,
                height: 400,
                child: ListView.builder(
                  itemCount: accessPoints.length,
                  itemBuilder: (context, index) {
                    final accessPoint = accessPoints[index];
                    return ListTile(
                      title: Text(accessPoint.ssid.isNotEmpty
                          ? accessPoint.ssid
                          : "**EMPTY**"),
                      onTap: () {
                        Navigator.of(context).pop(accessPoint.ssid);
                      },
                    );
                  },
                ),
              );
            }),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  GetNearbyWifiService.to.onCloseScan();
                },
                child: const Text('关闭'),
              ),
            ],
          );
        },
      );
      if (ssid != null) {
        setState(() {
          _ssid = ssid;
        });
      }
    } else {
      print("权限开启失败！");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _ssid ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNearbyWifi,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
