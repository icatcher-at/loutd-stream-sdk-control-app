import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info/package_info.dart';
import 'package:stream_webview_app/main_page/su_text_button.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_add_button.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  _InfoPageState() {
    version = '';
    appName = '';
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
        appName = packageInfo.appName;
      });
    });
  }

  late String version;
  late String appName;

  Widget _getBody(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 100),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('${translate('app_info.version')} $version',
                  style: Theme.of(context).textTheme.headline3!.merge(
                      TextStyle(color: SUAppStyle.streamUnlimitedGreen())
                  )),
            )
        ),
        Divider(
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: SUAppStyle.streamUnlimitedGreen(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, right: 0, left: 16),
                    alignment: Alignment.centerLeft),
                child: Text(translate('app_info.licenses'),
                    style: Theme.of(context).textTheme.headline3!.merge(
                        TextStyle(
                          color: SUAppStyle.streamUnlimitedGreen(),
                        )
                    )
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => Theme(
                        data: ThemeData(
                          backgroundColor: SUAppStyle.streamUnlimitedGrey2(),
                          cardColor: SUAppStyle.streamUnlimitedGrey3(),
                          textTheme: Theme.of(context).textTheme,
                          appBarTheme: AppBarTheme(
                              iconTheme: IconThemeData(color: SUAppStyle.streamUnlimitedGreen()),
                              color: SUAppStyle.streamUnlimitedGrey2(),
                              titleTextStyle: Theme.of(context).textTheme.headline2!.merge(
                                TextStyle(color: SUAppStyle.streamUnlimitedGreen())
                              ),
                          ),
                        ),
                        child: LicensePage(
                          applicationName: appName,
                          applicationIcon: const Image(
                            image: AssetImage('assets/images/app_logo.png'),
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
        ),
        Divider(
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: SUAppStyle.streamUnlimitedGreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _getBody(context),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SUTextButton(
            text: 'Close',
            textTheme: Theme.of(context).textTheme.headline2!.merge(
              TextStyle(
                color: SUAppStyle.streamUnlimitedGrey2()
              )
            ),
            onClickFunc: Navigator.of(context).pop,
          )
        )
    );
  }
}
