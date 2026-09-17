import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pin_auth_controller.dart';

/// Stores only a salted slow-KDF verifier in platform-protected storage.
/// The user PIN is never persisted and is never used as a vault content key.
final class SecurePinEnrollmentStore implements PinEnrollmentStore {
  SecurePinEnrollmentStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _recordKey = 'calculator.auth.pin.verifier.v1';
  static const _iterations = 210000;
  static const _saltBytes = 32;
  final FlutterSecureStorage _storage;
  final Pbkdf2 _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: _iterations, bits: 256);

  @override
  Future<bool> get isEnrolled async {
    try {
      return (await _storage.read(key: _recordKey)) != null;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> enroll(String pin) async {
    final salt = Uint8List.fromList(List<int>.generate(_saltBytes, (_) => Random.secure().nextInt(256)));
    final verifier = await _derive(pin, salt);
    final record = jsonEncode({'v': 1, 'i': _iterations, 's': base64Encode(salt), 'd': base64Encode(verifier)});
    await _storage.write(key: _recordKey, value: record);
  }

  @override
  Future<bool> verify(String candidate) async {
    try {
      final encoded = await _storage.read(key: _recordKey);
      if (encoded == null) return false;
      final record = jsonDecode(encoded) as Map<String, dynamic>;
      if (record['v'] != 1 || record['i'] != _iterations) return false;
      final actual = await _derive(candidate, base64Decode(record['s'] as String));
      return _constantTimeEquals(actual, base64Decode(record['d'] as String));
    } on Object {
      return false;
    }
  }

  Future<List<int>> _derive(String pin, List<int> salt) async {
    final key = await _kdf.deriveKey(secretKey: SecretKey(utf8.encode(pin)), nonce: salt);
    return key.extractBytes();
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var i = 0; i < left.length; i++) difference |= left[i] ^ right[i];
    return difference == 0;
  }
}
