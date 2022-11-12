import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stream_webview_app/ble_control/su_ble_device_controller.dart';
import 'package:stream_webview_app/ble_control/su_ble_status_screen.dart';
import 'package:stream_webview_app/ble_device_discovery/su_main_ble_provider.dart';
import 'package:stream_webview_app/device_setting_page/su_ble_service_handler.dart';
import 'package:stream_webview_app/device_setting_page/su_device_setting_page.dart';
import 'package:stream_webview_app/loading_overlay/su_loading_overlay.dart';
import 'package:stream_webview_app/main_page/su_custom_slider.dart';
import 'package:stream_webview_app/main_page/su_info.dart';
import 'package:stream_webview_app/main_page/su_menu_dialog.dart';
import 'package:stream_webview_app/main_page/su_text_button.dart';
import 'package:stream_webview_app/mdns_device_discovery/su_mdns_device_provider.dart';
import 'package:stream_webview_app/mdns_device_discovery/su_multiroom_mdns_device_provider.dart';
import 'package:stream_webview_app/multi_room_setting_page/su_multi_room_setting_handler.dart';
import 'package:stream_webview_app/multi_room_setting_page/su_multi_room_setting_page.dart';
import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/objects/su_device.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_action_dialog.dart';
import 'package:stream_webview_app/utils/su_add_button.dart';
import 'package:stream_webview_app/utils/su_alert_dialog.dart';
import 'package:stream_webview_app/utils/su_ble_conststants.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_enum.dart';
import 'package:stream_webview_app/utils/su_global_config.dart';
import 'package:stream_webview_app/utils/su_list_card.dart';

import './su_webview.dart';
import '../objects/su_device.dart';
import '../utils/animations/su_slide_right_route.dart';


class SUDeviceListPage extends StatefulWidget {
  const SUDeviceListPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SUDeviceListPageState createState() => _SUDeviceListPageState();
}

class _SUDeviceListPageState extends State<SUDeviceListPage> {
  late StreamSubscription<ConnectivityResult> _streamSubscription;
  late MultiroomMdnsDeviceProvider _mrDevicesProvider;
  late MdnsDeviceProvider _devicesProvider;

  late List<Device> master;
  late Map<String, List<Device>> slaveMap;
  bool isWiFiConnected = false;
  late FlutterBlue _flutterBlue;

  List<BluetoothDevice>? bleAmpDevices;
  List<BluetoothDevice>? bleDevices;
  late RefreshController _refreshController;
  late MainBleDeviceProvider _bleAmpDeviceProvider;
  late MainBleDeviceProvider _bleDeviceProvider;

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
    super.initState();
    _flutterBlue = FlutterBlue.instance;

    _streamSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        setState(() {
          isWiFiConnected = true;
        });
      } else {
        setState(() {
          isWiFiConnected = false;
        });
      }
    });

    if (isMultiRoomFunctionEnabled) {
      _mrDevicesProvider = MultiroomMdnsDeviceProvider(updateUiMr);
      _mrDevicesProvider.startScanning();
      master = _mrDevicesProvider.master;
      slaveMap = _mrDevicesProvider.slaveMap;
    } else {
      _devicesProvider = MdnsDeviceProvider(updateUi, bleServiceType);
      _devicesProvider.startScanning();
      master = <Device>[];
      slaveMap = <String, List<Device>>{};
    }
    if (stream_amp) {
      _bleAmpDeviceProvider = MainBleDeviceProvider(bleAmpUpdateUi,
          wifiAmpServiceUuidString);
      _bleAmpDeviceProvider.startScanning();
      bleAmpDevices = <BluetoothDevice>[];
    }
    _bleDeviceProvider = MainBleDeviceProvider(bleUpdateUi,
      wifiServiceUuidString);
    _bleDeviceProvider.startScanning();
    bleDevices = <BluetoothDevice>[];

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // ==== BLE Setting Page ====
  late BleServiceHandler _serviceHandler;
  Future<void> _startBleSetup(
      BluetoothDevice device, BuildContext context) async {
    _serviceHandler = BleServiceHandler(device);
    await _serviceHandler.startSetting(context, onDoneFunc: ()=><void>{removeDeviceFromList(device)});
  }
  // =============connect to status UUID=============

  void removeDeviceFromList(BluetoothDevice device) {
    if (bleDevices != null)
      setState(() {
        bleDevices!.remove(device);
      });
    if (bleAmpDevices != null)
      setState(() {
        bleAmpDevices!.remove(device);
      });
  }

  void updateUiMr(List<Device> masterCand, Map<String,
      List<Device>> slaveMapCand) {
    setState(() {
      slaveMap = slaveMapCand;
      master = masterCand;
    });
  }

  void updateUi(List<Device> devices) {
    setState(() {
      master = devices;
    });
  }

  void bleAmpUpdateUi(List<BluetoothDevice> devices) {
    setState(() {
      bleAmpDevices = devices;
    });
  }

  void bleUpdateUi(List<BluetoothDevice> devices) {
    setState(() {
      bleDevices = devices;
    });
  }

  void _showMenuDialog() {
    SUMenuDialog.showAlertDialog(context, translate('dialog.add_dialog_title'));
  }

  void _goToInfo(BuildContext context) {
    Navigator.push(context,
        // ignore: always_specify_types
        PageTransition(type: PageTransitionType.fade, child: const InfoPage()));
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (isMultiRoomFunctionEnabled) {
      _mrDevicesProvider.stopScanning();
    } else {
      _devicesProvider.stopScanning();
    }
    if (stream_amp) {
      _bleAmpDeviceProvider.stopScanning();
    }
    super.dispose();
  }

  Widget cardMDnsLayout(Device device) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Expanded( child:
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/device.svg',
                color: device.isOnline() ? SUAppStyle.streamUnlimitedGreen() : SUAppStyle.streamUnlimitedGrey4()
              ),
              title: Text(
                  device.name!,
                  style: Theme.of(context).textTheme.headline3!.merge(
                    TextStyle(color: device.isOnline() ? Colors.white : SUAppStyle.streamUnlimitedGrey4())
                  )
              ),
              subtitle: Text(
                  device.ip!,
                  style: Theme.of(context).textTheme.headline5!.merge(
                      TextStyle(color: device.isOnline() ? SUAppStyle.streamUnlimitedGrey5() : SUAppStyle.streamUnlimitedGrey4())
                  )
              ),
              onTap: () {
                  if (device.isOnline())
                    _goToWebView(device, context);
                },
            )
          ),
          Column(
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/power.svg',
                  color: SUAppStyle.streamUnlimitedGreen()
                ),
                onPressed: ()=><void>{
                  NSDK.activate(device.ip!, device.getActivatePath())
                },
              ),
              if (isMultiRoomFunctionEnabled
                  && !isGlobalMultiRoomButtonEnabled
                  && device.transcoder != TranscoderValues.disabled)
                IconButton(
                  icon: SvgPicture.asset(
                      'assets/icons/icon_group.svg',
                      color: device.isOnline() ? SUAppStyle.streamUnlimitedGreen() : SUAppStyle.streamUnlimitedGrey4()
                  ),
                  onPressed: (){
                      if (device.isOnline())
                        _showOptionDialog(device);
                    },
                ),
            ],
          )
        ],
      ),
      // SUCustomSlider(ip: device.ip!),
      _multiRoomCustomRow(device)
    ]);
  }

  Widget cardStreamAmpBleLayout(BluetoothDevice device) {
    return Column(children: <Widget>[
      ListTile(
        leading: SvgPicture.asset(
          'assets/icons/device.svg',
          color: SUAppStyle.streamUnlimitedGreen()
        ),
        title: Text(
            device.name,
            style: Theme.of(context).textTheme.headline3
        ),
      ),
      const SizedBox(
        height: 16
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SUTextButton(
                    text: translate('ble_control.button_title'),
                    onClickFunc: () => _goToBlePage(device, context))
            ),
            Expanded(
                child: SUTextButton(
                    text: translate('ble.button_title'),
                    onClickFunc: () => _startBleSetup(device, context),
                    primary: false,
                )
            )
          ]
      ),
      const SizedBox(
          height: 16
      ),
    ]);
  }

  Widget cardBleLayout(BluetoothDevice device) {
    return Column(children: <Widget>[
      ListTile(
        leading: SvgPicture.asset(
            'assets/icons/device.svg',
            color: SUAppStyle.streamUnlimitedGreen()
        ),
        title: Text(
            device.name == '' ? bleNamePlaceholder : device.name,
            style: Theme.of(context).textTheme.headline3
        ),
      ),
      const SizedBox(
          height: 16
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SUTextButton(
                    text: translate('ble.button_title'),
                    onClickFunc: () => _startBleSetup(device, context),
                    primary: false,
                ),
            )
          ]
      ),
      const SizedBox(
          height: 16
      ),
    ]);
  }

  Widget slaveCardLayout(Device device) {
    return Card(
      color: SUAppStyle.streamUnlimitedGreen(),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: SvgPicture.asset(
                'assets/icons/device.svg',
                color: SUAppStyle.streamUnlimitedGrey3()
            ),
            title: Text(
                device.name!,
                style: Theme.of(context).textTheme.headline3
            ),
            subtitle: Text(device.ip!),
            trailing: IconButton(
              icon: SvgPicture.asset(
                  'assets/icons/icon_cross.svg',
                  color: SUAppStyle.streamUnlimitedGrey3()
              ),
              onPressed: () {
                SUActionDialog.showActionDialog(
                    context,
                    translate('dialog.mr_dialog_ungroup_title'),
                    translate('dialog.mr_dialog_ungroup_content'),
                    (){
                      final MultiRoomSettingHandler handler = MultiRoomSettingHandler.getHandler();
                      handler.sendUngroupingRequest(device.ip!);
                      EasyLoading.show(
                          status: translate('load.loading'),
                          maskType: EasyLoadingMaskType.black);
                    },
                    actionButtonText: translate('dialog.alert_dialog_ok')
                );
              }
            ),
          ),
          // SUCustomSlider(ip: device.ip!, invertColor: true),
        ]
      )
    );
  }

  Widget _multiRoomElement(Device device) {
    return slaveCardLayout(device);
  }

  Widget _multiRoomCustomRow(Device device) {
    if (slaveMap[device.uuid] == null || slaveMap[device.uuid]!.isEmpty)
      return Container();
    else {
      final List<Widget> mrDevices = <Widget>[];
      for (final Device d in  slaveMap[device.uuid]!) {
        mrDevices.add(_multiRoomElement(d));
      }
      return Column(
        children: mrDevices
      );
    }
  }

  void _showOptionDialog(Device device) {
    final MultiRoomSettingHandler mrHandler = MultiRoomSettingHandler.getHandler();
    mrHandler.showOptionDialogAndConnect(device, master, context);
  }
  void _goToWebView(Device device, BuildContext context) {
    Navigator.of(context)
        .push(SlideRightRoute(page:
                  WebViewContainerCover(device.ip!, device.port)));
  }

  Future<void> _goToBlePage(BluetoothDevice device, BuildContext context) async {
    EasyLoading.show(
        status: translate('load.loading'),
        maskType: EasyLoadingMaskType.black
    );
    final BleDeviceController deviceController = BleDeviceController(device);
    await deviceController.connectDevice(context);
    Navigator.of(context)
        .push(SlideRightRoute(page:
                  BleStatusScreen(bleDeviceController: deviceController)));
  }

  Future<bool> _checkDeviceBluetoothIsOn() async {
    return _flutterBlue.isOn;
  }

  void _showBluetoothDisconnectedDialog(BuildContext context) {
    SUAlertDialog.showAlertDialog(context, translate('ble.errors.off'), translate('ble.action_on'));
  }

  Route<BleNetworkSettingPage> _createRouteToBleSetting() {
    return PageRouteBuilder<BleNetworkSettingPage>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      const BleNetworkSettingPage(),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return child;
      },
    );
  }

  void _goToBleSetting(BuildContext context) {
    _checkDeviceBluetoothIsOn().then((bool result) {
      if(result){
        Navigator.of(context).push(_createRouteToBleSetting());
      } else {
        _showBluetoothDisconnectedDialog(context);
      }
    });
  }

  void _goToMultiRoomSetting(BuildContext context) {
    Navigator.of(context).push(_createRouteToMultiRoomSetting());
  }

  Route<MultiRoomSettingPage> _createRouteToMultiRoomSetting() {
    return PageRouteBuilder<MultiRoomSettingPage>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      const MultiRoomSettingPage(),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return child;
      },
    );
  }

  Widget _customScroller(BuildContext context) {
    return Column(children: <Widget>[
      if (isGlobalMultiRoomButtonEnabled)
        SULargeButton(onTapFunction: _goToMultiRoomSetting),
      refresher(context)
    ]);
  }

  Widget _deviceListView(BuildContext context) {
    // Provide a ListView for discovered Devices
    return Scrollbar(
        child: ListView.builder(
          itemCount: _getListLength() + 1,
          itemBuilder: (BuildContext context, int index) {
            final Widget child;
            if (index == 0) {
              child = const SizedBox(
                height: 50,
              );
            } else if (index - 1 >= master.length + bleDevices!.length) {
              child = SUListCard(child: Card(
                  child: cardStreamAmpBleLayout(bleAmpDevices![index - 1 - master.length - bleDevices!.length])));
            } else if (index - 1 >= master.length) {
              child = SUListCard(child: Card(
                  child: cardBleLayout(bleDevices![index - 1 - master.length])));
            } else {
              child = SUListCard(child: Card(child: cardMDnsLayout(master[index-1])));
            }
            return child;
          }
        )
    );
  }

  int _getListLength() {
    if (stream_amp && bleAmpDevices != null) {
      return master.length + bleAmpDevices!.length + bleDevices!.length;
    } else {
      return master.length + bleDevices!.length;
    }
  }

  Widget refresher(BuildContext context) {
    // Provide a refresher Widget which refreshes the device list by pulling it down
    return Flexible(
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: false,
          onRefresh: _onRefresh,
          controller: _refreshController,
          child: _deviceListView(context),
        ));
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return true ? Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: const Center(
            child: Image(
              image: AssetImage('assets/images/app_logo.png'),
              height: 65,
            )
          ),
          centerTitle: true,
          actions: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                      icon: SvgPicture.asset(
                          'assets/icons/info.svg',
                          color: SUAppStyle.streamUnlimitedGreen()
                      ),
                      onPressed: () {_goToInfo(context);}),
                  const SizedBox(height: 30)
                ])
          ],
        ),
        body: _customScroller(context),
        // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: const SizedBox(height: 30)
        ):  SULoadingOverlayView(message: translate('wifi.wifi_disconnected'));
  }
}
