import 'package:flutter/material.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SUListCard extends StatelessWidget {
  const SUListCard({Key? key, required this.child}) : super(key: key);

  final Widget child;
  @override
  Widget build(BuildContext context) {
    const Offset blurOffset = Offset(-2, 2);
    return Container(
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: SUAppStyle.streamUnlimitedGrey3(),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: SUAppStyle.streamUnlimitedGrey1(),
                  offset: blurOffset,
                  spreadRadius: 0,
                  blurRadius: 4)
            ]),
        child: child);
  }
}
