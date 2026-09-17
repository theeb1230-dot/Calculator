/// Platform-backed PIN credential boundary.
///
/// Implementations own salt generation, a maintained slow password KDF, and
/// storage of verifier material in platform-protected storage. Dart never
/// persists plaintext PINs and the PIN is never a vault/content encryption key.
abstract interface class PinCredentialBackend {
  Future<bool> get isEnrolled;

  /// Creates verifier material for a user-selected PIN. Must fail closed if
  /// protected storage or the platform KDF is unavailable.
  Future<void> enroll(String pin);

  /// Verifies without exposing verifier material to the UI layer.
  Future<bool> verify(String candidate);
}

final class PinAuthenticationService {
  const PinAuthenticationService(this._backend);

  static const int minLength = 6;
  static const int maxLength = 12;

  final PinCredentialBackend _backend;

  Future<bool> get isEnrolled => _backend.isEnrolled;

  Future<void> enroll(String pin) async {
    if (!_isCandidate(pin)) {
      throw ArgumentError('PIN must contain 6 to 12 digits.');
    }
    await _backend.enroll(pin);
  }

  Future<bool> verify(String candidate) async {
    if (!_isCandidate(candidate)) return false;
    if (!await _backend.isEnrolled) return false;
    return _backend.verify(candidate);
  }

  bool _isCandidate(String value) => RegExp(r'^\d{6,12}$').hasMatch(value);
}
