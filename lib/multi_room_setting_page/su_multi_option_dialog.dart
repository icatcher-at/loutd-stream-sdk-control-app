import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/multi_room_setting_page/su_option.dart';
import 'package:stream_webview_app/objects/su_device.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class MultiOptionDialog extends StatefulWidget {
  const MultiOptionDialog({Key? key,
                     required this.title,
                     required this.devices,
                    }): super(key: key) ;

  static Future<List<Device>?> showOptionDialog(BuildContext context, String title, List<Device> devices) =>
      showDialog<List<Device>>(
          context: context,
          builder: (BuildContext context) =>  MultiOptionDialog(title: title, devices: devices)
      );

  final String title;
  final List<Device> devices;

  @override
  _MultiOptionDialogState createState() => _MultiOptionDialogState();
}

class _MultiOptionDialogState extends State<MultiOptionDialog> {
  @override
  void initState(){
    super.initState();
    options = _makeOptions(widget.devices);
  }

  late List<Option> options;

  List<Option> _makeOptions(List<Device> devices) {
    final List<Option> options = <Option>[];
    for (int i = 0; i < devices.length; i++){
      options.add(Option(false, i, devices[i].name!));
    }
    return options;
  }

  List<Device> _getSelectedSlaves(List<Option> options){
    final List<Device> slaves = <Device>[];
    for(final Option option in options) {
      if (option.selected)
        slaves.add(widget.devices[option.index]);
    }
    return slaves;
  }

  Widget customRow(int index){
    return Padding (
      padding: const EdgeInsets.only(left: 12.0, right: 3.0, top: 3.0, bottom: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
          child: Text(
            options[index].title,
            style: const TextStyle(
              fontSize: 16
            ),
          )),
          if (options[index].selected) const Icon(
            Icons.radio_button_checked
          ) else const Icon(
            Icons.radio_button_unchecked
          )
        ]
      )
    );
  }

  Widget _dialogOptionPart(BuildContext context) {
    if (options.isEmpty) {
      return Container();
    } else {
      return Container(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 12.0),
            color: SUAppStyle.streamUnlimitedGreen(),
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Divider(
                color: SUAppStyle.streamUnlimitedGrey2(),
              ),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  //highlightColor: Colors.red,
                  //splashColor: Colors.blueAccent,
                  onTap: () {
                    setState(() {
                      options[index].selected = !options[index].selected;
                    });
                  },
                  child: customRow(index),
                );
              },
            ),
        );
    }
  }

  Widget _dialogContent(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Image.asset('assets/icons/multiroom_group.png', width: 160),
          ),
          Container(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 8.0),
            // color: SUAppStyle().getPrimaryBlack(),
            child: Text(translate(widget.title),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22
              )
            ),
          ),
          Flexible(
            child: _dialogOptionPart(context)
          ),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_getSelectedSlaves(options));
              },
              child: Text(
                translate('dialog.mr_dialog_connect_button'),
                style: Theme.of(context).textTheme.headline3,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  )
                )
              )
            ),
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        elevation: 25.0,
        backgroundColor: SUAppStyle.streamUnlimitedGrey2(),
        child: _dialogContent(context),
    );
  }
}