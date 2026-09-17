# Protected-session authentication flow

The public surface remains a normal calculator and must not expose private-feature labels, lock icons, errors, or hints.

1. Enrollment is explicit and user-selected. There is no production default credential.
2. The enrolled credential is represented by a slow verifier in platform-protected storage. It is not a content-encryption key.
3. An equals press reaches the authentication boundary before ordinary calculator evaluation.
4. Only an enrolled, syntactically bounded candidate is verified. A match may open a protected session.
5. A mismatch, missing enrollment, or ordinary expression falls through to calculator evaluation with no private-feature signal.
6. Lifecycle lock invalidates the protected session; reopening requires authentication under the same policy.

The current `PinEnrollmentStore` is a boundary contract. A production platform-backed enrollment implementation and UI wiring are required before this flow can be marked RELEASED. Physical-device platform validation remains `DEVICE_REQUIRED_PENDING` and does not block automated regression gates.
