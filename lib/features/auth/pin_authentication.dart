import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Persistence boundary for PIN verification material.
/// Production adapters must place this record in platform-protected storage.
abstract interface class PinCredentialStore {
  Future<PinCredentialRecord?> read();
  Future<void> write(PinCredentialRecord record);
}

final class PinCredentialRecord {
  const PinCredentialRecord({
    required this.salt,
    required this.digest,
    required this.iterations,
  });

  final List<int> salt;
  final List<int> digest;
  final int iterations;
}

/// User-controlled PIN enrollment and verification. The PIN is never retained
/// and is deliberately independent from vault/content encryption keys.
final class PinAuthenticationService {
  PinAuthenticationService(this._store, {Random? random})
      : _random = random ?? Random.secure();

  static const int minLength = 6;
  static const int maxLength = 12;
  static const int defaultIterations = 120000;

  final PinCredentialStore _store;
  final Random _random;

  Future<bool> get isEnrolled async => await _store.read() != null;

  Future<void> enroll(String pin) async {
    _validate(pin);
    final salt = List<int>.generate(32, (_) => _random.nextInt(256));
    final digest = _derive(pin, salt, defaultIterations);
    await _store.write(PinCredentialRecord(
      salt: salt,
      digest: digest,
      iterations: defaultIterations,
    ));
  }

  Future<bool> verify(String candidate) async {
    if (!_isCandidate(candidate)) return false;
    final record = await _store.read();
    if (record == null) return false;
    final actual = _derive(candidate, record.salt, record.iterations);
    return _constantTimeEquals(actual, record.digest);
  }

  void _validate(String pin) {
    if (!_isCandidate(pin)) {
      throw ArgumentError('PIN must contain 6 to 12 digits.');
    }
  }

  bool _isCandidate(String pin) => RegExp(r'^\d{6,12}$').hasMatch(pin);

  List<int> _derive(String pin, List<int> salt, int iterations) {
    var block = <int>[...salt, ...utf8.encode(pin)];
    for (var i = 0; i < iterations; i++) {
      block = sha256.convert(block).bytes;
    }
    return block;
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
