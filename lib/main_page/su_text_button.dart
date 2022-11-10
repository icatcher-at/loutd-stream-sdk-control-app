
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SUTextButton extends StatelessWidget {
  SUTextButton({Key? key,
    required this.text,
    required this.onClickFunc,
    this.textTheme,
    this.primary = true}) : super(key: key);

  final String text;
  final Function() onClickFunc;
  final bool primary;
  TextStyle? textTheme;

  TextStyle _getTextStyle(BuildContext context) {
    if (textTheme == null) {
      TextStyle textStyle;
      if (primary) {
        textStyle = Theme
            .of(context)
            .textTheme
            .headline3!
            .merge(
            TextStyle(color: SUAppStyle.streamUnlimitedGrey3())
        );
      } else {
        textStyle = Theme
            .of(context)
            .textTheme
            .headline3!
            .merge(
            TextStyle(color: SUAppStyle.streamUnlimitedGreen())
        );
      }
      return textStyle;
    } else {
      return textTheme!;
    }
  }

  ButtonStyle _getStyle(BuildContext context) {
    Color backgroundColor;
    if (primary) {
      backgroundColor = SUAppStyle.streamUnlimitedGreen();
    } else {
      backgroundColor = SUAppStyle.streamUnlimitedGrey3();
    }

    return TextButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(side: BorderSide(
            color: SUAppStyle.streamUnlimitedGreen(),
            width: 1,
            style: BorderStyle.solid
        ), borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.all(12.0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 4, right: 4),
        child: TextButton(
            child: Text(
              text,
              style: _getTextStyle(context),
            ),
            onPressed: () => onClickFunc(),
            style: _getStyle(context)
        )
    );
  }
}