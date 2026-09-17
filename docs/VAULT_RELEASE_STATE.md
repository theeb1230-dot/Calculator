# Vault release state

- Base main SHA: `e1e6334185a6f4f70f9f74034a93cc090347feac`
- Target version/build: `0.3.0+3`
- Vault PIN trigger: IMPLEMENTED
- PIN enrollment: hidden long-press on calculator equals, then user-selected 6–12 digit PIN confirmation.
- PIN verifier: PBKDF2-HMAC-SHA256 (210,000 iterations, random 256-bit salt) stored via platform-protected secure storage; PIN is not a content-encryption key.
- Authentication routing: `PIN` then `=` is checked before calculator evaluation. Rejection falls through to ordinary calculator evaluation with no protected-feature hint.
- Protected session: opens only after authentication and locks when leaving the protected route or app lifecycle stops being resumed.
- Physical device validation: DEVICE_REQUIRED_PENDING for Keychain/Android protected-storage behavior and lifecycle capture behavior.
- Release gate: CI, merge, exact-main Android APK + iOS UNSIGNED/no-codesign IPA, SHA256SUMS and BUILD_PROVENANCE still required before status may become RELEASED.
