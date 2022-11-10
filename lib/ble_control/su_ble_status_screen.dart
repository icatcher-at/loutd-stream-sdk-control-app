import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/ble_control/su_ble_device_controller.dart';
import 'package:stream_webview_app/main_page/su_appbar.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_constants.dart';

class BleStatusScreen extends StatefulWidget {
  const BleStatusScreen({Key? key, required this.bleDeviceController}) : super(key: key);

  final BleDeviceController bleDeviceController;

  @override
  _BleStatusScreenState createState() => _BleStatusScreenState();
}

class _BleStatusScreenState extends State<BleStatusScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.bleDeviceController.disconnectDevice();
  }

  Widget buttonBase(int buttonId,
      Widget content, bool navigationBack,
      {BuildContext? context, bool isInputButton = false}) {
    return InkWell(
        onTap: () {
          if (isInputButton) {
            showDialog(context!);
            return;
          }
          widget.bleDeviceController.executeFunction(buttonId);
          if (navigationBack) {
            if (context != null)
              Navigator.of(context).pop();
            else
              developer.log('Context is empty. Provide the method with Context!',
                  name: runtimeType.toString());
          }
        },
        child: Container(
            decoration: BoxDecoration(
                color: SUAppStyle.streamUnlimitedGreen(),
                borderRadius: BorderRadius.circular(10.0)
            ),
            child: Padding (
                padding: const EdgeInsets.all(16.0),
                child: content
            )
        )
    );
  }

  Widget createIconButton(String iconData, int buttonId,
      {double size = 120, bool navigateBack = false, BuildContext? context}) {
    return buttonBase(buttonId,
        SizedBox(
            width: size,
            child: SvgPicture.asset(
                iconData,
                height: 20,
                width: 20,
                color: Colors.white
            )),
            navigateBack, context: context);
  }

  Future<List<Widget>> generateInputObject() async {
    // read json file
    final String inputsString
      = await rootBundle.loadString('assets/json/inputSources.json');
    final Map<String, dynamic> data = await jsonDecode(inputsString) as Map<String, dynamic>;

    // create Input object
    final List<Widget> inputList = <Widget>[];
    for (final Map<String, dynamic> e in data['inputs']) {
      if (e['enabled'] as bool) {
        final Widget wid = InkWell(
            onTap: () {
              widget.bleDeviceController.executeFunction(e['buttonKey'] as int);
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  e['name'] as String,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline3!
                      .merge(
                      TextStyle(color: SUAppStyle.streamUnlimitedGreen())
                  ),
                )
            )
        );
        inputList.add(wid);
      }
    }
    return inputList;
  }

  Future<void> showDialog(BuildContext context) async {
    // showModalBottomSheet(context: context, builder: builder);
    final List<Widget> inputSourcesWidget = await generateInputObject();
    final List<Widget> scrollBody = <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child:Text(
          'Input',
          style: Theme.of(context).textTheme.headline4!.merge(
            TextStyle(
              color: SUAppStyle.streamUnlimitedGrey5()
            )
          ),
        )
      )
    ];
    scrollBody.addAll(inputSourcesWidget);
    showModalBottomSheet(
      context: context,
      backgroundColor: SUAppStyle.streamUnlimitedGrey2(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: scrollBody
              )
          )
        );
      }
    );
  }

  Widget createInputButton(BuildContext context) {
    return buttonBase(-1, const Text('Inputs'),
        false, context: context, isInputButton: true);
  }

  Widget createUpperBody(BuildContext context) {
    return Row (
      children: <Widget>[
        const Spacer(),
        createInputButton(context)
      ]
    );
  }

  Widget createPlayerBody(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
          border: Border.all(
            color: SUAppStyle.streamUnlimitedGreen(),
            width: 4,
          ),
          color: SUAppStyle.streamUnlimitedGrey2(),
          borderRadius: BorderRadius.circular(10.0)
      ),
      child: Column(
          children: <Widget>[
            const Text('Player'),
            const SizedBox(height: 16),
            Row (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                createIconButton('assets/icons/power.svg', keySleep,
                    navigateBack: true, context: context),
                createIconButton('assets/icons/icon_mute.svg', keyVolumeMute)
              ],
            ),
            const SizedBox(height: 16),
            Row (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                createIconButton('assets/icons/icon_minus.svg', keyVolumeDown),
                createIconButton('assets/icons/icon_plus.svg', keyVolumeUp)
              ],
            ),
            const SizedBox(height: 16)
          ],
        )
    );
  }

  Widget createBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: <Widget>[
          createUpperBody(context),
          createPlayerBody(context)
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SUAppBar(isBle: true),
        body: createBody(context)
    );
  }
}