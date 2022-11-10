import 'dart:async';

import 'package:stream_webview_app/mdns_device_discovery/su_mdns_device_discovery.dart';
import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/objects/su_device.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_enum.dart';

class MultiroomMdnsDeviceProvider {
  MultiroomMdnsDeviceProvider(
      Function(List<Device> master, Map<String, List<Device>> slaveMap) func) {
    updateUI = func;
    mdnsDeviceDiscovery = MdnsDeviceDiscovery();
    multiroomMdnsDeviceDiscovery = MdnsDeviceDiscovery();

    master = <Device>[];
    slaveMap = <String, List<Device>>{};
  }

  late MdnsDeviceDiscovery mdnsDeviceDiscovery;
  late MdnsDeviceDiscovery multiroomMdnsDeviceDiscovery;
  late List<Device> master;
  late Map<String, List<Device>> slaveMap;
  late Function(List<Device> master, Map<String,
      List<Device>> slaveMap) updateUI;
  late Timer _updateUiTimer;

  void startScanning() {
    mdnsDeviceDiscovery.startDiscovery(bleServiceType);
    multiroomMdnsDeviceDiscovery.startDiscovery(multiRoomServiceType);

    _updateUiTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        generateMasterSlaveMap();
      }
    );
  }

  void stopScanning() {
    mdnsDeviceDiscovery.stopDiscovery();
    multiroomMdnsDeviceDiscovery.stopDiscovery();

    _updateUiTimer.cancel();
  }

  Future<void> generateMasterSlaveMap() async {
    final List<Device> foundDevices = await mdnsDeviceDiscovery.getDevices();
    final List<Device> foundMrDevices =
      await multiroomMdnsDeviceDiscovery.getDevices();

    master = <Device>[];
    slaveMap = <String, List<Device>>{};
    for (final Device device in foundDevices) {
      await _assignRoles(device, foundMrDevices);
    }
    // sort master and slave
    master.sort((Device a, Device b)
    => a.name!.compareTo(b.name!));
    for (final String key in slaveMap.keys) {
      slaveMap[key]!.sort((Device a, Device b)
      => a.name!.compareTo(b.name!));
    }
    // update ui
    updateUI(master, slaveMap);
  }

  Future<void> _assignRoles(Device device, List<Device> foundMrDevices) async {
    // assign the device to the master or slaveMap
    for (final Device mrDevice in foundMrDevices) {
      if (mrDevice.uuid == device.uuid) {
        // Either master and slave devices has to hold a TranscoderValue
        // to provide with the state related to the multi room function.
        device.transcoder = mrDevice.transcoder;
        if (mrDevice.transcoder == TranscoderValues.transcoderFalse) {
          await _moveDeviceToSlave(device);
          return;
        } else {
          master.add(device);
          return;
        }
      }
    }
    // if the device doesn't have the mulriroom function,
    // assign it to master
    master.add(device);
  }

  Future<void> _moveDeviceToSlave(Device slaveCand) async {
    // add to slave
    final String? masterId = await _getMasterId(slaveCand);

    if (masterId != null) {
      if (slaveMap[masterId] == null)
        slaveMap[masterId] = <Device>[];
      slaveCand.transcoder = TranscoderValues.transcoderFalse;

      slaveMap[masterId]?.add(slaveCand);
    }
  }

  Future<String?> _getMasterId(Device slave) async {
    final Map<String, dynamic> results =
    await NSDK.getRows(slave.ip!, multi_room_member_path, default_roles, 0, 0);
    if (results.isNotEmpty) {
      final String masterId =  results['rows']![0]!['value']!['groupingMember']!['master']!['id']! as String;
      return masterId;
    } else {
      return null;
    }
  }
}