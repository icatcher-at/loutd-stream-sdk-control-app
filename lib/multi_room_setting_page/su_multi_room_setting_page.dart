import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stream_webview_app/mdns_device_discovery/su_mdns_device_provider.dart';
import 'package:stream_webview_app/multi_room_setting_page/su_multi_room_setting_handler.dart';
import 'package:stream_webview_app/objects/su_device.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_list_card.dart';

import '../objects/su_device.dart';

class MultiRoomSettingPage extends StatefulWidget {
  const MultiRoomSettingPage({Key? key}) : super(key: key);

  @override
  _MultiRoomSettingPageState createState() => _MultiRoomSettingPageState();
}

class _MultiRoomSettingPageState extends State<MultiRoomSettingPage> {

  late MultiRoomSettingHandler _handler;
  late BuildContext _context;
  late MdnsDeviceProvider _devicesProvider;
  late List<Device> devices;
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);

    _devicesProvider = MdnsDeviceProvider(updateUi, multiRoomServiceType);
    _devicesProvider.startScanning();
    devices = <Device>[];

    _handler = MultiRoomSettingHandler.getHandler();
  }

  void updateUi(List<Device> devicesCand) {
    setState(() {
      devices = devicesCand;
    });
    if (EasyLoading.isShow)
      EasyLoading.dismiss();
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _devicesProvider.stopScanning();
  }

  Widget cardMDnsLayout(Device device) {
    return Column(children: <Widget>[
      ListTile(
        leading: Icon(Icons.devices_other_rounded,
            color: SUAppStyle.streamUnlimitedGreen(), size: 64),
        title: Text(device.name!),
        subtitle: Text(device.ip!),
        onTap: () => _onTapFunction(device),
      )
    ]);
  }

  Future<void> _onTapFunction(Device master) async {
    _handler.showOptionDialogAndConnect(master, devices, _context);
  }

  Widget _customScroller(BuildContext context) {
    return Column(children: <Widget>[
      refresher(context)
    ]);
  }

  Widget _deviceListView(BuildContext context) {
    // Provide a ListView for discovered Devices
    return ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          final Widget child = Card(child: cardMDnsLayout(devices[index]));
          return SUListCard(child: child);
        });
  }

  Widget _loadingMessage() {
    return Container(
        margin: const EdgeInsets.all(30.0),
        padding: const EdgeInsets.all(10.0),
        child: Text(translate('multi_room.loading'), style: const TextStyle(
            fontSize: 24
        ))
    );
  }

  Widget refresher(BuildContext context) {
    // Provide a refresher Widget which refreshes the device list by pulling it down
    return Flexible(
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: false,
          onRefresh: _onRefresh,
          controller: _refreshController,
          child: devices.isNotEmpty ?
            _deviceListView(context) : _loadingMessage()
        ));
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(translate('multi_room.title')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            iconTheme: IconThemeData(color: SUAppStyle.streamUnlimitedGreen())),
        body: _customScroller(context)// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
