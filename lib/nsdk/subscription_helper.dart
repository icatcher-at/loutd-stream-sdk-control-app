import 'dart:developer' as developer;

import 'package:stream_webview_app/nsdk/nsdk.dart';

class NSDKEventSubscribeTypes {
  static const String item = 'item';
  static const String rows = 'rows';
  static const String itemWithValue = 'itemWithValue';
  static const String rowsWithRoles = 'rowsWithRoles';
  // DOES NOT WORK ON ALL StreamSDK's
  static const String itemWithRoles = 'itemWithRoles';
}

class NSDKRowEventType {
  static const String add = 'item';
  static const String remove = 'remove';
  static const String update = 'update';
}

class SubscriptionHelper {
  // Instantiate only one instance of the class and avoid exporting the class itself to ensure the singleton pattern
  factory SubscriptionHelper(String ip) {
    return _cache.putIfAbsent(ip, () => SubscriptionHelper._internal(ip));
  }

  SubscriptionHelper._internal(this._rootUrl) {
    _resubscribe = false;
    _queueId = '';
    _eventHandlers = <String,
        Map<String, List<Function(dynamic)>>>{}; // path, type, and handlers
    queueIteration();
  }

  static final Map<String, SubscriptionHelper> _cache =
      <String, SubscriptionHelper>{};

  late String _rootUrl;
  late bool _resubscribe;
  late String _queueId;
  late Map<String, Map<String, List<Function(dynamic)>>> _eventHandlers;

  Future<dynamic> queueIteration() async {
    dynamic ret = dynamic;
    if (_queueId == '' || _resubscribe == true) {
      try {
        ret = await _renewQueue();
        queueIteration();
      } catch (e) {
        Future<void>.delayed(const Duration(milliseconds: 1000), queueIteration);
      }
    } else {
      try {
        ret = await _pollQueue();
        queueIteration();
      } catch (e) {
        Future<void>.delayed(const Duration(milliseconds: 1000), queueIteration);
      }
    }
    return ret;
  }

  Future<dynamic> _renewQueue() async {
    _resubscribe = false;
    final List<Map<String, String>> subscribe = <Map<String, String>>[];

    for (final String pathKey in _eventHandlers.keys) {
      for (final String typeKey in _eventHandlers[pathKey]!.keys) {
        subscribe.add(<String, String>{'path': pathKey, 'type': typeKey});
      }
    }

    final dynamic ret =
        await NSDK.modifyQueue(_rootUrl, _queueId, subscribe: subscribe);
    _queueId = ret as String;
    return ret;
  }

  Future<dynamic> _pollQueue() async {
    final List<dynamic> data = await NSDK
        .pollQueue(_rootUrl, _queueId, 1500)
        .onError((dynamic error, dynamic stackTrace) {
      _queueFailed();
      return <dynamic>[];
    });
    return _handleEvents(data);
  }

  Future<Map<String, dynamic>> subscribe(
      String path, String type, Function(dynamic) handler) async {
    developer.log('Subscribe path: $path type: $type', name: 'subscribe');
    bool added = false;

    // Assign the handlers
    if (!_eventHandlers.containsKey(path)) {
      // This path has not been subscribed yet
      _eventHandlers[path] = <String, List<Function(dynamic)>>{};
      _eventHandlers[path]![type] = <Function(dynamic)>[];
      _eventHandlers[path]![type]!.add(handler);
      added = true;
    } else if (_eventHandlers[path] != null &&
        _eventHandlers[path]!.containsKey(type)) {
      // This path already exist, but  with other type
      _eventHandlers[path]![type] = <Function(dynamic)>[];
      _eventHandlers[path]![type]!.add(handler);
      added = true;
    } else {
      // This path with given type already exists. Add handler but do not modify queue
      _eventHandlers[path]![type]!.add(handler);
    }

    if (_queueId == '') {
      _resubscribe = true;
    } else if (added) {
      final List<Map<String, String>> subscribe = <Map<String, String>>[];
      subscribe.add(<String, String>{'path': path, 'type': type});
      await NSDK
          .modifyQueue(_rootUrl, _queueId,
              subscribe: subscribe,
              unsubscribe: <String, String>{},
              success: handler)
          .onError((Object? error, StackTrace stackTrace) => _queueFailed());
    }

    return <String, dynamic>{'path': path, 'type': type, 'handler': handler};
  }

  void unsubscribe(Map<String, dynamic> eventHandler) {
    final String path = eventHandler['path'] as String;
    final String type = eventHandler['type'] as String;
    bool removed = false;

    if (_eventHandlers[path] != null && _eventHandlers[path]![type] != null) {
      // ignore: avoid_dynamic_calls
      for (int i = 0; i < _eventHandlers[path]![type]!.length; i++) {
        if (_eventHandlers[path]![type]![i] ==
            eventHandler['handler'] as Function) {
          removed = true;
          break;
        }
      }
      if (_eventHandlers[path]![type]!.isEmpty) {
        // last path of type 'type' was removed,
        // remove also from queue
        removed = true;
        _eventHandlers[path]!.remove(type);
      }
      if (_eventHandlers[path]!.keys.isEmpty) {
        _eventHandlers.remove(path);
      }
    }

    if (_queueId == '') {
      _resubscribe = true;
    } else if (removed) {
      NSDK.modifyQueue(_rootUrl, _queueId, unsubscribe: <String, String>{
        'path': path,
        'type': type
      }).onError((Object? error, StackTrace stackTrace) => _queueFailed());
    }
  }

  Future<List<dynamic>> _handleEvents(List<dynamic> events) async {
    String path = '';
    final List<dynamic> res = <dynamic>[];
    for (int i = 0; i < events.length; i++) {
      // ignore: avoid_dynamic_calls
      path = events[i]['path'] as String;
      // copy of available handlers for the path, so handle
      // method can call unsubscribe without breaking iteration
      final List<Function(dynamic)> handlers =
          <Function(dynamic)>[]; // type, handler

      for (final String keyType in _eventHandlers[path]!.keys) {
        // ignore: avoid_function_literals_in_foreach_calls
        _eventHandlers[path]![keyType]!.forEach((Function(dynamic) element) {
          handlers.add(element);
        });
      }

      for (final Function(dynamic) handler in handlers) {
        res.add(handler(events[i]));
      }
    }

    return res;
  }

  void _queueFailed() {
    _queueId = '';
  }
}
