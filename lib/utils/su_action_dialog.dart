import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/main_page/su_text_button.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SUActionDialog extends StatelessWidget {
  const SUActionDialog({Key? key,
    required this.title,
    required this.message,
    required this.doAction,
    this.actionButtonText
  })
      : super(key: key);

  final String title;
  final String message;
  final Function() doAction;
  final String? actionButtonText;

  static Future<void> showActionDialog(
        BuildContext context,
        String title,
        String message,
        Function() doAction,
        {String actionButtonText=''}
      ) =>
          showDialog<void>(
              context: context,
              builder: (BuildContext context) =>
                  SUActionDialog(
                      title: title,
                      message: message,
                      doAction: doAction,
                      actionButtonText: actionButtonText,
                  ));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title),
        content: Text(message),
        backgroundColor: SUAppStyle.streamUnlimitedGrey3(),
        actions: <Widget>[
          Row(
              children: <Widget>[
                Expanded(
                    child: SUTextButton(
                      text: translate('dialog.alert_dialog_cancel'),
                      onClickFunc: () {
                        Navigator.of(context).pop();
                      },
                      primary: false,
                    ),
                ),
                Expanded(
                    child: SUTextButton(
                        text: actionButtonText != null || actionButtonText !='' ?
                                translate(actionButtonText!)
                                : translate('dialog.alert_dialog_ok'),
                        onClickFunc: () {
                          doAction();
                          Navigator.of(context).pop();
                        })
                )
              ]
          )
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16)
    );
  }
}
