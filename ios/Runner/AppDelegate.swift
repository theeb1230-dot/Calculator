import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let securityChannelName = "com.theeb.calculator/security"
  private var protectedContentEnabled = false
  private var privacyShield: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(captureStateChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CalculatorSecurity") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: securityChannelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setProtectedContent",
            let args = call.arguments as? [String: Any],
            let enabled = args["enabled"] as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.protectedContentEnabled = enabled
      self?.refreshPrivacyShield()
      result(nil)
    }
  }

  @objc private func captureStateChanged() {
    refreshPrivacyShield()
  }

  @objc private func applicationWillResignActive() {
    if protectedContentEnabled { showPrivacyShield() }
  }

  @objc private func applicationDidBecomeActive() {
    refreshPrivacyShield()
  }

  private func refreshPrivacyShield() {
    let shouldObscure = protectedContentEnabled && UIScreen.main.isCaptured
    shouldObscure ? showPrivacyShield() : hidePrivacyShield()
  }

  private func showPrivacyShield() {
    guard privacyShield == nil, let window = window else { return }
    let shield = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    shield.frame = window.bounds
    shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(shield)
    privacyShield = shield
  }

  private func hidePrivacyShield() {
    privacyShield?.removeFromSuperview()
    privacyShield = nil
  }
}
