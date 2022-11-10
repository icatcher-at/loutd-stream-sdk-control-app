import 'dart:async';
import 'dart:convert' as convert;
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/device_setting_page/su_softap_page.dart';
import 'package:stream_webview_app/device_setting_page/su_wifi_page.dart';
import 'package:stream_webview_app/objects/su_wifi.dart';
import 'package:stream_webview_app/utils/su_alert_dialog.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_encryption.dart';
import 'package:stream_webview_app/utils/su_enum.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../objects/su_soft_ap.dart';
import '../utils/su_action_dialog.dart';
import '../utils/su_ble_conststants.dart';


class BleServiceHandler {
  BleServiceHandler(this._bleDevice) {
    _connCheckCount = 0;
    // If this object is generated, the app is connected to the device
  }

  final BluetoothDevice _bleDevice;
  late int _connCheckCount;
  late List<Wifi>? _wifiList;
  late List<SoftAp>? _softApList;
  late String? _pubKey;
  late BuildContext? _context;

  late BluetoothCharacteristic? _readWifiList;
  late BluetoothCharacteristic? _readWifiState;
  late BluetoothCharacteristic? _readPubKey;
  late BluetoothCharacteristic? _writeOffset;
  late BluetoothCharacteristic? _writeWifiConnection;
  BluetoothCharacteristic? _writeConnectionStart;

  Function()? _onWifiConnected;

  Future<void> _processServices() async {
    // Ble characteristics are assigned to the corresponding class params
    final List<BluetoothService> services = await _bleDevice.discoverServices();
    // ignore: avoid_function_literals_in_foreach_calls
    services.forEach((BluetoothService service) {
      // Check each service which is available and find the appropriate characteristics in it with UUID
      if (service.uuid.toString().toUpperCase() == wifiServiceUuidString
          || service.uuid.toString().toUpperCase() == wifiAmpServiceUuidString
      ) {
        final List<BluetoothCharacteristic> characteristics =
            service.characteristics;
        for (final BluetoothCharacteristic characteristic in characteristics) {
          final String charUuid = characteristic.uuid.toString().toUpperCase();
          switch (charUuid) {
            case wifiCharWifiListUuidString:
              {
                _readWifiList = characteristic;
                break;
              }
            case wifiCharPublicKeyUuidString:
              {
                _readPubKey = characteristic;
                break;
              }
            case wifiCharConnectStatusUUIDString:
              {
                developer.log(
                    '==================== connect to status UUID =======================',
                    name: 'BleServiceHandler');
                _readWifiState = characteristic;
                break;
              }

            case wifiCharReadOffsetUuidString:
              {
                _writeOffset = characteristic;
                break;
              }
            case wifiConnectionStartUuidString:
              {
                _writeConnectionStart = characteristic;
                break;
              }
            case wifiCharConnectReqUUIDString:
              {
                _writeWifiConnection = characteristic;
                break;
              }
            default:
              continue;
          }
        }
      }
    });
  }

  Future<void> _updateWifiState() async {
    final List<int> val = await _readWifiState!.read();
    final String wifiStateJson = convert.utf8.decode(val);
    final String wifiState =
        // ignore: avoid_dynamic_calls
        convert.json.decode(wifiStateJson)['id'].toString();

    _onUpdateWifiState(wifiState);
  }

  Future<void> _onUpdateWifiState(String wifiState) async {
    developer.log(wifiState);
    developer.log(_connCheckCount.toString());
    switch (wifiState) {
      case wifiStateIdle:
        break; // Do nothing

      case wifiStateConnecting:
        _setSetupState(BleSetupState.settingWifi);
        break;

      case wifiStateConnected:
        {
          _setSetupState(BleSetupState.finished);
          break;
        }
      case wifiStateDisconnected:
        _setSetupState(BleSetupState.settingWifi);
        break;

      case wifiStatePasswordNotCorrect:
        _setSetupState(BleSetupState.waitingUserInput);
        SUAlertDialog.showAlertDialog(_context!, translate('ble.errors.title'),
            translate('ble.errors.password'));
        break;
      case wifiStateNetworkNotFound:
        _setSetupState(BleSetupState.waitingUserInput);
        SUAlertDialog.showAlertDialog(_context!, translate('ble.errors.title'),
            translate('ble.errors.network'));
        break;
      case wifiStateJsonError:
        _setSetupState(BleSetupState.waitingUserInput);
        SUAlertDialog.showAlertDialog(_context!, translate('ble.errors.title'),
            translate('ble.errors.json'));
        break;

      default:
        break;
    }
  }

  Future<void> _setSetupState(BleSetupState state) async {
    switch (state) {
      case BleSetupState.connected:
        {
          developer.log('========== enter connected state ==========',
              name: 'BleServiceHandler');
        }
        break;

      case BleSetupState.fetchPubKey:
        {
          developer.log('========== enter fetchPubKey state ==========',
              name: 'BleServiceHandler');
          _pubKey = convert.utf8.decode(await _readPubKey!.read());
          await _setSetupState(BleSetupState.fetchWifiList);
        }
        break;

      case BleSetupState.fetchWifiList:
        {
          developer.log('========== enter fetchWifiList state ==========',
              name: 'BleServiceHandler');
          _wifiList = await readWifiLists();
          await _setSetupState(BleSetupState.waitingUserInput);
          Navigator.of(_context!).push(_goToList());
        }
        break;

      case BleSetupState.waitingUserInput:
        {
          developer.log('========== enter waitingUserInput state ==========',
              name: 'BleServiceHandler');
          EasyLoading.dismiss();
        }
        break;

      case BleSetupState.settingWifi:
        {
          developer.log('========== enter settingWifi state ==========',
              name: 'BleServiceHandler');
          if (!EasyLoading.isShow)
            EasyLoading.show(
                status: translate('load.loading'),
                maskType: EasyLoadingMaskType.black);
          if (_connCheckCount > 80) {
            _setSetupState(BleSetupState.waitingUserInput);
            return;
          }
          _updateWifiState();
          _connCheckCount++;
        }
        break;

      case BleSetupState.disconnected:
      case BleSetupState.finished:
        {
          developer.log(
              '========== enter disconnected/finished state ==========',
              name: 'BleServiceHandler');
          EasyLoading.dismiss();
          if(_onWifiConnected != null) {
            _onWifiConnected!();
          }
          _disconnectAndBack();
        }
        break;
    }
  }

  void _disconnectAndBack() {
    _bleDevice.disconnect();
    //Go to home
    int count = 0;
    Navigator.of(_context!).popUntil((_) => count++ >= 1);
  }

  Future<List<Wifi>> readWifiLists() async {
    // Using the assigned characteristic, available wifi will be extracted
    int count = -1;
    int i = 0;
    String extractedWifiList = '';

    while (count != extractedWifiList.length) {
      // Read one line, set the offset to the next line, and read the new line...
      count = extractedWifiList.length;
      await _writeOffset!.write(convert.utf8.encode(i.toString()));
      final List<int> wifiData = await _readWifiList!.read();
      extractedWifiList += convert.utf8.decode(wifiData);
      i++;
    }
    print(extractedWifiList);
    final Map<String, dynamic> val =
        convert.jsonDecode(extractedWifiList) as Map<String, dynamic>;
    return makeWifiList(val['wifiList']! as List<dynamic>);
  }

  List<Wifi> makeWifiList(List<dynamic> data) {
    final List<Wifi> wifiObjList = <Wifi>[];
    for (int i = 0; i < data.length; i++) {
      final Map<String, dynamic> element = data[i] as Map<String, dynamic>;
      final Wifi wifiObj = Wifi(
          element['ssid']!.toString(),
          element['encryption']!.toString(),
          element['rssi']! as int,
          element['frequency']! as int);
      wifiObjList.add(wifiObj);
    }
    return wifiObjList;
  }

  Future<void> readPubKey() async {
    // List<int> byteKey = await _readPubKey.read();
    // return convert.utf8.decode(byteKey);
    await _setSetupState(BleSetupState.fetchPubKey);
  }

  Future<void> writeWifiConnection(String wifiConfig) async {
    final List<int> sentData = convert.utf8.encode(wifiConfig);
    await _writeWifiConnection!.write(sentData);
  }

  Future<void> _onConnectingWifi(Wifi wifiObj, String password) async {
    final Map<String, dynamic> wifiConfig = <String, dynamic>{
      'ssid': wifiObj.ssid,
      'encryption': wifiObj.encryption,
      'password': password,
      'stopAdvertisingOnSuccess': true
    };
    // Convert the data to json
    final String wifiConfigJson = convert.jsonEncode(wifiConfig);
    // And encrypt it with the provided RSA key
    final Uint8List encryptedWifiConfig = SUEncryption.rsaBleEnctypt(
        _pubKey!, Uint8List.fromList(convert.utf8.encode(wifiConfigJson)));

    // this.writeWifiConnection(encryptedWifiConfig);
    await _writeWifiConnection!.write(encryptedWifiConfig);

    _connCheckCount = 0;
    _setSetupState(BleSetupState.settingWifi);
  }

  Future<void> _onConnectingSoftAp(SoftAp softApObj) async {
    await WiFiForIoTPlugin.connect(softApObj.ssid, withInternet: false, joinOnce: false);
    WiFiForIoTPlugin.forceWifiUsage(true);
  }

  Future<List<SoftAp>> getSoftApList() async {
    final List<WifiNetwork> softAps = await WiFiForIoTPlugin.loadWifiList();
    final List<SoftAp> softApObjList = <SoftAp>[];
    for (final WifiNetwork softApObj in softAps) {
      final SoftAp lSoftApObj = SoftAp(
          softApObj.ssid!.toString(),
          softApObj.level!,
          softApObj.frequency!);
      softApObjList.add(lSoftApObj);
    }
    return softApObjList;
  }

  Future<void> connectToSoftAp() async {
    _softApList = await getSoftApList();
    Navigator.of(_context!).push(_goToSoftApList());
  }

  Future<void> startSetting(BuildContext context, {Function()? onDoneFunc}) async {
    if (onDoneFunc != null) {
      _onWifiConnected = onDoneFunc;
    }

    _context = context;
    developer.log('Connect to the selected device.',
        name: runtimeType.toString());
    EasyLoading.show(
        status: translate('load.loading'),
        maskType: EasyLoadingMaskType.black);
    await _bleDevice.disconnect();
    try {
      await _bleDevice.connect(autoConnect: false).timeout(const Duration(seconds: 30));
      await _setSetupState(BleSetupState.connected);
      await _processServices();
      await _setSetupState(BleSetupState.fetchPubKey);
      if (_writeConnectionStart != null) {
        _writeConnectionStart!.write(convert.utf8.encode('connected'));
      }
    } catch (timeOutException) {
      EasyLoading.dismiss();
      if (Platform.isAndroid) {
        SUActionDialog.showActionDialog(context, translate('softap.title'), translate('softap.description'), connectToSoftAp, actionButtonText: 'softap.connect');
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _disConnectDevice(Function() onComplete) async {
    await _bleDevice.disconnect();
    onComplete();
  }

  Route<SUWifiPage> _goToList() {
    return PageRouteBuilder<SUWifiPage>(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          SUWifiPage(
              wifiList: _wifiList!,
              onPressedAction: _onConnectingWifi,
              disconnectDevice: _disConnectDevice,
          ),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return child;
      },
    );
  }

  Route<SUSoftApPage> _goToSoftApList() {
    return PageRouteBuilder<SUSoftApPage>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
          SUSoftApPage(
              softApList: _softApList!,
              onPressedAction: _onConnectingSoftAp
              ),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return child;
      },
    );
  }
}
