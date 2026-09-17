import 'package:flutter/services.dart';

import 'pin_auth_controller.dart';

/// PIN enrollment backed by platform-protected credential storage.
///
/// Native implementations own salt + slow verifier derivation. Dart never
/// persists the PIN and this channel is deliberately separate from vault keys.
final class PlatformPinEnrollmentStore implements PinEnrollmentStore {
  PlatformPinEnrollmentStore({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('calculator/pin_auth');

  final MethodChannel _channel;

  @override
  Future<bool> get isEnrolled async =>
      await _channel.invokeMethod<bool>('isPinEnrolled') ?? false;

  @override
  Future<void> enroll(String pin) async {
    if (!RegExp(r'^\d{6,12}$').hasMatch(pin)) {
      throw const FormatException('PIN must contain 6 to 12 digits.');
    }
    await _channel.invokeMethod<void>('enrollPin', pin);
  }

  @override
  Future<bool> verify(String candidate) async {
    if (!RegExp(r'^\d{6,12}$').hasMatch(candidate)) return false;
    return await _channel.invokeMethod<bool>('verifyPin', candidate) ?? false;
  }
}
