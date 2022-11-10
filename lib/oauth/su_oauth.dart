import 'dart:core';
import 'dart:developer' as developer;

import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:stream_webview_app/nsdk/nsdk.dart';
import 'package:stream_webview_app/utils/su_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/su_url_processor.dart';

class OAuthHandler {
  OAuthHandler(this._dataPath, this._deviceIp);

  final String _deviceIp;
  final String? _dataPath;

  String? _authEndPointUrl;
  String? _rsaPubKey;
  String? _redirectUrl;

  Uri _encodeUri() {
    final Uri uri = Uri.parse(_authEndPointUrl!);
    final String authority = uri.authority;
    final String path = uri.path;
    final Map<String, String> qmap = uri.queryParameters;

    final Map<String, String> test = <String, String>{};
    qmap.forEach((String k, String v) => k != oauthRedirectUrlKey
        ? test[k] = v
        : test[oauthRedirectUrlKey] = Uri.encodeFull(v));
    return Uri.https(authority, path, test);
  }

  Map<String, String> _encrypt(String code, String pubKey, String state) {
    const int AES_BLOC_SIZE = 16;
    final encrypt_lib.Key aesKey = encrypt_lib.Key.fromLength(
        32); // should be something with a length of 32

    final encrypt_lib.IV aesIv = encrypt_lib.IV.fromLength(AES_BLOC_SIZE);
    final encrypt_lib.Encrypter aesEncrypter = encrypt_lib.Encrypter(encrypt_lib
        .AES(aesKey, mode: encrypt_lib.AESMode.cbc, padding: 'PKCS7'));
    final encrypt_lib.RSAKeyParser parser = encrypt_lib.RSAKeyParser();

    final RSAAsymmetricKey asymKey = parser.parse(pubKey);
    final RSAPublicKey myPublic =
        RSAPublicKey(asymKey.modulus!, asymKey.exponent!);
    final encrypt_lib.Encrypter rasEncrypter = encrypt_lib.Encrypter(encrypt_lib
        .RSA(publicKey: myPublic, encoding: encrypt_lib.RSAEncoding.OAEP));

    final String encryptedCode = aesEncrypter.encrypt(code, iv: aesIv).base64;
    final String encryptedAesKey =
        rasEncrypter.encryptBytes(aesKey.bytes).base64;

    final Map<String, String> loginInfo = <String, String>{};

    loginInfo[oauthSendEncryptedCodeKey] = '${aesIv.base64}.$encryptedCode';
    loginInfo[oauthSendStateKey] = state;
    loginInfo[oauthSendAesKey] = encryptedAesKey;
    loginInfo[oauthSendRedirectUriKey] = _redirectUrl!;

    return loginInfo;
  }

  Future<void> startProcess() async {
    bool isExcutable = await _fetchOAuthData();
    if (isExcutable) {
      _redirectToOAuth();
    }
  }

  Future<bool> _fetchOAuthData() async {
      developer.log('Start to fetch data from $_dataPath',
          name: runtimeType.toString());

      final dynamic result =
        await NSDK.setData(_deviceIp, _dataPath!, 0, role: "activate");

      _authEndPointUrl = result['url'] as String;
      _rsaPubKey = result['rsaPubKey'] as String;
      _redirectUrl = result['redirectUri'] as String;

      if (_authEndPointUrl != null
          && _rsaPubKey != null
          && _redirectUrl != null) {
        return true;
      } else {
        return false;
      }
  }

  void _redirectToOAuth() {
    developer.log('Oauth: Url to the endpoint: $_authEndPointUrl',
        name: runtimeType.toString());
    developer.log('RSA public key: $_rsaPubKey', name: runtimeType.toString());

    final Uri encodedUrl = _encodeUri();

    launch(encodedUrl.toString(), forceSafariVC: false);
  }

  void sendLoginDataToDevice(String? uri, String deviceIP) {
    developer.log('DeepLink: Uri obtained from the stream is ${uri ?? 'empty'}',
        name: runtimeType.toString());
    if (uri != null) {
      final Uri parsedUri = Uri.parse(uri);

      final String code = extractFromUri(parsedUri, oauthAuthcodeKey)!;
      final String state = extractFromUri(parsedUri, oauthStateKey)!;
      final Map<String, String> loginData = _encrypt(code, _rsaPubKey!, state);
      final Map<String, Object> value = <String, Object>{};
      value[oauthTypeKey] = oauthTypeVal;
      value[oauthAuthResponseKey] = loginData;

      developer.log('Uri with encrypted data for oauth',
          name: runtimeType.toString());
      NSDK.setData(deviceIP, _dataPath!, value, role: value_roles);
      //http://192.168.12.182/api/setData?path=firmwareupdate%3AstartLocalUpdate&role=activate&value=%7B%7D&_nocache=1623224110674\

    } else {
      return;
    }
  }
}
