# Platform Security Boundary

Calculator remains the only public-facing surface. Vault state must not be named in launcher labels, bundle display names, notifications, app-switcher snapshots, or ordinary calculator errors.

## Android

- Package identity: `com.theeb.calculator`.
- Vault presentation will enable `FLAG_SECURE` while sensitive UI is visible and remove it after leaving the protected surface.
- `FLAG_SECURE` is defense-in-depth. It blocks normal screenshots and non-secure displays for the protected window, but it is not a universal guarantee against every capture technique or compromised device.
- Key-encryption keys must be generated randomly and protected by Android Keystore. StrongBox may be preferred when available but cannot be assumed.

## iOS

- Public display name is `Calculator`.
- iOS does not provide an application API that universally prevents screenshots. The app will detect active screen capture where supported and obscure sensitive content, and will cover sensitive UI before background/app-switcher snapshots.
- Key-encryption material must use Keychain-backed protection. Secure Enclave can protect suitable asymmetric keys where available; it is not a storage location for arbitrary AES file keys.

## Shared cryptographic rules

- User PIN is an authentication secret, never a file-encryption key and never stored in plaintext.
- File/content keys are random. Protected metadata, thumbnails, indexes, temporary plaintext and recovery material are in the threat model.
- Authenticated encryption uses a maintained AEAD construction such as AES-256-GCM. No custom cryptographic primitive or unauthenticated encryption is permitted.
- Import is transactional: read -> encrypt -> authenticated verification -> durable metadata commit -> success. Original deletion is optional and permission-gated.
- Flash secure deletion is not guaranteed. iOS must not claim silent deletion of arbitrary Photos-library originals.
- Decoy vault, if shipped, requires independent key material, database and files.

## Manual verification queue

`DEVICE_REQUIRED_PENDING`: verify Android screenshot/recording behavior, iOS capture/background obscuring, biometric prompts, key persistence, reinstall behavior, and interruption during large imports on physical devices. These checks do not block unrelated automated development, but they block claims of full device security validation.

Security acceptance follows OWASP MASVS/MASTG principles and must be backed by tests and platform evidence before a release is described as security-complete.
