# Calculator

Offline-first Flutter calculator with a separately authenticated private-storage architecture under active development.

## Current state

The public product surface is a normal calculator. It supports arithmetic precedence, parentheses, decimals, unary signs, postfix percentage, large values and scientific-notation continuation. Android and iOS platform projects are committed and built by CI.

The private-storage feature set is **not release-complete yet**. Security claims require implementation, automated tests and platform validation. There is currently no published GitHub Release.

## Privacy contract

- No account, ads, analytics, tracking or backend is required for core operation.
- Production onboarding must require a PIN chosen by the user. There is no production default PIN.
- A secret numeric trigger is checked by the authentication layer before ordinary `=` evaluation. A failed candidate falls through to normal calculator behavior without a private-feature hint.
- The PIN is not stored as plaintext and is never a file-encryption key.
- Vault/content keys must be cryptographically random and protected using platform-backed facilities such as Android Keystore and iOS Keychain where applicable.
- Encrypted objects use maintained authenticated encryption such as AES-256-GCM. Custom cryptography is prohibited.
- Sensitive metadata, thumbnails, indexes, caches, temporary plaintext and recovery material are included in the threat model.
- Android protected content uses `FLAG_SECURE` as defense-in-depth, not as a universal capture guarantee. iOS requires capture detection/obscuring and cannot truthfully promise universal screenshot prevention.
- Source deletion after import is optional, permission-gated and only offered after encrypted output has been authenticated and committed. Secure deletion on flash is not guaranteed.

## Build and verification

Pull requests and `main` run Flutter analyze/tests plus Android APK and iOS no-codesign build gates from the committed platform projects.

A release is not considered shipped until the same exact version/commit produces both required distributable assets and they are published under GitHub Releases with signing state and checksums documented. An unsigned/no-codesign iOS package must be labeled as such and requires external signing/provisioning before normal device installation.

## Architecture

- `lib/features/calculator/` contains calculator parsing and input behavior.
- `lib/features/auth/` contains authentication-boundary contracts. It must not contain a hardcoded production PIN.
- `lib/platform/` contains narrow Dart-to-native security contracts.
- `docs/SECURITY_ARCHITECTURE.md` defines key hierarchy, import invariants, recovery and threat boundaries.
- `docs/PLATFORM_SECURITY.md` defines platform-specific limitations and the physical-device verification queue.

Security acceptance is aligned with relevant OWASP MASVS/MASTG controls. `DEVICE_REQUIRED_PENDING` checks are tracked separately and do not block unrelated automated development, but they do block claims of completed device security validation.
