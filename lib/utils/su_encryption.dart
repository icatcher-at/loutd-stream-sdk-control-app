import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:pointycastle/export.dart';

mixin SUEncryption {
  static Uint8List rsaBleEnctypt(String pubKey, Uint8List dataToEncrypt) {
    final encrypt_lib.RSAKeyParser parser = encrypt_lib.RSAKeyParser();
    final RSAAsymmetricKey asymKey = parser.parse(pubKey);
    final RSAPublicKey myPublic =
        RSAPublicKey(asymKey.modulus!, asymKey.exponent!);

    final OAEPEncoding encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt
    return _processInBlocks(encryptor, dataToEncrypt);
  }

  static Uint8List _processInBlocks(
      AsymmetricBlockCipher engine, Uint8List input) {
    final int numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final Uint8List output = Uint8List(numBlocks * engine.outputBlockSize);

    int inputOffset = 0;
    int outputOffset = 0;
    while (inputOffset < input.length) {
      final int chunkSize =
          (inputOffset + engine.inputBlockSize <= input.length)
              ? engine.inputBlockSize
              : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }
}
