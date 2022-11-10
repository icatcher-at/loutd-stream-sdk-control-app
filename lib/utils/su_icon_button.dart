import 'package:flutter/material.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SUIconButton extends StatelessWidget {
  const SUIconButton(
      {Key? key, required this.onTapFunction,
                 required this.iconData,
                 required this.text
      })
      : super(key: key);

  final void Function() onTapFunction;
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        fillColor: SUAppStyle.streamUnlimitedGrey3(),
        onPressed: onTapFunction,
        shape: const StadiumBorder(),
        child: SizedBox(
          width: 240,
          child: Padding (
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  iconData,
                  color: SUAppStyle.streamUnlimitedGreen()
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
