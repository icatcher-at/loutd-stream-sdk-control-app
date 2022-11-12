import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_webview_app/objects/su_device.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_enum.dart';
import 'package:stream_webview_app/utils/su_global_config.dart';
import 'package:synchronized/synchronized.dart';

import '../objects/su_device.dart';

class MdnsDeviceDiscovery {
  MdnsDeviceDiscovery() {
    mDnsDevices = <Device>[];
  }

  late List<Device> mDnsDevices;
  late BonsoirDiscovery _discovery;
  late Timer _scannerTimer;
  late Timer _checkTimer;
  late String _serviceType;

  void startDiscovery(String serviceType) {
    _serviceType = serviceType;

    _scanDevices();
    _scannerTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if(_discovery != null)
          _discovery.stop();
        _scanDevices(resetList: false);
      }
    );
    _checkTimer = Timer.periodic(const Duration(milliseconds: 3500), (Timer t)
    => <void>{
      // for master
      for (Device d in mDnsDevices) <void>{
        _pingDevice(d)
      }
    });
  }

  Future<void> _scanDevices({bool resetList = true}) async {
    // Once defined, we can start the discovery :
    _discovery = BonsoirDiscovery(type: _serviceType, printLogs: kDebugMode && enableMdnsLog);
    await _discovery.ready;
    await _discovery.start();
    // If you want to listen to the discovery :
    _discovery.eventStream?.listen((BonsoirDiscoveryEvent event) async {
      if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        if (enableMdnsLog)
          developer.log('Service found : ${event.service?.toJson()}',
            name: runtimeType.toString());
        _checkDevice(event);
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (enableMdnsLog)
          developer.log('Service lost : ${event.service?.toJson()}',
            name: runtimeType.toString());
        _removeDevice(_createDeviceFromEvent(event));
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolveFailed) {
        if (enableMdnsLog)
          developer.log('Service cannot resolved : ${event.service?.toJson()}',
            name: runtimeType.toString());
      } else {
        if (enableMdnsLog)
          developer.log('This event is not handled: ${event.type} !!!',
            name: runtimeType.toString());
      }
    });
  }

  void stopDiscovery() {
    // Stop scanning the device in the local network!
    _discovery.stop();
    // Stop counting time to execute task
    _scannerTimer.cancel();
    _checkTimer.cancel();
  }

  void _checkDevice(BonsoirDiscoveryEvent event) {
    // Generate a device object and check if the device should be displayed or not
    final Device device = _createDeviceFromEvent(event);
    // If the electric plug of the device is pulled out, the device doesn't have time
    // to unregister its service from the router
    // Therefore, check if the device is available by pining it
    _pingDevice(device);
  }

  Device _createDeviceFromEvent(BonsoirDiscoveryEvent event){
    final String? name = event.service?.attributes?['name'];
    final String? ip = event.service?.attributes!['ip'];
    final String? uuid = event.service?.attributes?['uuid'];
    final String? manufacturer = event.service?.attributes?['manufacturer'];
    final int? port = event.service?.port;
    String? model;
    if (event.service?.attributes?['model'] == null) {
      model =  DefaultModelName;
    } else {
      model = event.service?.attributes?['model'];
    }
    // Only for _suegrouping._tcp
    // if transcoder is true, the device has multiroom function and is a master
    // at this pont. if it is false, the device has multiroom function but it's
    // a slave at this pont. Otherwise, multiroom function is not available.
    final String? transcoder = event.service?.attributes?['transcoder'];

    if (transcoder == null) {
      return Device(port: port!, model: model, name: name, ip: ip, uuid: uuid,
          manufacturer: manufacturer, transcoder: TranscoderValues.disabled);
    } else {
      return Device(port: port!, model: model, name: name, ip: ip, uuid: uuid,
          manufacturer: manufacturer,
          transcoder: transcoder == 'true'? TranscoderValues.transcoderTrue :
          TranscoderValues.transcoderFalse);
    }
  }

  int _checkDeviceRegistered(Device device) {
    // Check if 'device' already exists in the master list
    // return -1 if the device isn't registered
    // and if a device is already registered, return its index
    for (int i = 0; i < mDnsDevices.length; i++) {
      if (mDnsDevices[i].uuid == device.uuid)
        return i;
    }

    return -1;
  }

  void cleanList() {
    final Map<String, Device> deviceMap = <String, Device>{};
    for (int i = 0; i < mDnsDevices.length; i++) {
      if (deviceMap[mDnsDevices[i].uuid!] == null)
        deviceMap[mDnsDevices[i].uuid!] = mDnsDevices[i];
    }

    final List<Device> newDeviceList = <Device>[];
    deviceMap.entries.forEach((MapEntry<String, Device> e) => newDeviceList.add(e.value));
    mDnsDevices = newDeviceList;
  }

  bool _checkDeviceChanged(Device device, int deviceIndex) {
    // Check if something in the device has changed or not.
    // name, ip, transcoder
    if (mDnsDevices[deviceIndex].name != device.name) {
      return true;
    }
    if (mDnsDevices[deviceIndex].ip != device.ip) {
      return true;
    }
    if (mDnsDevices[deviceIndex].transcoder != device.transcoder) {
      return true;
    }
    return false;
  }

  bool _checkDeviceIsStreamAmp(Device device) {
    return device.model == StreamAmpModelName;
  }

  Future<void> _pingDevice(Device device) async {
    // Ping device if it is reachable
    Socket.connect(device.ip, device.port, timeout: const Duration(seconds: 2))
        .then((Socket socket) async {
      // Add the device if it is not in the devices list
      final Lock lock = Lock();
      await lock.synchronized(() async {
        final int deviceIndex = _checkDeviceRegistered(device);
        if (deviceIndex == -1) {
          await device.performSubscribe();
          mDnsDevices.add(device);
        } else {
          final bool updateDevice = _checkDeviceChanged(device, deviceIndex);
          if (updateDevice) {
            mDnsDevices[deviceIndex] = device;
          }
        }
        cleanList();
      });
      socket.destroy();
    }).catchError((dynamic error) {
      _removeDevice(device);
    });
  }

  Future<List<Device>> getDevices() async {
    final Lock lock = Lock();
    List<Device> devList = <Device>[];
    await lock.synchronized(() async {
      devList = mDnsDevices;
    });
    return devList;
  }

  void _removeDevice(Device device) {
    if (_checkDeviceRegistered(device) != -1) {
      device.performUnsubscribe();
      mDnsDevices.remove(device);
    }
  }
}
