import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/nsdk/subscription_helper.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:stream_webview_app/utils/su_enum.dart';

class Device {
  Device(
      {required this.port,
      required this.model,
      required this.name,
      required this.ip,
      required this.uuid,
      required this.manufacturer,
      required this.transcoder}) {
    _helper = SubscriptionHelper(ip!);
    _newSubscriptionEvents = <Map<String, dynamic>>[];
    _getPowerState();
  }

  final String? name, ip, uuid, manufacturer, model;
  final int port;

  late TranscoderValues? transcoder;

  late SubscriptionHelper _helper;
  late List<Map<String, dynamic>> _newSubscriptionEvents;
  NSDKPowerType? _powerManagerState;

  Future<void> performSubscribe() async {
    final Map<String, dynamic> subscription = await _helper.subscribe(
        power_manager_path, NSDKEventSubscribeTypes.itemWithValue, updatePowerState);
    _newSubscriptionEvents.add(subscription);
  }

  void performUnsubscribe() {
    // ignore: avoid_function_literals_in_foreach_calls
    _newSubscriptionEvents.forEach((Map<String, dynamic> subscription) {
      _helper.unsubscribe(subscription);
    });
  }

  void updatePowerState(dynamic item) {
    final Map<String, dynamic> val = item as Map<String, dynamic>;
    if (val.containsKey(itemTypeKey) &&
        val[itemTypeKey] == NSDKRowEventType.update &&
        val.containsKey(itemValueKey)) {
      final NSDKPowerType stateVal
      = NSDK.getTypedValue(val[itemValueKey]) as NSDKPowerType;
      _powerManagerState = stateVal;
    }
  }

  Future<void> _getPowerState() async {
    final List<dynamic> result =
    await NSDK.getData(ip!, power_manager_path, 'value');
    final NSDKPowerType stateVal = NSDK.getTypedValue(result[0]) as NSDKPowerType;
    _powerManagerState = stateVal;
  }

  bool isOnline() {
    if(_powerManagerState == null)
      return false;

    if (_powerManagerState == NSDKPowerType.online) {
      return true;
    } else {
      return false;
    }
  }

  String getActivatePath() {
    if(_powerManagerState == null)
      return power_manager_online_path;

    if (_powerManagerState == NSDKPowerType.online) {
      return power_manager_networkstandby_path;
    } else {
      return power_manager_online_path;
    }
  }
}
