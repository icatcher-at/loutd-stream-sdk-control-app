import 'dart:async';

import 'dart:io';
import 'dart:typed_data';

import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/su_url_constants.dart';

class WebSocketHandler {
  factory WebSocketHandler() {
    return _instance;
  }

  WebSocketHandler._privateConstructor() {
    running = false;
  }

  late HttpServer server;
  late bool running;
  late WebSocket currentWebSocket;

  static final WebSocketHandler _instance = WebSocketHandler._privateConstructor();

  Future<void> startWebSocket() async {
    final WebSocketTransformer webSocketTransformer = WebSocketTransformer();
    server = await HttpServer.bind(InternetAddress.anyIPv4, 4567);
    server.transform(webSocketTransformer).listen((WebSocket webSocket) {
      running = true;
      currentWebSocket = webSocket;
      checkSpotify();
      webSocket.listen( (message) {
        print(message);
      },
          onDone: () {
            running = false;
            },
          onError: (error) {
            running = false;
          } );
    });
  }
  Future<void> checkSpotify() async {
    if (running) {
      if (Platform.isAndroid) {
        if (await DeviceApps.isAppInstalled(spotifyAppLinkList['appAndroid']!))
          broadCast('spotifyStatus:installed');
        else
          broadCast('spotifyStatus:uninstalled');
      } else if (Platform.isIOS) {
        if (await canLaunch(spotifyAppLinkList['appIos']!))
          broadCast('spotifyStatus:installed');
        else
          broadCast('spotifyStatus:uninstalled');
      }
    }
  }
  Future<void> broadCast(String message) async {
    currentWebSocket.add(message);
  }

  Future<void> stopServer() async {
    await server.close();
    running = false;
  }

}
