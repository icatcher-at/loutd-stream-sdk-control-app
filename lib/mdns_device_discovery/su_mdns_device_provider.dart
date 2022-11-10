import 'dart:async';

import 'package:stream_webview_app/mdns_device_discovery/su_mdns_device_discovery.dart';
import 'package:stream_webview_app/objects/su_device.dart';

class MdnsDeviceProvider {
  MdnsDeviceProvider(
      Function(List<Device> devices) func,
      String mdnsServiceType) {
    updateUI = func;
    serviceType = mdnsServiceType;
    mdnsDeviceDiscovery = MdnsDeviceDiscovery();

    devices = <Device>[];
  }

  late MdnsDeviceDiscovery mdnsDeviceDiscovery;
  late List<Device> devices;
  late Function(List<Device> devices) updateUI;
  late Timer _updateUiTimer;
  late String serviceType;

  void startScanning() {
    mdnsDeviceDiscovery.startDiscovery(serviceType);

    _updateUiTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        generateList();
      }
    );
  }

  void stopScanning() {
    mdnsDeviceDiscovery.stopDiscovery();

    _updateUiTimer.cancel();
  }

  Future<void> generateList() async {
    final List<Device> foundDevices = await mdnsDeviceDiscovery.getDevices();
    updateUI(foundDevices);
  }
}