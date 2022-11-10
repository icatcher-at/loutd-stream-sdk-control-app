enum BleUpdatedCharacteristic { wifiConnection, readOffset, wifiState }

enum BleSetupState {
  connected,
  fetchPubKey,
  fetchWifiList,
  waitingUserInput,
  settingWifi,
  disconnected,
  finished
}

// This is used to decide if the update of UI is necessary or not for multi-room
// function.
// updataUI: Update the UI because the role of a device was changed. (e.g.
// salve to master or mater to slave)
// updateValue: Trigger an UI update after a role was given to a device for the
// first time.
// neither: Don't trigger an UI update
enum TranscoderUpdateState {
  updateUI,
  updateValue,
  neither
}

// This is used to identify the role of a device for multi-room function.
// disabled: The device's role hasn't been checked yet.
// transcoderTrue: The device is a master.
// transcoderFalse: The device is a slave.
enum TranscoderValues {
  disabled,
  transcoderTrue,
  transcoderFalse
}