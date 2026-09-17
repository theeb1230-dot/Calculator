# Device validation queue

Status: `DEVICE_REQUIRED_PENDING`

Before production-signing claims or store distribution, validate on physical Android and iOS devices:

- Android Keystore persistence and StrongBox preference/fallback across restart.
- iOS Keychain persistence and no-codesign development limitations.
- PIN enrollment verifier persistence in platform-protected storage once native adapters are enabled.
- lifecycle/background relock and screen-capture protection behavior.
- no Gallery copy for future private-camera imports.

These checks do not replace automated tests and do not block software-only CI unless a platform implementation fails closed incorrectly.
