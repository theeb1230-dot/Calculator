import 'secret_trigger_gate.dart';

/// Persistence boundary for user-selected PIN enrollment.
///
/// Production implementations must persist only a slow password-verifier
/// representation in platform-protected storage. The PIN is never a file key.
abstract interface class PinEnrollmentStore implements PinVerifier {
  Future<bool> get isEnrolled;
  Future<void> enroll(String pin);
}

enum PinRouteDecision { evaluateNormally, openProtectedSession }

/// Coordinates enrollment and the calculator's secret authentication boundary.
final class PinAuthController {
  PinAuthController(this._store) : _gate = SecretTriggerGate(_store);

  final PinEnrollmentStore _store;
  final SecretTriggerGate _gate;

  Future<bool> get isEnrolled => _store.isEnrolled;

  Future<void> enroll(String pin) async {
    if (!RegExp(r'^\d{6,12}$').hasMatch(pin)) {
      throw const FormatException('PIN must contain 6 to 12 digits.');
    }
    await _store.enroll(pin);
  }

  Future<PinRouteDecision> onEquals(String expression) async {
    if (!await _store.isEnrolled) {
      return PinRouteDecision.evaluateNormally;
    }
    final decision = await _gate.onEquals(expression);
    return decision == SecretTriggerDecision.authenticated
        ? PinRouteDecision.openProtectedSession
        : PinRouteDecision.evaluateNormally;
  }
}
