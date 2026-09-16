/// Result of handling an equals press at the authentication boundary.
enum SecretTriggerDecision {
  /// Continue with ordinary calculator evaluation.
  evaluateNormally,

  /// Authentication succeeded and the caller may open a protected session.
  authenticated,
}

/// Verifies a user-selected PIN without exposing how it is persisted.
///
/// Production implementations must use a slow password verifier backed by
/// platform-protected state. The PIN must never be a file-encryption key.
abstract interface class PinVerifier {
  Future<bool> verify(String candidate);
}

/// Intercepts calculator input before normal evaluation without revealing
/// whether a failed candidate was intended as a PIN.
final class SecretTriggerGate {
  const SecretTriggerGate(this._verifier);

  final PinVerifier _verifier;

  Future<SecretTriggerDecision> onEquals(String expression) async {
    if (!_isPinCandidate(expression)) {
      return SecretTriggerDecision.evaluateNormally;
    }

    final accepted = await _verifier.verify(expression);
    return accepted
        ? SecretTriggerDecision.authenticated
        : SecretTriggerDecision.evaluateNormally;
  }

  bool _isPinCandidate(String value) {
    // Keep the trigger syntactically indistinguishable from an ordinary
    // positive integer calculation. Length bounds prevent unbounded verifier
    // work and are policy, not a signal shown to the user.
    return RegExp(r'^\d{6,12}$').hasMatch(value);
  }
}
