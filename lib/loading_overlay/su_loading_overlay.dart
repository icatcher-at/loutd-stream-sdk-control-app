import 'package:flutter/material.dart';
import 'package:stream_webview_app/style/su_app_style.dart';


class SULoadingOverlayView extends StatefulWidget {
  const SULoadingOverlayView({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  _SULoadingOverlayViewState createState() => _SULoadingOverlayViewState();
}

class _SULoadingOverlayViewState extends State<SULoadingOverlayView>
    with SingleTickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
           Icon(Icons.signal_wifi_off,
              color: SUAppStyle.streamUnlimitedGreen(), size: 64),
           Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
            child: Text(
              widget.message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            )
          ),
        ],
      ))
    );
  }
}