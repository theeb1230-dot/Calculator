import 'package:calculator_vault/features/auth/platform_pin_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('calculator/pin_auth');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('malformed candidate fails before platform verification', () async {
    var called = false;
    messenger.setMockMethodCallHandler(channel, (call) async { called = true; return false; });
    final store = PlatformPinEnrollmentStore(channel: channel);
    expect(await store.verify('invalid'), isFalse);
    expect(called, isFalse);
  });

  test('verification delegates to protected platform boundary', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isPinEnrolled') return true;
      if (call.method == 'verifyPin') return call.arguments == '654321';
      return null;
    });
    final store = PlatformPinEnrollmentStore(channel: channel);
    expect(await store.isEnrolled, isTrue);
    expect(await store.verify('654321'), isTrue);
    expect(await store.verify('123456'), isFalse);
  });
}
