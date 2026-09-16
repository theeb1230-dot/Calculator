import 'package:flutter/services.dart';

/// Narrow bridge for platform-specific sensitive-surface protection.
///
/// This is defense-in-depth only. Android maps this to FLAG_SECURE. iOS will
/// map it to capture detection and obscuring, because iOS cannot universally
/// prohibit screenshots.
final class PlatformSecurityGateway {
  const PlatformSecurityGateway({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.theeb.calculator/security');

  final MethodChannel _channel;

  Future<void> setProtectedContent(bool enabled) {
    return _channel.invokeMethod<void>(
      'setProtectedContent',
      <String, Object>{'enabled': enabled},
    );
  }
}
