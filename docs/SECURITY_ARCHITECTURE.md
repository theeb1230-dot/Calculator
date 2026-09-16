# Security Architecture

## Status
Design baseline. Security-sensitive functionality is not considered implemented until code, automated tests, platform validation, and review exist.

## Principles
- Offline-first: no account, ads, analytics, or backend is required for core operation.
- Never hardcode a production PIN, encryption key, recovery key, or other secret.
- The PIN is an authentication factor, not a file-encryption key.
- Use platform-backed key protection (Android Keystore/StrongBox when available; iOS Keychain/Secure Enclave where applicable).
- Use authenticated encryption through maintained cryptographic libraries. Target primitive for encrypted vault objects: AES-256-GCM or an equally reviewed AEAD construction supported by the chosen library/platform.
- Nonces must be unique for a given key and generated according to the cryptographic API contract.
- Protect sensitive metadata, thumbnails, caches, and temporary material, not only original files.
- Lock sensitive sessions on lifecycle transitions according to policy and obscure sensitive UI in task/app switchers where the platform supports it.
- Obfuscation is hardening only; it is never a secret-storage mechanism.

## Proposed key hierarchy
1. Generate a cryptographically random vault master key.
2. Protect/wrap key material using platform-backed secure storage.
3. Keep user PIN verification logically separate from encrypted file data.
4. Use scoped data-encryption keys where this improves rotation, streaming, or blast-radius properties.
5. Keep plaintext key material in memory only for the minimum practical session lifetime.

Exact KDF parameters, key wrapping format, and file envelope format MUST be selected only with a concrete maintained library and covered by compatibility/test vectors. They are intentionally not invented in this document.

## Transactional import invariant
The app MUST NOT delete an imported source merely because encryption started.

Expected sequence:
1. Read the selected source with least privilege.
2. Encrypt into private application storage.
3. Finalize and authenticate the encrypted object.
4. Verify committed metadata and the ability to read/decrypt the new object.
5. Commit the vault database transaction.
6. Report successful import.
7. Only then offer source deletion as an explicit user action supported by the platform.

Any failure before commit leaves the source untouched and cleans incomplete private output.

## Media
Large media should use bounded-memory authenticated streaming/chunking based on a reviewed construction. Do not decrypt a complete large video into a persistent plaintext temporary file merely for playback.

## Recovery
No-cloud recovery has an unavoidable tradeoff: if all usable key material is lost, data may be unrecoverable. A future recovery-key feature must make that consequence explicit and must not introduce a hidden server-side bypass.

## Threat boundaries
Initial threat model includes casual device inspection, another app reading shared storage, accidental plaintext leakage, backup/cache leakage, screenshots/task previews where controllable, offline file theft, and reverse engineering.

It does not claim protection against a fully compromised OS, an already-unlocked device controlled by an attacker, forensic hardware attacks beyond platform guarantees, or every screen-capture path on every OS version.

## Verification gate
Before a security feature is called complete, map implementation and tests to relevant OWASP MASVS/MASTG controls and record platform limitations. Physical-device-only checks are tracked as `DEVICE_REQUIRED_PENDING`; they do not convert unverified behavior into a passing claim.
