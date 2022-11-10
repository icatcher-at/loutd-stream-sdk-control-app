//Parameter of JavascriptChannel, which is used to pass data from webview to flutter app

const String bleServiceType = '_sueS800Device._tcp';
const String multiRoomServiceType = '_sueGrouping._tcp';
const String DefaultModelName = "DefaultModel";
const String StreamAmpModelName = "StreamAmp Module";

const String wifiStateIdle = 'idle';
const String wifiStateConnecting = 'connecting';
const String wifiStateConnected = 'connected';
const String wifiStateDisconnected = 'disconnected';
const String wifiStatePasswordNotCorrect = 'password_not_correct';
const String wifiStateNetworkNotFound = 'network_not_found';
const String wifiStateJsonError = 'json_error';

const String javascriptChannelUrl = 'PrintData';

const String oauthUrlKey = 'url';
const String oauthPubkeyKey = 'key';
const String oauthSetDataPath = 'path';
const String oauthRedirectUrlKey = 'redirect_uri';
const String oauthAuthcodeKey = 'code';
const String oauthStateKey = 'state';
const String oauthTypeKey = 'type';
const String oauthTypeVal = 'oauth2AuthResponse';
const String oauthAuthResponseKey = 'oauth2AuthResponse';
const String oauthSendEncryptedCodeKey = 'encryptedCode';
const String oauthSendRedirectUriKey = 'redirectUri';
const String oauthSendStateKey = 'state';
const String oauthSendAesKey = 'aesKey';

// API
const String volume_path = 'player:volume';
const String playerValuePath = 'player:player/data/value';
const String hostOverTempPath = 'plateamp:hostOverTemp';
const String clientOverTempPath = 'plateamp:clientOverTemp';
const String default_roles = '@all';
const String value_roles = 'value';
const String activate_roles = 'activate';
const String itemTypeKey = 'itemType';
const String itemValueKey = 'itemValue';
const String valueType = 'type';
const String multi_room_member_path = 'grouping:members';
const String grouping_request_path = 'grouping:request';
const String power_manager_path = 'powermanager:target';
const String power_manager_online_path = 'powermanager:goOnline';
const String power_manager_networkstandby_path = 'powermanager:goNetworkStandby';

// Button code
const int keyVolumeUp = 115;
const int keyVolumeDown = 114;
const int keyVolumeMute = 113;
const int keyPrevious = 165;
const int keyPlayPause = 164;
const int keyNext = 163;
const int keySleep = 142;
const int keyShuffle = 20;
const int keyRepeat = 19;
