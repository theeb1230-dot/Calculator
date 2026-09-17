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
    let securityChannel = FlutterMethodChannel(name: securityChannelName, binaryMessenger: messenger)
    securityChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setProtectedContent", let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? Bool else {
        result(FlutterMethodNotImplemented); return
      }
      self?.protectedContentEnabled = enabled; self?.refreshPrivacyShield(); result(nil)
    }
    let keyChannel = FlutterMethodChannel(name: keyChannelName, binaryMessenger: messenger)
    keyChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(FlutterError(code: "KEYCHAIN_FAILURE", message: "Platform key manager unavailable", details: nil)); return }
      do {
        switch call.method {
        case "createVaultKey": result(try self.createVaultKey())
        case "containsVaultKey": result(self.containsVaultKey(call.arguments as? String))
        case "destroyVaultKey": try self.destroyVaultKey(call.arguments as? String); result(nil)
        case "unwrapDataKey": result(FlutterError(code: "NOT_IMPLEMENTED", message: "Native authenticated unwrap is not wired yet", details: nil))
        default: result(FlutterMethodNotImplemented)
        }
      } catch {
        result(FlutterError(code: "KEYCHAIN_FAILURE", message: "Platform key operation failed", details: String(describing: error)))
      }
    }
  }

  private func createVaultKey() throws -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { throw KeyError.randomFailure }
    let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    let handle = "vault-key-\(id)"
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keyService,
      kSecAttrAccount as String: handle,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      kSecValueData as String: Data(bytes)
    ]
    guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else { throw KeyError.storeFailure }
    return handle
  }

  private func containsVaultKey(_ handle: String?) -> Bool {
    guard validHandle(handle) else { return false }
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keyService, kSecAttrAccount as String: handle!, kSecReturnData as String: false]
    return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
  }

  private func destroyVaultKey(_ handle: String?) throws {
    guard validHandle(handle) else { throw KeyError.invalidHandle }
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keyService, kSecAttrAccount as String: handle!]
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeyError.deleteFailure }
  }

  private func validHandle(_ handle: String?) -> Bool {
    guard let handle else { return false }
    return handle.range(of: "^vault-key-[a-f0-9]{32}$", options: .regularExpression) != nil
  }

  private enum KeyError: Error { case randomFailure, storeFailure, invalidHandle, deleteFailure }

  @objc private func captureStateChanged() { refreshPrivacyShield() }
  @objc private func handleWillResignActiveNotification() { if protectedContentEnabled { showPrivacyShield() } }
  @objc private func handleDidBecomeActiveNotification() { refreshPrivacyShield() }
  private func refreshPrivacyShield() { protectedContentEnabled && UIScreen.main.isCaptured ? showPrivacyShield() : hidePrivacyShield() }
  private func showPrivacyShield() {
    guard privacyShield == nil, let window = window else { return }
    let shield = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial)); shield.frame = window.bounds; shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]; window.addSubview(shield); privacyShield = shield
  }
  private func hidePrivacyShield() { privacyShield?.removeFromSuperview(); privacyShield = nil }
}
