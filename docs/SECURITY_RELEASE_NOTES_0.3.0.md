# Security notes for 0.3.0

This release does not claim that a PIN encrypts files. PIN authentication gates access to the protected session; content encryption remains a separate random-key hierarchy. The verifier uses a random salt and a slow maintained KDF and is persisted through platform protected storage. Authentication failures are fail-closed and reveal no private-feature state on the calculator surface. Device-backed storage and lifecycle behavior remain subject to DEVICE_REQUIRED_PENDING physical validation.
