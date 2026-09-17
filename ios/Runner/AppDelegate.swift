import CryptoKit
import Flutter
import Security
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let securityChannelName = "com.theeb.calculator/security"
  private let keyChannelName = "calculator/platform_keys"
  private let keyService = "com.theeb.calculator.vault.keys"
  private var protectedContentEnabled = false
  private var privacyShield: UIVisualEffectView?

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    NotificationCenter.default.addObserver(self, selector: #selector(captureStateChanged), name: UIScreen.capturedDidChangeNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CalculatorSecurity") else { return }
    let messenger = registrar.messenger()
    FlutterMethodChannel(name: securityChannelName, binaryMessenger: messenger).setMethodCallHandler { [weak self] call, result in
      guard call.method == "setProtectedContent", let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? Bool else { result(FlutterMethodNotImplemented); return }
      self?.protectedContentEnabled = enabled; self?.refreshPrivacyShield(); result(nil)
    }
    FlutterMethodChannel(name: keyChannelName, binaryMessenger: messenger).setMethodCallHandler { [weak self] call, result in
      guard let self else { result(FlutterError(code: "KEYCHAIN_FAILURE", message: "Platform key manager unavailable", details: nil)); return }
      do {
        switch call.method {
        case "createVaultKey": result(try self.createVaultKey())
        case "containsVaultKey": result(self.containsVaultKey(call.arguments as? String))
        case "destroyVaultKey": try self.destroyVaultKey(call.arguments as? String); result(nil)
        case "createWrappedDataKey": result(FlutterStandardTypedData(bytes: try self.createWrappedDataKey(call.arguments as? [String: Any])))
        case "unwrapDataKey": result(FlutterStandardTypedData(bytes: try self.unwrapDataKey(call.arguments as? [String: Any])))
        default: result(FlutterMethodNotImplemented)
        }
      } catch { result(FlutterError(code: "KEYCHAIN_FAILURE", message: "Platform key operation failed", details: String(describing: error))) }
    }
  }

  private func createVaultKey() throws -> String {
    var bytes = [UInt8](repeating: 0, count: 32); guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { throw KeyError.randomFailure }
    let handle = "vault-key-\(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())"
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keyService, kSecAttrAccount as String: handle, kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly, kSecValueData as String: Data(bytes)]
    guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else { throw KeyError.storeFailure }; bytes = []; return handle
  }

  private func masterKey(_ handle: String?) throws -> SymmetricKey {
    guard validHandle(handle) else { throw KeyError.invalidHandle }
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keyService, kSecAttrAccount as String: handle!, kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
    var item: CFTypeRef?; guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data, data.count == 32 else { throw KeyError.storeFailure }
    return SymmetricKey(data: data)
  }

  private func createWrappedDataKey(_ args: [String: Any]?) throws -> Data {
    guard let context = (args?["context"] as? FlutterStandardTypedData)?.data, !context.isEmpty else { throw KeyError.invalidArgument }
    let key = try masterKey(args?["handle"] as? String); let dataKey = SymmetricKey(size: .bits256); let sealed = try AES.GCM.seal(dataKey.withUnsafeBytes { Data($0) }, using: key, authenticating: context)
    guard let combined = sealed.combined else { throw KeyError.cryptoFailure }; return combined
  }

  private func unwrapDataKey(_ args: [String: Any]?) throws -> Data {
    guard let wrapped = (args?["wrappedDataKey"] as? FlutterStandardTypedData)?.data, let context = (args?["context"] as? FlutterStandardTypedData)?.data, wrapped.count == 60, !context.isEmpty else { throw KeyError.invalidArgument }
    let box = try AES.GCM.SealedBox(combined: wrapped); let clear = try AES.GCM.open(box, using: masterKey(args?["handle"] as? String), authenticating: context); guard clear.count == 32 else { throw KeyError.cryptoFailure }; return clear
  }

  private func containsVaultKey(_ handle: String?) -> Bool { guard validHandle(handle) else { return false }; let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keyService, kSecAttrAccount as String: handle!, kSecReturnData as String: false]; return SecItemCopyMatching(q as CFDictionary, nil) == errSecSuccess }
  private func destroyVaultKey(_ handle: String?) throws { guard validHandle(handle) else { throw KeyError.invalidHandle }; let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keyService, kSecAttrAccount as String: handle!]; let s = SecItemDelete(q as CFDictionary); guard s == errSecSuccess || s == errSecItemNotFound else { throw KeyError.deleteFailure } }
  private func validHandle(_ handle: String?) -> Bool { guard let handle else { return false }; return handle.range(of: "^vault-key-[a-f0-9]{32}$", options: .regularExpression) != nil }
  private enum KeyError: Error { case randomFailure, storeFailure, invalidHandle, deleteFailure, invalidArgument, cryptoFailure }

  @objc private func captureStateChanged() { refreshPrivacyShield() }
  @objc private func handleWillResignActiveNotification() { if protectedContentEnabled { showPrivacyShield() } }
  @objc private func handleDidBecomeActiveNotification() { refreshPrivacyShield() }
  private func refreshPrivacyShield() { protectedContentEnabled && UIScreen.main.isCaptured ? showPrivacyShield() : hidePrivacyShield() }
  private func showPrivacyShield() { guard privacyShield == nil, let window = window else { return }; let shield = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial)); shield.frame = window.bounds; shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]; window.addSubview(shield); privacyShield = shield }
  private func hidePrivacyShield() { privacyShield?.removeFromSuperview(); privacyShield = nil }
}
