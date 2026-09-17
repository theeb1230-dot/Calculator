# Vault PIN release completion

This branch completes the calculator-to-protected-session wiring after the authentication boundary merged in PR #17.

Release gate requirements:
- user-selected PIN enrollment with no production default;
- platform-protected verifier storage and a maintained slow password KDF;
- equals is routed through authentication before calculator evaluation;
- failed authentication is indistinguishable from normal calculator behavior;
- successful authentication opens only a lifecycle-lockable protected session;
- lifecycle exit locks the protected session;
- regression tests cover enrollment, correct/wrong PIN, ordinary calculations, and relock;
- bump version/build and publish APK plus UNSIGNED/no-codesign IPA from one exact main SHA with checksums and provenance.

Physical-device-only validation is recorded as DEVICE_REQUIRED_PENDING and does not weaken automated gates.
