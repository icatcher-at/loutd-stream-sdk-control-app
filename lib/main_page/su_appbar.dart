import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/nsdk/subscription_helper.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_alert_dialog.dart';
import 'package:stream_webview_app/utils/su_constants.dart';

class SUAppBar extends StatefulWidget implements PreferredSizeWidget {
  SUAppBar({Key? key, this.isBle = false, this.toSetting, this.ip, this.toMain}) : super(key: key) {
    preferredSize = const Size.fromHeight(80.0);
  }

  final bool isBle;
  final Function? toSetting;
  final Function? toMain;
  final String? ip;

  @override
  late Size preferredSize;

  @override
  _SUAppBarState createState() => _SUAppBarState();
}

class _SUAppBarState extends State<SUAppBar> {
  late List<Map<String, dynamic>> _newSubscriptionEvents;
  late SubscriptionHelper _helper;
  String? inputName;
  late bool isHostOverTemp;
  late bool isClientOverTemp;

  @override
  void initState() {
    super.initState();
    isHostOverTemp = false;
    isClientOverTemp = false;
    if (!widget.isBle) {
      _helper = SubscriptionHelper(widget.ip!);
      _newSubscriptionEvents = <Map<String, dynamic>>[];
      _getInputData();
      _getOverTemp(hostOverTempPath, true);
      _getOverTemp(clientOverTempPath, false);
      _performSubscribe();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.isBle) {
      _performUnsubscribe();
    }
  }

  Future<void> _getInputData() async {
    final List<dynamic> item =
      await NSDK.getData(widget.ip!, playerValuePath, 'value');
    final Map<String, dynamic> val = item[0] as Map<String, dynamic>;
    if (val.containsKey(valueType)) {
      final dynamic playingState = NSDK.getTypedValue(val);
      String? rawInputName = getInputName(playingState);
      if (rawInputName != null) {
        rawInputName = '${rawInputName[0].toUpperCase()}${rawInputName.substring(1).toLowerCase()}';
      }
      setState(() {
        inputName = rawInputName;
      });
    }
  }

  Future<void> _getOverTemp(String overTempPath, bool isHost) async {
    final List<dynamic> item =
      await NSDK.getData(widget.ip!, overTempPath, 'value');
    final Map<String, dynamic> val = item[0] as Map<String, dynamic>;
    if (val.containsKey(valueType)) {
      final bool newIsOverTemp = NSDK.getTypedValue(val) as bool;
      setState(() {
        if (isHost) {
          isHostOverTemp = newIsOverTemp;
        } else {
          isClientOverTemp = newIsOverTemp;
        }
      });
    }
  }

  Future<void> _performSubscribe() async {
    Map<String, dynamic> subscription = await _helper.subscribe(
        playerValuePath, NSDKEventSubscribeTypes.itemWithValue, updateInput);
    _newSubscriptionEvents.add(subscription);
    subscription = await _helper.subscribe(
        hostOverTempPath, NSDKEventSubscribeTypes.itemWithValue,
            (dynamic item) => updateOverTemp(item, true));
    _newSubscriptionEvents.add(subscription);
    subscription = await _helper.subscribe(
        clientOverTempPath, NSDKEventSubscribeTypes.itemWithValue,
            (dynamic item) => updateOverTemp(item, false));
    _newSubscriptionEvents.add(subscription);
  }


  void _performUnsubscribe() {
    // ignore: avoid_function_literals_in_foreach_calls
    _newSubscriptionEvents.forEach((Map<String, dynamic> subscription) {
      _helper.unsubscribe(subscription);
    });
  }

  void updateOverTemp(dynamic item, bool isHost) {
    final Map<String, dynamic> val = item as Map<String, dynamic>;
    if (val.containsKey(itemTypeKey) &&
        val[itemTypeKey] == NSDKRowEventType.update &&
        val.containsKey(itemValueKey) ||
        mounted) {
      final bool newIsOverTemp = NSDK.getTypedValue(val[itemValueKey]) as bool;
      setState(() {
        if (isHost)
          isHostOverTemp = newIsOverTemp;
        else
          isClientOverTemp = newIsOverTemp;
      });
    }
  }

  void updateInput(dynamic item) {
    final Map<String, dynamic> val = item as Map<String, dynamic>;
    if (val.containsKey(itemTypeKey) &&
        val[itemTypeKey] == NSDKRowEventType.update &&
        val.containsKey(itemValueKey) ||
        mounted) {
      final dynamic playingState = NSDK.getTypedValue(val[itemValueKey]);
      String? rawInputName = getInputName(playingState);
      if (rawInputName != null) {
        rawInputName = '${rawInputName[0].toUpperCase()}${rawInputName.substring(1).toLowerCase()}';
      }
      setState(() {
        inputName = rawInputName;
      });
    }
  }

  String? getInputName(dynamic playingState) {
    if (
      playingState != null &&
        playingState["trackRoles"] != null &&
        playingState["trackRoles"]["mediaData"] != null &&
        playingState["trackRoles"]["mediaData"]["metaData"] != null
    ) {
      if (playingState['trackRoles']['mediaData']['metaData']['serviceNameOverride'] != null) {
        return playingState['trackRoles']['mediaData']['metaData']['serviceNameOverride'] as String;
      } else if (playingState['trackRoles']['mediaData']['metaData']['serviceID'] != null) {
        return playingState['trackRoles']['mediaData']['metaData']['serviceID'] as String;
      }
    }
    if (
      playingState != null &&
        playingState["mediaRoles"] != null &&
        playingState["mediaRoles"]["mediaData"] != null &&
        playingState["mediaRoles"]["mediaData"]["metaData"] != null &&
        playingState["mediaRoles"]["mediaData"]["metaData"]["serviceID"] != null
    ) {
      return playingState["mediaRoles"]["mediaData"]["metaData"]["serviceID"] as String;
    }
    return null;
  }

  Widget createInputDisplay() {
    return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: SUAppStyle.streamUnlimitedGrey3(),
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: inputName != null? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(inputName!)
        ) : Container()
    );
  }

  Widget createInfoButton(BuildContext context) {
    return InkWell(
      onTap: () {
        SUAlertDialog.showAlertDialog(
          context,
          translate('ble_control.info_dialog_title'),
          translate('ble_control.info_dialog_message')
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: SUAppStyle.streamUnlimitedGrey3(),
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(translate('ble_control.info_button'))
        )
      )
    );
  }

  Widget createNotification(BuildContext context) {
    return Container (
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: SUAppStyle.streamUnlimitedGreen(),
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: Row (
        children: <Widget>[
          if (isHostOverTemp || isClientOverTemp) const Icon(Icons.thermostat,
              color: Colors.red),
          if (widget.isBle) Container() else createInputDisplay(),
          const Spacer(),
          if (widget.isBle)
            Text(translate('ble_control.connection_limited'))
          else
            Text(translate('ble_control.connection_full')),
          createInfoButton(context)
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // final Widget notification = createNotification(context);
    return SafeArea(
        top: true,
        bottom: false,
        child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              children: <Widget> [
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    if (widget.isBle)
                      const SizedBox(
                        width: 50.0,
                        height: 50.0
                      )
                    else
                      IconButton(
                          icon: SvgPicture.asset(
                              'assets/icons/Icon_settings_outline.svg',
                              color: SUAppStyle.streamUnlimitedGreen()
                          ),
                          onPressed: () => widget.toSetting!()
                      ),
                    const Spacer(),
                    SizedBox(
                        width: 97.0,
                        child: IconButton(
                          onPressed: () {
                            if (widget.toMain != null) {
                              widget.toMain!();
                            }
                          },
                          icon: const Image(
                            image: AssetImage('assets/images/app_logo.png'),
                          ),
                        ),
                    ),
                    const Spacer(),
                    IconButton(
                        icon: SvgPicture.asset(
                            'assets/icons/Icon_home_outline.svg',
                            color: SUAppStyle.streamUnlimitedGreen()
                        ),
                        onPressed: () => Navigator.of(context).pop()
                    )
                  ]
                )
              ]
            )
        )
    );
  }
}
