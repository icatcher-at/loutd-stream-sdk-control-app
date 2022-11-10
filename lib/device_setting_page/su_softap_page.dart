import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_list_card.dart';

import '../objects/su_soft_ap.dart';

class SUSoftApPage extends StatefulWidget {
  const SUSoftApPage(
      {Key? key,
      required this.softApList,
      required this.onPressedAction})
      : super(key: key);

  final List<SoftAp> softApList;
  final Future<void> Function(SoftAp softApObj) onPressedAction;

  @override
  _SUSoftApPageState createState() => _SUSoftApPageState();
}

class _SUSoftApPageState extends State<SUSoftApPage> {
  _SUSoftApPageState();

  Widget _myListView(BuildContext context) {
    return ListView.builder(
        itemCount: widget.softApList.length,
        itemBuilder: (BuildContext context, int index) {
          final Card child = Card(
              child: ListTile(
                  title: Text(
                    widget.softApList[index].ssid,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  trailing: _getSoftApStateImage(widget.softApList[index]),
                  onTap: () async {
                    await widget.onPressedAction(widget.softApList[index]);
                    Navigator.of(context).pop();
                  }));
          return SUListCard(child: child);
        });
  }
  Widget _getSoftApStateImage(SoftAp target){
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getSoftApLockIcon(target),
          const SizedBox(width: 5, child: null),
          _getSoftApIntensity(target)
        ]
    );
  }

  Widget _getSoftApLockIcon(SoftAp target) {
    return const SizedBox(width: 20, child: null);
  }

  Widget _getSoftApIntensity(SoftAp target) {
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
            title: Text(translate('softap.soft_ap_list')),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            iconTheme: IconThemeData(color: SUAppStyle.streamUnlimitedGreen())),
        body: _myListView(context));
  }

  @override
  Widget build(BuildContext context) {
    return _buildWifiList(context);
  }
}
