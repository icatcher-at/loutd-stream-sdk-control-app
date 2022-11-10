import 'package:flutter/material.dart';
import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/nsdk/subscription_helper.dart';
import 'package:stream_webview_app/style/su_app_style.dart';
import 'package:stream_webview_app/utils/su_constants.dart';

const int volume_step = 5;

class SUCustomSlider extends StatefulWidget {
  const SUCustomSlider({Key? key, required this.ip, this.invertColor = false})
      : super(key: key);

  final String ip;
  final bool invertColor;

  @override
  _SUCustomSliderState createState() => _SUCustomSliderState();
}

class _SUCustomSliderState extends State<SUCustomSlider> {
  late SubscriptionHelper _helper;
  late double _currentSliderValue;
  late bool _isTouched;
  late List<Map<String, dynamic>> _newSubscriptionEvents;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = 0;
    _newSubscriptionEvents = <Map<String, dynamic>>[];
    _helper = SubscriptionHelper(widget.ip);
    _isTouched = false;
    _getVolume();
    _performSubscribe();
  }

  @override
  void dispose() {
    super.dispose();
    _performUnsubscribe();
  }

  Future<void> _performSubscribe() async {
    final Map<String, dynamic> subscription = await _helper.subscribe(
        volume_path, NSDKEventSubscribeTypes.itemWithValue, updateVolume);
    _newSubscriptionEvents.add(subscription);
  }

  void _performUnsubscribe() {
    // ignore: avoid_function_literals_in_foreach_calls
    _newSubscriptionEvents.forEach((Map<String, dynamic> subscription) {
      _helper.unsubscribe(subscription);
    });
  }

  void updateVolume(dynamic item) {
    if (_isTouched) {
      return;
    }

    final Map<String, dynamic> val = item as Map<String, dynamic>;
    if (val.containsKey(itemTypeKey) &&
            val[itemTypeKey] == NSDKRowEventType.update &&
            val.containsKey(itemValueKey) ||
        mounted) {
      final int volumeVal = NSDK.getTypedValue(val[itemValueKey]) as int;
      setState(() {
        _currentSliderValue = volumeVal.toDouble();
      });
    }
  }

  Future<void> _getVolume() async {
    final List<dynamic> result =
        await NSDK.getData(widget.ip, volume_path, 'value');
    final int intVal = NSDK.getTypedValue(result[0]) as int;
    if (mounted) {
      setState(() {
        _currentSliderValue = intVal.toDouble();
      });
    }
  }

  Future<void> _onChange(double value) async {
    _isTouched = true;

    setState(() {
      _currentSliderValue = value;
    });
    NSDK.setData(widget.ip, volume_path, value.round());
  }

  void _onChangeEnd(double value) {
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      _isTouched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: widget.invertColor
              ? SUAppStyle.streamUnlimitedGrey2()
              : SUAppStyle.streamUnlimitedGreen(),
          inactiveTrackColor: widget.invertColor
              ? SUAppStyle.streamUnlimitedGreen()
              : SUAppStyle.streamUnlimitedGrey2(),
          trackHeight: 4.0,
          thumbColor: widget.invertColor
              ? SUAppStyle.streamUnlimitedGrey2()
              : SUAppStyle.streamUnlimitedGreen(),
          overlayColor: widget.invertColor
              ? SUAppStyle.streamUnlimitedGreen()
              : SUAppStyle.streamUnlimitedGrey2(),
        ),
        child: Slider(
            value: _currentSliderValue,
            label: _currentSliderValue.round().toString(),
            max: 100,
            min: 0,
            onChanged: _onChange,
            onChangeEnd: _onChangeEnd));
  }
}
