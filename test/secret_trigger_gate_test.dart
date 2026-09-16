import 'package:calculator_vault/features/auth/secret_trigger_gate.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakePinVerifier implements PinVerifier {
  _FakePinVerifier(this.accepted);

  final String accepted;
  int calls = 0;

  @override
  Future<bool> verify(String candidate) async {
    calls++;
    return candidate == accepted;
  }
}

void main() {
  group('SecretTriggerGate', () {
    test('authenticates only through injected verifier', () async {
      final verifier = _FakePinVerifier('654321');
      final gate = SecretTriggerGate(verifier);

      expect(
        await gate.onEquals('654321'),
        SecretTriggerDecision.authenticated,
      );
      expect(verifier.calls, 1);
    });

    test('wrong PIN is indistinguishable from normal evaluation', () async {
      final verifier = _FakePinVerifier('654321');
      final gate = SecretTriggerGate(verifier);

      expect(
        await gate.onEquals('123456'),
        SecretTriggerDecision.evaluateNormally,
      );
      expect(verifier.calls, 1);
    });

    test('ordinary expressions never reach PIN verifier', () async {
      final verifier = _FakePinVerifier('654321');
      final gate = SecretTriggerGate(verifier);

      for (final expression in ['2+2', '50%', '12345', '1234567890123']) {
        expect(
          await gate.onEquals(expression),
          SecretTriggerDecision.evaluateNormally,
        );
      }
      expect(verifier.calls, 0);
    });

    test('contains no production default PIN behavior', () async {
      final verifier = _FakePinVerifier('654321');
      final gate = SecretTriggerGate(verifier);

      expect(
        await gate.onEquals('280126'),
        SecretTriggerDecision.evaluateNormally,
      );
    });
  });
}
