import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/main_page/su_text_button.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class AlertDialogWithTextField extends StatefulWidget {

  const AlertDialogWithTextField({Key? key, required this.passwordNeeded}) : super(key: key);
  final bool passwordNeeded;

  // NOTE(takaki): no callback needed, return value can be handled with Navigator.pop
  static Future<String?> showDialogWithText(BuildContext context, bool passwordNeeded) =>
      showDialog<String>(
          context: context,
          builder: (BuildContext context) =>  AlertDialogWithTextField(passwordNeeded: passwordNeeded));

  @override
  _AlertDialogWithTextFieldState createState() =>
      _AlertDialogWithTextFieldState();
}

class _AlertDialogWithTextFieldState extends State<AlertDialogWithTextField> {
  late TextEditingController _textEditingController;
  String? passWord;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
        title: widget.passwordNeeded ?
            Text(
                translate('ble.password_dialog'),
                style: Theme.of(context).textTheme.headline2,
            )
            : Text(translate('')),
        backgroundColor: SUAppStyle.streamUnlimitedGrey3(),
        content: widget.passwordNeeded ? TextField(
            obscureText: true,
            controller: _textEditingController,
            textInputAction: TextInputAction.go,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: SUAppStyle.streamUnlimitedGreen()),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: SUAppStyle.streamUnlimitedGreen()),
                ),
                hintText: translate('ble.password_dialog_hint')),
                cursorColor: SUAppStyle.streamUnlimitedGreen(),
                onChanged: (String value) {
                  passWord = value;
                }
            ):
            RichText(
              text: TextSpan(
                text: translate('ble.tap_unencrypted_network'),
                style: const TextStyle(fontSize: 20),
                children:  <TextSpan>[
                  TextSpan(text: ' ${translate('ble.connect')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  TextSpan(text: ' ${translate('ble.procced_question')}', style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SUTextButton(
                  text: translate('ble.password_dialog_cancel'),
                  primary: false,
                  onClickFunc: () {
                    Navigator.of(context).pop();
                  })
              ),
              Expanded(
                child: SUTextButton(
                  text: translate('ble.password_dialog_connect'),
                  onClickFunc: () {
                    widget.passwordNeeded ? Navigator.of(context).pop(passWord):Navigator.of(context).pop('');
                  })
              )
            ])
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
  }
}
