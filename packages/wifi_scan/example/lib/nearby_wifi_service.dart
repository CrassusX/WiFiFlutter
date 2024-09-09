import 'dart:async';

import 'package:get/get.dart';
import 'package:wifi_scan/wifi_scan.dart';

class GetNearbyWifiService extends GetxService {
  RxList<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[].obs;
  RxBool isLoading = false.obs; // 添加加载状态
  StreamSubscription<List<WiFiAccessPoint>>? _subscription;

  static GetNearbyWifiService get to => Get.find();

  Future<bool> onStartScan() async {
    // 扫描权限请求
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      // 开始扫描
      await WiFiScan.instance.startScan();
      accessPoints.clear();
      isLoading.value = true; // 开始加载

      // 监听扫描结果
      return await _startListening();
    } else {
      accessPoints.clear();
      isLoading.value = false;
      return false;
    }
  }

  void onCloseScan() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> _canGetScannedResults() async {
    final can = await WiFiScan.instance.canGetScannedResults();
    if (can != CanGetScannedResults.yes) {
      accessPoints.clear();
      return false;
    }
    return true;
  }

  Future<bool> _startListening() async {
    if (await _canGetScannedResults()) {
      // 数据变化
      _subscription =
          WiFiScan.instance.onScannedResultsAvailable.listen((points) {
        _updateWifi(points);
      });

      // 直接获取
      List<WiFiAccessPoint> points =
          await WiFiScan.instance.getScannedResults();
      _updateWifi(points);
      return true;
    } else {
      return false;
    }
  }

  _updateWifi(List<WiFiAccessPoint> points) {
    if (points.isNotEmpty) {
      accessPoints.assignAll(points);
      isLoading.value = false; // 加载完成
    }
  }
}
