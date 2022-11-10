import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stream_webview_app/multi_room_setting_page/su_multi_option_dialog.dart';
import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/objects/su_device.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_enum.dart';
import 'package:stream_webview_app/utils/su_global_config.dart';

enum GroupingMode {
  join,
  leave
}

class MultiRoomSettingHandler {
  MultiRoomSettingHandler() {
    _slaveCandidateDevices = <Device>[];
  }

  static MultiRoomSettingHandler? handler;
  late Device _master;
  late List<Device> _slaveCandidateDevices;

  // Singleton
  static MultiRoomSettingHandler getHandler(){
    handler ??= MultiRoomSettingHandler();
    return handler!;
  }

  Future<void> showOptionDialogAndConnect(Device master, List<Device> devices, BuildContext context) async {
    _master = master;
    setSlaveData(devices);
    final List<Device>? slaves =
      await MultiOptionDialog.showOptionDialog(
          context,'dialog.mr_dialog_title', _slaveCandidateDevices);
    await _sendConnectRequest(slaves);
    if (isGlobalMultiRoomButtonEnabled)
      Navigator.of(context).pop();
  }

  // Given the device list, this function stores the data of slave candidates
  void setSlaveData(List<Device> devices) {
    _slaveCandidateDevices.clear();
    for(final Device device in devices) {
      if (device.transcoder == TranscoderValues.transcoderTrue  && _master.uuid != device.uuid)
        _slaveCandidateDevices.add(device);
    }
  }

  Future<void> _sendConnectRequest(List<Device>? devices) async {
    for (final Device d in devices!) {
      await sendGroupiongRequest(d.ip!);
    }
  }

  Future<void> sendGroupiongRequest(String slaveIp) async {
    final Map<String, dynamic> groupingJason = _makeGroupingRequestJson(GroupingMode.join);
    await NSDK.setData(slaveIp, grouping_request_path,
        groupingJason, role: activate_roles, valueType: 'groupingRequest');
  }

  Future<void> sendUngroupingRequest(String slaveIp) async {
    final Map<String, dynamic> groupingJason = _makeGroupingRequestJson(GroupingMode.leave);
    await NSDK.setData(slaveIp, grouping_request_path,
        groupingJason, role: activate_roles, valueType: 'groupingRequest');
    EasyLoading.dismiss();
  }

  Map<String, dynamic> _makeGroupingRequestJson(GroupingMode mode) {
    final Map<String, dynamic> value = <String, dynamic>{};

    switch (mode) {
      case GroupingMode.join:
        value['command'] = 'join';
        break;
      case GroupingMode.leave:
        value['command'] = 'leave';
        break;
      default:
        break;
    }

    value['master'] = <String, String>{};
    if (mode == GroupingMode.join) {
      value['master']['id'] = _master.uuid;
      value['master']['name'] = _master.name;
      value['master']['ipAddress'] = _master.ip;
    }
    return value;
  }
}