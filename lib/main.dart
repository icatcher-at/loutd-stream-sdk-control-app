import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/main_page/su_start_page.dart';
import 'package:stream_webview_app/websocket/su_websocket_handler.dart';

Future<void> main() async {
  final LocalizationDelegate delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US', supportedLocales: <String>['en_US', 'de']);
  runApp(LocalizedApp(delegate, const SULocalizationApp()));
}

class SULocalizationApp extends StatelessWidget {
  const SULocalizationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;
    WebSocketHandler().startWebSocket();
    return LocalizationProvider(
      child: SUStartPage(localizationDelegate: localizationDelegate),
      state: LocalizationProvider.of(context).state,
    );
  }
}
