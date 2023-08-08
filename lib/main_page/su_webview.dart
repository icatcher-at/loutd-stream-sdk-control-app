import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:stream_webview_app/main_page/su_appbar.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_global_config.dart';
import 'package:stream_webview_app/utils/su_url_constants.dart';
import 'package:stream_webview_app/websocket/su_websocket_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../deep_link/su_deeplink_bloc.dart';
import '../oauth/su_oauth.dart';
import '../utils/su_constants.dart';

class WebViewContainerCover extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const WebViewContainerCover(this._ip, this._port);

  final String _ip;
  final int _port;

  @override
  WebViewContainerCoverState createState() => WebViewContainerCoverState();
}

class WebViewContainerCoverState extends State<WebViewContainerCover> with WidgetsBindingObserver {
  late DeepLinkBloc bloc;
  late StreamSubscription<String> _blocStateSub;

  late String _url;
  late OAuthHandler _oaHandler;
  late WebViewController _webViewController;
  late BuildContext? _context;

  final UniqueKey _key = UniqueKey();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        WebSocketHandler().checkSpotify();
        break;
      case AppLifecycleState.inactive:
        print('app in inactive');
        break;
      case AppLifecycleState.paused:
        print('app in paused');
        break;
      case AppLifecycleState.detached:
        print('app in detached');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _url = Uri.http('${widget._ip}:${widget._port}', '/webclient/', <String, String>{'isMobileApp' : 'true'}).toString();

    bloc = DeepLinkBloc();
    if (Platform.isAndroid)
      WebView.platform = SurfaceAndroidWebView();
    _blocStateSub = bloc.state.listen((String? event) => _onReceiveCode(event));
  }

  void _onPathReceived(String path) {
    _oaHandler = OAuthHandler(path, widget._ip);
    _oaHandler.startProcess();
  }

  NavigationDecision _handleRedirection(NavigationRequest action) {
    if (!action.url.contains(_url)) {
      // if the redirection url doesn't contain a ip address of the device
      // open the link with the browser
      developer.log('Open the link with the browser: ${action.url}',
          name: runtimeType.toString());
      return _functionalUrl(action.url);
    } else {
      return NavigationDecision.navigate;
    }
  }

  NavigationDecision _functionalUrl(String url) {
    if (url.contains(accountSubDir)) {
      // launch(action.url, forceSafariVC: false);
      return NavigationDecision.prevent;
    } else if (url.contains(homeSubDir)) {
      // go to widget._ip
      _webViewController.loadUrl(Uri.http(widget._ip, '').toString());
      return NavigationDecision.prevent;
    } else if (url.contains(deviceListSubDir)) {
      // go back ot list
      Navigator.of(_context!).pop();
      return NavigationDecision.prevent;
    } else if (url.contains(reloadSubDir)) {
      // reload
      _webViewController.reload();
      return NavigationDecision.prevent;
    } else if (url.contains(openThirdPartyAppRootSubDir) && !url.contains(openHttpsLinks)) {
      _processThirdPartyApp(url);
      return NavigationDecision.prevent;
    }  else if (url.contains(openHttpsLinks)) {
      _processHttpsLinks(url);
      return NavigationDecision.prevent;
    } else {
      launch(url, forceSafariVC: false);
      return NavigationDecision.prevent;
    }
  }

  Future<void> _processThirdPartyApp(String url) async {
    if (url.contains(alexaIdentifier)) {
      _openApp(alexaAppLinkList);
    } else if (url.contains(spotifyIdentifier)) {
      _openApp(spotifyAppLinkList);
    } else if (url.contains(deezerIdentifier)) {
      _openApp(deezerAppLinkList);
    } else if (url.contains(tuneinIdentifier)) {
      _openApp(tuneinAppLinkList);
    } else if (url.contains(youtubemusicIdentifier)) {
      _openApp(youtubemusicAppLinkList);
    } else if (url.contains(pandoraIdentifier)) {
      _openApp(pandoraAppLinkList);
    }
  }

  Future<void> _processHttpsLinks(String url) async {
    if (url.contains(amazonMusicUrlIdentifier)) {
      launch(amazonMusicUrl, forceSafariVC: false);
    } else if (url.contains(spotifyUrlIndentifier)) {
      launch(spotifyUrl, forceSafariVC: false);
    } else if (url.contains(pandoraUrlIdentifier)) {
      final String code = url.split('=').last;
      launch(pandoraUrl + code, forceSafariVC: false);
    } else if(url.contains(tidalUrlIndentifier)) {
      launch(tidalUrl, forceSafariVC: false);
    }
  }

  Future<void> _openApp(Map<String, String> linkList) async {
    if (Platform.isAndroid) {
      if (await DeviceApps.isAppInstalled(linkList['appAndroid']!))
        DeviceApps.openApp(linkList['appAndroid']!);
      else
        launch(linkList['googlePlay']!, forceSafariVC: false);
    } else if (Platform.isIOS) {
      if (await canLaunch(linkList['appIos']!))
        launch(linkList['appIos']!, forceSafariVC: false);
      else
        launch(linkList['appStore']!, forceSafariVC: false);
    }
  }

  bool checkFunctionalUrl(String url) {
    for (final String subDir in functionalSubDirs) {
      final String funcUrl = widget._ip + subDir;
      if (url == funcUrl)
        return true;
    }
    return false;
  }

  void _onReceiveCode(String? uri) {
    _oaHandler.sendLoginDataToDevice(uri, widget._ip);
  }

  @override
  void dispose() {
    bloc.dispose();
    _blocStateSub.cancel();
    super.dispose();
  }

  Future<void> toSetupPage() async {
    _webViewController.loadUrl('http:/${widget._ip}/webclient/?isMobileApp=true#/settings');
  }

  Future<void> toMainPage() async {
    _webViewController.loadUrl('http:/${widget._ip}/webclient/?isMobileApp=true#/');
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return StreamBuilder<String>(
        stream: bloc.state,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
            Scaffold(
                appBar: SUAppBar(
                    ip: widget._ip,
                    toSetting: toSetupPage,
                    toMain: toMainPage,
                ),
                body: Container(color: SUAppStyle.streamUnlimitedGrey1(), child: SafeArea(
                    top: false,
                    bottom: true,
                    child:Column(
                      children: <Widget>[
                        Expanded(
                            child: WebView(
                              key: _key,
                              onWebViewCreated: (WebViewController controller) {
                                _webViewController = controller;
                              },
                              javascriptMode: JavascriptMode.unrestricted,
                              initialUrl: _url,
                              javascriptChannels: <JavascriptChannel>{
                                JavascriptChannel(
                                    name: javascriptChannelUrl,
                                    onMessageReceived: (JavascriptMessage message) {
                                      _onPathReceived(message.message);
                                    })
                              },
                              navigationDelegate: (NavigationRequest action) =>
                                  _handleRedirection(action),
                            ))
                      ],
                )))));
  }
}