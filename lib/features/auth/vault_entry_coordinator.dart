import 'authenticated_equals_router.dart';
import 'pin_auth_controller.dart';

/// UI-facing boundary that keeps authentication ahead of calculator evaluation.
/// It exposes no user-facing failure reason: rejected candidates fall through.
final class VaultEntryCoordinator {
  const VaultEntryCoordinator({required this.auth, required this.router});

  final PinAuthController auth;
  final AuthenticatedEqualsRouter router;

  Future<bool> get needsEnrollment async => !(await auth.isEnrolled);

  Future<void> enroll(String pin) => auth.enroll(pin);

  /// Returns true only when the protected session was authenticated and opened.
  /// False means the caller must continue ordinary calculator evaluation.
  Future<bool> interceptEquals(String expression) => router.tryOpen(expression);
}
