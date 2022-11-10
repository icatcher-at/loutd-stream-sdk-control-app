import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/device_setting_page/su_device_setting_page.dart';
import 'package:stream_webview_app/utils/su_alert_dialog.dart';
import 'package:stream_webview_app/utils/su_global_config.dart';
import 'package:stream_webview_app/utils/su_icon_button.dart';

class SUMenuDialog extends StatelessWidget {
  SUMenuDialog(this._context, {Key? key, required this.title}): super(key: key) {
    _flutterBlue = FlutterBlue.instance;
  }

  final BuildContext _context;
  final String title;
  late FlutterBlue _flutterBlue;


  static Future<void> showAlertDialog(
      BuildContext context, String title) =>
      showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SUMenuDialog(context, title: title));

  void _showBluetoothDisconnectedDialog() {
    SUAlertDialog.showAlertDialog(_context, translate('ble.errors.off'), translate('ble.action_on'));
  }

  Future<bool> _checkDeviceBluetoothIsOn() async {
    return _flutterBlue.isOn;
  }


  void _goToBleSetting(BuildContext context) {
    _checkDeviceBluetoothIsOn().then((bool result) {
      if(result){
        Navigator.of(context).push(_createRouteToBleSetting());
      } else {
        _showBluetoothDisconnectedDialog();
      }
    });

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            Text(title, style:const TextStyle(fontSize: 24)),
            SUIconButton(
                iconData: Icons.wifi,
                text: translate('dialog.add_dialog_ble'),
                onTapFunction: () async {
                  Navigator.of(context).pop();
                  final bool bleOn = await _checkDeviceBluetoothIsOn();
                  if (bleOn)
                    _goToBleSetting(context);
                  else
                    _showBluetoothDisconnectedDialog();
                }
            ),
            const SizedBox(
              height: 8,
            )
          ]
        )
      )
    );
  }
}