import 'package:flutter/material.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SULargeButton extends StatelessWidget {
  const SULargeButton(
      {Key? key, required this.onTapFunction, this.iconData = Icons.add})
      : super(key: key);

  final void Function(BuildContext context) onTapFunction;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    const Offset blurOffset = Offset(-4, 4);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: SUAppStyle.streamUnlimitedGrey3(),
          width: 8.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SUAppStyle.streamUnlimitedGrey1(),
            // unit is some relative part of the canvas width
            offset: blurOffset,
            spreadRadius: 0,
            blurRadius: 8,
          ),
        ],
      ),
      height: 100,
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: Center(
        child: SizedBox.fromSize(
          size: const Size(80, 80), // button width and height
          child: ClipOval(
            child: Material(
              color: SUAppStyle.streamUnlimitedGrey3(), // button color
              child: InkWell(
                onTap: () => onTapFunction(context),
                splashColor: SUAppStyle.streamUnlimitedGrey2(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      iconData,
                      color: SUAppStyle.streamUnlimitedGreen(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
