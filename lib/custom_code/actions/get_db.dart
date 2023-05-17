// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:sembast/sembast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:sembast/sembast_io.dart';
import 'package:encrypt/encrypt.dart' as enc;

var _random = Random.secure();

/// Random bytes generator
Uint8List _randBytes(int length) {
  return Uint8List.fromList(
      List<int>.generate(length, (i) => _random.nextInt(256)));
}

/// Generate an encryption password based on a user input password
///
/// It uses MD5 which generates a 16 bytes blob, size needed for Salsa20
Uint8List _generateEncryptPassword(String password) {
  var blob = Uint8List.fromList(md5.convert(utf8.encode(password)).bytes);
  assert(blob.length == 16);
  return blob;
}

/// Salsa20 based encoder
class _EncryptEncoder extends Converter<Object?, String> {
  final enc.Salsa20 salsa20;

  _EncryptEncoder(this.salsa20);

  @override
  String convert(dynamic input) {
    // Generate random initial value
    final iv = _randBytes(8);
    final ivEncoded = base64.encode(iv);
    assert(ivEncoded.length == 12);

    // Encode the input value
    final encoded = enc.Encrypter(salsa20)
        .encrypt(json.encode(input), iv: enc.IV(iv))
        .base64;

    // Prepend the initial value
    return '$ivEncoded$encoded';
  }
}

/// Salsa20 based decoder
class _EncryptDecoder extends Converter<String, Object?> {
  final enc.Salsa20 salsa20;

  _EncryptDecoder(this.salsa20);

  @override
  dynamic convert(String input) {
    // Read the initial value that was prepended
    assert(input.length >= 12);
    final iv = base64.decode(input.substring(0, 12));

    // Extract the real input
    input = input.substring(12);

    // Decode the input
    var decoded =
        json.decode(enc.Encrypter(salsa20).decrypt64(input, iv: enc.IV(iv)));
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
    return decoded;
  }
}

/// Salsa20 based Codec
class _EncryptCodec extends Codec<Object?, String> {
  late _EncryptEncoder _encoder;
  late _EncryptDecoder _decoder;

  _EncryptCodec(Uint8List passwordBytes) {
    var salsa20 = enc.Salsa20(enc.Key(passwordBytes));
    _encoder = _EncryptEncoder(salsa20);
    _decoder = _EncryptDecoder(salsa20);
  }

  @override
  Converter<String, Object?> get decoder => _decoder;

  @override
  Converter<Object?, String> get encoder => _encoder;
}

SembastCodec getEncryptSembastCodec({required String password}) => SembastCodec(
    signature: 'encrypt',
    codec: _EncryptCodec(_generateEncryptPassword(password)));

class Utils {
  static Future<Database> getDb(String dbName) async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    const secureStorage = FlutterSecureStorage();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random.secure();
    final encryptionKey = await secureStorage.read(key: "$dbName-key");
    if (encryptionKey == null) {
      final key = String.fromCharCodes(Iterable.generate(
          16, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      await secureStorage.write(
        key: "$dbName-key",
        value: key,
      );
    }
    final key = await secureStorage.read(key: "$dbName-key");
    final codec = getEncryptSembastCodec(password: key!);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String dbPath = '$appDocPath/$dbName.db';
    return await dbFactory.openDatabase(dbPath, codec: codec);
  }
}
