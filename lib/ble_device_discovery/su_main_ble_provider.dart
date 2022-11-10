import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:stream_webview_app/ble_device_discovery/su_main_ble_discovery.dart';

class MainBleDeviceProvider {
  MainBleDeviceProvider(this._updateUi, String targetUuid) {
    mainBleDiscovery = MainBleDiscovery(targetUuid);

    devices = <BluetoothDevice>[];
  }

  final Function(List<BluetoothDevice> devices) _updateUi;
  late MainBleDiscovery mainBleDiscovery;
  late List<BluetoothDevice> devices;
  late Timer _updateUiTimer;

  void startScanning() {
    mainBleDiscovery.startDiscovery();

    _updateUiTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      setList();
    });
  }

  void stopScanning() {
    mainBleDiscovery.stopDiscovery();
    _updateUiTimer.cancel();
  }

  Future<void> setList() async {
    final List<BluetoothDevice> foundDevices = mainBleDiscovery.getList();
    _updateUi(foundDevices);
  }

}