import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

abstract class Bloc {
  void dispose();
}

class DeepLinkBloc extends Bloc {
  //Adding the listener into constructor
  DeepLinkBloc() {
    //Checking application start by deep link
    _startUri().then(_onRedirected);
    //Checking broadcast stream, if deep link was clicked in opened appication
    stream
        .receiveBroadcastStream()
        .listen((dynamic d) => _onRedirected(d.toString()));
  }

  //Event Channel creation
  static const EventChannel stream = EventChannel('suedemoapp.deeplink/events');

  //Method channel creation
  static const MethodChannel platform =
      MethodChannel('suedemoapp.deeplink/channel');

  final StreamController<String> _stateController =
      StreamController<String>.broadcast();

  Stream<String> get state => _stateController.stream;

  Sink<String> get stateSink => _stateController.sink;

  void _onRedirected(String uri) {
    // Here can be any uri analysis, checking tokens etc, if it’s necessary
    // Throw deep link URI into the BloC's stream
    developer.log('DeepLink: Uri which is used to open this app: $uri',
        name: runtimeType.toString());
    stateSink.add(uri);
  }

  @override
  void dispose() {
    _stateController.close();
  }

  Future<String> _startUri() async {
    try {
      return platform.invokeMethod('initialLink').toString();
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }
}
