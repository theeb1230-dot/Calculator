import 'package:calculator_vault/features/auth/key_management.dart';
import 'package:calculator_vault/features/auth/platform_key_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('calculator/platform_keys_test');
  const handle = VaultKeyHandle('vault-key-0123456789abcdef0123456789abcdef');

  tearDown(() async => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

  test('accepts only opaque platform key handles', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async => call.method == 'createVaultKey' ? handle.id : null);
    expect((await PlatformVaultKeyManager(channel: channel).createVaultKey()).id, handle.id);
  });

  test('rejects raw secret-like platform response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async => '0123456789abcdef');
    expect(PlatformVaultKeyManager(channel: channel).createVaultKey(), throwsStateError);
  });

  test('wrapped key creation requires authenticated context', () async {
    final manager = PlatformVaultKeyManager(channel: channel);
    expect(manager.createWrappedDataKey(handle: handle, context: Uint8List(0)), throwsArgumentError);
  });

  test('authenticated unwrap rejects malformed wrapped key before native call', () async {
    final manager = PlatformVaultKeyManager(channel: channel);
    expect(manager.unwrapDataKey(handle: handle, wrappedDataKey: WrappedDataKey(Uint8List(59)), context: Uint8List.fromList([2])), throwsArgumentError);
  });

  test('authenticated unwrap fails closed on invalid platform output', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async => Uint8List(31));
    final manager = PlatformVaultKeyManager(channel: channel);
    expect(manager.unwrapDataKey(handle: handle, wrappedDataKey: WrappedDataKey(Uint8List(60)), context: Uint8List.fromList([2])), throwsStateError);
  });
}
