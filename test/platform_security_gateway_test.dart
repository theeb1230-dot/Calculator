import 'package:calculator_vault/platform/platform_security_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test.security');
  const gateway = PlatformSecurityGateway(channel: channel);

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends explicit protected-content state', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    await gateway.setProtectedContent(true);
    await gateway.setProtectedContent(false);

    expect(calls, hasLength(2));
    expect(calls.first.method, 'setProtectedContent');
    expect(calls.first.arguments, {'enabled': true});
    expect(calls.last.arguments, {'enabled': false});
  });
}
