import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stream_webview_app/main_page/su_device_list_page.dart';
import 'package:stream_webview_app/style/su_app_style.dart';

class SUStartPage extends StatelessWidget {
  const SUStartPage({Key? key, required this.localizationDelegate})
      : super(key: key);
  final LocalizationDelegate localizationDelegate;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      // ignore: always_specify_types
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        localizationDelegate
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
      title: 'Flutter Demo',
      theme: SUAppStyle().theme,
      darkTheme: SUAppStyle().darkTheme,
      // home: const SUDeviceListPage(title: 'StreamSDKControlApp'),
      home: const SUDeviceListPage(title: 'StreamSDKControlApp'),
      builder: EasyLoading.init(),
    );
  }
}