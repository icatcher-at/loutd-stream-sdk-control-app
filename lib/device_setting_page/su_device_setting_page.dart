import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stream_webview_app/ble_device_discovery/su_main_ble_provider.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_ble_conststants.dart';
import 'package:stream_webview_app/utils/su_list_card.dart';

import 'su_ble_service_handler.dart';

class BleNetworkSettingPage extends StatefulWidget {
  const BleNetworkSettingPage({Key? key}) : super(key: key);

  @override
  _BleNetworkSettingPageState createState() => _BleNetworkSettingPageState();
}

class _BleNetworkSettingPageState extends State<BleNetworkSettingPage> {
  _BleNetworkSettingPageState() {
    _refreshController = RefreshController(initialRefresh: false);
    _bleDeviceProvider = MainBleDeviceProvider(_updateUi, wifiServiceUuidString);
    _bleDeviceProvider.startScanning();
    _availableDevices = <BluetoothDevice>[];
  }

  late BleServiceHandler _serviceHandler;
  late List<BluetoothDevice> _availableDevices;
  late RefreshController _refreshController;

  late MainBleDeviceProvider _bleDeviceProvider;

  void _updateUi(List<BluetoothDevice> devices) {
    setState(() {
      _availableDevices = devices;
    });
  }

  @override
  void dispose(){
    super.dispose();
    _bleDeviceProvider.stopScanning();
  }

  Future<void> _startBleSetup(
      BuildContext context, BluetoothDevice device) async {
    _serviceHandler = BleServiceHandler(device);
    _serviceHandler.startSetting(context);
  }

  Widget _loadingMessage() {
    return Container(
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(10.0),
      child: Text(translate('ble.loading'), style: const TextStyle(
          fontSize: 24
      ))
    );
  }

  Widget _myListView(BuildContext context) {
    return ListView.builder(
      itemCount: _availableDevices.length,
      itemBuilder: (BuildContext context, int index) {
        final Card child = Card(
            child: ListTile(
                leading: Icon(Icons.app_settings_alt_outlined,
                    color: SUAppStyle.streamUnlimitedGreen(), size: 56),
                title: Text(_availableDevices[index].name),
                subtitle: Text(translate('ble.card_navigation')),
                onTap: () =>
                    _startBleSetup(context, _availableDevices[index])));
        return SUListCard(child: child);
      },
    );
  }

  Widget _refresher(BuildContext context) {
    return SmartRefresher(
        enablePullDown: false,
        enablePullUp: false,
        onRefresh: _onRefresh,
        controller: _refreshController,
        child: _availableDevices.isNotEmpty ?
          _myListView(context) : _loadingMessage());
  }

  Future<void> _onRefresh() async {
    // await _getAvailableDevices();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(translate('ble.title')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            iconTheme: IconThemeData(color: SUAppStyle.streamUnlimitedGreen())),
        body: _refresher(context));
  }
}
