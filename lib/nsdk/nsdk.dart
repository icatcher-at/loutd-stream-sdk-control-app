import 'dart:convert' as convert;
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:stream_webview_app/utils/su_global_config.dart';
import 'package:stream_webview_app/utils/su_url_processor.dart';

enum NSDKPowerType {
  offline,
  online,
  reboot,
  networkStandby,
}

class NSDKValueType {
  static const String bool = 'bool_';
  static const String qint8 = 'byte_';
  static const String qint16 = 'i16_';
  static const String qint32 = 'i32_';
  static const String qint64 = 'i64_';
  static const String double = 'double_';
  static const String doubleList = 'doubleList';
  static const String string = 'string_';
  static const String stringList = 'stringList';
  static const String i32List = 'i32List';
  static const String playLogicData = 'playLogicData';
  static const String powerTarget = 'powerTarget';
}

mixin NSDK {
  static dynamic getTypedValue(dynamic nsdkValue) {
    final String value = (nsdkValue as Map<String, dynamic>)['type'] as String;
    switch (value) {
      case NSDKValueType.string:
        return nsdkValue['string_'];
      case NSDKValueType.stringList:
        return nsdkValue['stringList'];
      case NSDKValueType.qint32:
        return nsdkValue['i32_'];
      case NSDKValueType.qint64:
        return nsdkValue['i64_'];
      case NSDKValueType.bool:
        return nsdkValue['bool_'];
      case NSDKValueType.double:
        return nsdkValue['double_'];
      case NSDKValueType.doubleList:
        return nsdkValue['doubleList'];
      case NSDKValueType.i32List:
        return nsdkValue['i32List'];
      case NSDKValueType.playLogicData:
        return nsdkValue['playLogicData'];
      case NSDKValueType.powerTarget:
        return _getPowerType(nsdkValue['powerTarget']['target'] as String);
      default:
        return null;
    }
  }

  static NSDKPowerType _getPowerType(String state) {
    switch (state) {
      case 'offline':
        return NSDKPowerType.offline;
      case 'online':
        return NSDKPowerType.online;
      case 'reboot':
        return NSDKPowerType.reboot;
      case 'networkStandby':
      default:
        return NSDKPowerType.networkStandby;
    }
  }

  static Future<List<dynamic>> getData(
      String rootUrl, String path, String roles) async {
    final Map<String, String> queryParams = <String, String>{
      'path': path,
      'roles': roles,
    };

    final String url = generateUri(rootUrl, '/api/getData', queryParams);

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (nsdkLog)
        developer.log('getData on $path finished', name: 'getData');
      if (response.statusCode == 200) {
        // on success
        return convert.jsonDecode(response.body) as List<dynamic>;
      } else {
        // on fail
        throw Exception('Fail to getData on $path');
      }
    } on Exception {
      rethrow;
    }
  }

  static Future<dynamic> activate(String rootUrl,
      String path, {dynamic value}) async {
    value ??= <String, dynamic>{};
    return setData(rootUrl, path, value, role: 'activate');
  }

  static Future<dynamic> setData(String rootUrl, String path, dynamic value,
      {String? role, String? valueType}) async {
    // Function pre-processing the given data object and performing the setData request
    role ??= 'value';
    dynamic nsdkValue;

    if (valueType == null) {
      switch (value.runtimeType) {
        case bool:
          nsdkValue = _stringToValue(value, NSDKValueType.bool);
          break;
        case String:
          nsdkValue = _stringToValue(value, NSDKValueType.string);
          break;
        case int:
          nsdkValue = _stringToValue(value, NSDKValueType.qint32);
          break;
        default:
          nsdkValue = value;
      }
    } else {
      nsdkValue = _stringToValue(value, valueType);
    }
    return _setData(rootUrl, path, role, nsdkValue);
  }

  static Future<dynamic> _setData(
      String rootUrl, String path, String role, dynamic value) async {
    final Map<String, String> queryParams = <String, String>{
      'path': path,
      'role': role,
      'value': convert.jsonEncode(value)
    };

    final String url = generateUri(rootUrl, 'api/setData', queryParams);

    try {
      final http.Response response = await http.get(Uri.parse(url));
      developer.log('setData on $path finished', name: 'setData');
      if (response.statusCode == 200) {
        // on success
        return convert.jsonDecode(String.fromCharCodes(response.bodyBytes));
      } else {
        // on fail
        throw Exception('Fail to setData on $path');
      }
    } on Exception {
      rethrow;
    }
  }

  static Future<dynamic> modifyQueue(String rootUrl, String queueId,
      {List<Map<String, String>>? subscribe,
      Map<String, String>? unsubscribe,
      Function? success}) async {
    final Map<String, dynamic> queryParams = <String, dynamic>{
      'queueId': queueId,
      'subscribe': convert.jsonEncode(subscribe),
      'unsubscribe': convert.jsonEncode(unsubscribe),
    };

    final String url =
        generateUri(rootUrl, 'api/event/modifyQueue', queryParams);
    try {
      final http.Response response = await http.get(Uri.parse(url));
      return convert.jsonDecode(response.body);
    } on Exception {
      rethrow;
    }
  }

  static Future<List<dynamic>> pollQueue(
      String rootUrl, String queueId, int timeout,
      {Function? success}) async {
    final Map<String, dynamic> queryParams = <String, dynamic>{
      'queueId': queueId,
      'timeout': timeout.toString(),
    };

    final String url = generateUri(rootUrl, 'api/event/pollQueue', queryParams);
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (success != null)
        // ignore: avoid_dynamic_calls
        success(response);
      return convert.jsonDecode(response.body) as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getRows(
      String rootUrl, String path, String roles, int from, int to) async {
    final Map<String, String> queryParams = <String, String>{
      'path': path,
      'roles': roles,
      'from': from.toString(),
      'to': to.toString(),
    };

    final String url = generateUri(rootUrl, '/api/getRows', queryParams);
    print(url);

    try {
      final http.Response response = await http.get(Uri.parse(url));

      developer.log('getRows on $path finished', name: 'getRows');
      if (response.statusCode == 200) {
        // on success
        return convert.jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 500) {
        // on fail, path doesn't exists
        return <String, dynamic>{};
      } else {
        // on fail
        throw Exception('Fail to getData on $path');
      }
    } on Exception {
      rethrow;
    }
  }

  static Map<String, String> createNsdkEventSubscribe(
      String path, String type) {
    return <String, String>{'path': path, 'type': type};
  }

  static dynamic _stringToValue(dynamic value, String type) {
    return <String, dynamic>{'type': type, type: value};
  }
}
