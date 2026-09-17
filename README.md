# Calculator

Offline-first Flutter calculator with a separately authenticated private-storage architecture.

## Current state

The public product surface remains a normal calculator with no Vault/Private/Lock hint. It supports arithmetic precedence, parentheses, decimals, unary signs, postfix percentage, large values and scientific-notation continuation. Android and iOS platform projects are committed and built by CI.

The Vault entry path is wired for the 0.3.0 build: user-selected PIN enrollment, platform-protected credential persistence, a maintained slow password KDF, authentication-first `=` interception before calculator evaluation, protected-session navigation, and lifecycle relock. Physical-device security checks remain `DEVICE_REQUIRED_PENDING` and are not represented as completed validation.

GitHub Release v0.2.0 is the previously published baseline. Version 0.3.0+3 is the next release candidate and is not considered shipped until its exact-main Android APK and clearly UNSIGNED/no-codesign iOS IPA, checksums, and provenance are published and verified in GitHub Releases.

## Privacy contract

- No account, ads, analytics, tracking or backend is required for core operation.
- Production onboarding requires a PIN chosen by the user. There is no production default PIN.
- A secret numeric trigger is checked by the authentication layer before ordinary `=` evaluation. A failed candidate falls through to normal calculator behavior without a private-feature hint.
- The PIN is not stored as plaintext and is never a file-encryption key.
- Vault/content keys are cryptographically random and protected using platform-backed facilities such as Android Keystore and iOS Keychain where applicable.
- Encrypted objects use maintained authenticated encryption such as AES-256-GCM. Custom cryptography is prohibited.
- Sensitive metadata, thumbnails, indexes, caches, temporary plaintext and recovery material are included in the threat model.
- Android protected content uses `FLAG_SECURE` as defense-in-depth, not as a universal capture guarantee. iOS uses capture detection/obscuring where applicable and cannot truthfully promise universal screenshot prevention.
- Source deletion after import is optional, permission-gated and only offered after encrypted output has been authenticated and committed. Secure deletion on flash is not guaranteed.

## Build and verification

Pull requests and `main` run Flutter analyze/tests plus Android APK and iOS no-codesign build gates from the committed platform projects.

A release is not considered shipped until the same exact version/commit produces both required distributable assets and they are published under GitHub Releases with signing state and checksums documented. An unsigned/no-codesign iOS package must be labeled as such and requires external signing/provisioning before normal device installation.

## Architecture

- `lib/features/calculator/` contains calculator parsing and input behavior.
- `lib/features/auth/` contains authentication-boundary contracts and secure PIN credential handling. It contains no hardcoded production PIN.
- `lib/platform/` contains narrow Dart-to-native security contracts.
- `docs/SECURITY_ARCHITECTURE.md` defines key hierarchy, import invariants, recovery and threat boundaries.
- `docs/PLATFORM_SECURITY.md` defines platform-specific limitations and the physical-device verification queue.

Security acceptance is aligned with relevant OWASP MASVS/MASTG controls. `DEVICE_REQUIRED_PENDING` checks are tracked separately and do not block unrelated automated development, but they block claims of completed physical-device security validation.
