import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_blue/flutter_blue.dart';
import 'package:synchronized/synchronized.dart';

class MainBleDiscovery {
  MainBleDiscovery(this._targetUuid) {
    _discoveredDevices = <BluetoothDevice>[];
    _flutterBlue = FlutterBlue.instance;

    // Register a listener which is called when ble devices are found.
    _flutterBlue.scanResults.listen((List<ScanResult> results) async {
      final Lock lock = Lock();
      await lock.synchronized(() {
        for (final ScanResult result in results) {
          // Find each found device
          for (final String serviceUuid
          in result.advertisementData.serviceUuids) {
            // Check the services of each device and compare if it is our device
            if (serviceUuid.toUpperCase() == _targetUuid) {
              _addDeviceToList(result.device);
            }
          }
        }
      });
    });
  }

  final String _targetUuid;
  late List<BluetoothDevice> _discoveredDevices;
  late FlutterBlue _flutterBlue;
  late Timer _scannerTimer;
  //discovery listener
  void _addDeviceToList(final BluetoothDevice device) {
    if (!_discoveredDevices.contains(device)) {
      _discoveredDevices.add(device);
      _discoveredDevices.sort((BluetoothDevice a, BluetoothDevice b) =>
          a.name.compareTo(b.name));
    }
  }

  void startDiscovery() {
    _scanDevices();
    _scannerTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      _scanDevices();
    });
  }

  void stopDiscovery() {
    _flutterBlue.stopScan();
    _scannerTimer.cancel();
  }

  Future<void> _scanDevices() async {
    await _flutterBlue.stopScan();

    _discoveredDevices = <BluetoothDevice>[];

    // Start scanning for 8 seconds
    developer.log('Start scanning bluetooth devices.',
        name: runtimeType.toString());

    developer.log('Start listing found bluetooth devices.',
        name: runtimeType.toString());
    await _flutterBlue.startScan(timeout: const Duration(seconds: 8));

    // Stop scanning
    developer.log('Stop scanning bluetooth devices.',
        name: runtimeType.toString());
    await _flutterBlue.stopScan();
  }

  List<BluetoothDevice> getList() {
    return _discoveredDevices;
  }
}