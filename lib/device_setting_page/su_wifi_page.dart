import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/objects/su_wifi.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_alert_dialog_with_textfield.dart';
import 'package:stream_webview_app/utils/su_list_card.dart';

class SUWifiPage extends StatefulWidget {
  const SUWifiPage(
      {Key? key,
      required this.wifiList,
      required this.onPressedAction,
      required this.disconnectDevice})
      : super(key: key);

  final List<Wifi> wifiList;
  final void Function(Wifi, String) onPressedAction;
  final void Function(Function() onComplete) disconnectDevice;

  @override
  _SUWifiPageState createState() => _SUWifiPageState();
}

class _SUWifiPageState extends State<SUWifiPage> {
  _SUWifiPageState();

  Widget _myListView(BuildContext context) {
    return ListView.builder(
        itemCount: widget.wifiList.length,
        itemBuilder: (BuildContext context, int index) {
          final Card child = Card(
              child: ListTile(
                  title: Text(
                    widget.wifiList[index].ssid,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  trailing: _getWifiStateImage(widget.wifiList[index]),
                  onTap: () async {
                    if (widget.wifiList[index].encryption != 'none') {
                      final String? password =
                      await AlertDialogWithTextField.showDialogWithText(
                          context, true);
                      if (password != null) {
                        widget.onPressedAction(widget.wifiList[index], password);
                      }
                    } else {
                      final String? password =
                      await AlertDialogWithTextField.showDialogWithText(
                          context, false);
                      if (password == '') {
                        widget.onPressedAction(widget.wifiList[index], '');
                      }

                    }
                  }));
          return SUListCard(child: child);
        });
  }
  Widget _getWifiStateImage(Wifi target){
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getWifiLockIcon(target),
          const SizedBox(width: 12, child: null),
          _getWifiIntensity(target)
        ]
    );
  }

  Widget _getWifiLockIcon(Wifi target) {
    if (target.encryption == null)
      return const SizedBox(width: 20, child: null);

    if (target.encryption != 'none') {
      return SizedBox(
        width: 20,
        child: SvgPicture.asset(
          'assets/icons/Icon_closed_outline.svg',
          color: Colors.white,
        ),
      );
    } else {
      return const SizedBox(width: 20, child: null);
    }
  }

  Widget _getWifiIntensity(Wifi target) {
    final Color color = SUAppStyle.streamUnlimitedGreen();
    if (target.rssi > -50)
      return Image.asset('assets/images/wifi_intensity_3.png', scale: 2.2, color:color);
    else if (target.rssi > -70)
      return Image.asset('assets/images/wifi_intensity_2.png', scale: 2.2, color:color);
    else
      return Image.asset('assets/images/wifi_intensity_1.png', scale: 2.2, color:color);
  }
  Widget _buildWifiList(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(translate('ble.wifi_list')),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.disconnectDevice(() =>
                      Navigator.of(context).pop()
                  );

                }),
            iconTheme: IconThemeData(color: SUAppStyle.streamUnlimitedGreen())),
        body: _myListView(context));
  }

  @override
  Widget build(BuildContext context) {
    return _buildWifiList(context);
  }
}
