import 'pin_auth_controller.dart';
import 'protected_session.dart';

/// Authentication-first equals router used by the calculator UI boundary.
/// A rejected candidate is deliberately indistinguishable from normal input.
final class AuthenticatedEqualsRouter {
  const AuthenticatedEqualsRouter(this.auth, this.session);

  final PinAuthController auth;
  final ProtectedSession session;

  Future<bool> tryOpen(String expression) async {
    final decision = await auth.onEquals(expression);
    if (decision != PinRouteDecision.openProtectedSession) return false;
    session.unlock();
    return true;
  }
}
