import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stream_webview_app/utils/su_ble_conststants.dart';

class BleDeviceController {
  BleDeviceController(this._bleDevice);

  final BluetoothDevice _bleDevice;

  late BluetoothCharacteristic? _writeButtonInput;

  Future<void> connectDevice(BuildContext context) async {
    await runZonedGuarded(
            () async {
          // Try to connect to the device
          await _bleDevice.connect(
              timeout: const Duration(milliseconds: 7000), autoConnect: false);
        },
            (Object error, StackTrace stack) {
          // If we can't connect to the device, go back and dismiss the loader
          EasyLoading.dismiss();
        }
    );

    // The bellow part is executed only if the connection was succeeded
    EasyLoading.dismiss();
    _processServices();
  }

  Future<void> executeFunction(int val) async {
    if (_writeButtonInput != null) {
      await _writeButtonInput!.write(convert.utf8.encode(val.toString()));
    }
  }

  Future<void> disconnectDevice() async {
    await _bleDevice.disconnect();
  }

  Future<void> _processServices() async {
    // Ble characteristics are assigned to the corresponding class params
    final List<BluetoothService> services = await _bleDevice.discoverServices();
    // ignore: avoid_function_literals_in_foreach_calls
    services.forEach((BluetoothService service) {
      // Check each service which is available and find the appropriate characteristics in it with UUID
      if (service.uuid.toString().toUpperCase() ==
          buttonFunctionServiceUuidString) {
        final List<BluetoothCharacteristic> characteristics =
            service.characteristics;
        for (final BluetoothCharacteristic characteristic in characteristics) {
          final String charUuid = characteristic.uuid.toString().toUpperCase();
          switch (charUuid) {
            case buttonFunctionExecuteUuidString:
              {
                _writeButtonInput = characteristic;
                break;
              }
            default:
              continue;
          }
        }
      }
    });
  }
}