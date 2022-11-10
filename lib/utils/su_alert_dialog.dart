import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/main_page/su_text_button.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SUAlertDialog extends StatelessWidget {
  const SUAlertDialog({Key? key, required this.title, required this.message})
      : super(key: key);

  final String title;
  final String message;

  static Future<void> showAlertDialog(
          BuildContext context, String title, String message) =>
      showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              SUAlertDialog(title: title, message: message));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title),
        backgroundColor: SUAppStyle.streamUnlimitedGrey3(),
        content: Text(message),
        actions: <Widget>[
          Expanded(
              child: SUTextButton(
                  text: translate('dialog.alert_dialog_ok'),
                  onClickFunc: () {
                    Navigator.of(context).pop();
                  },
                  primary: false,
              )
          ),
        ]);
  }
}
