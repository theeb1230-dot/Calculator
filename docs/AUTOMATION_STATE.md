# Autonomous development state

- Final Sprint phase: BUILD SPRINT A closeout.
- Source-of-truth main at wave start: `e1e6334185a6f4f70f9f74034a93cc090347feac`.
- Working PR: `#19` / branch `feat/auth-ui-release`.
- Exact head at closeout update parent: `91aebc13c6f0a9b5ea96a100ae43e8bb40ea7352`; this document update creates the next exact head and CI must be evaluated on that SHA.
- Target: `0.3.0+3`.
- Verified prior defect on head `e0f6edbc2feae33344ada9bd301a54e7369a035d`: iOS CI no-codesign gate failed because Xcode still required a Development Team. Classification: CODE_DEFECT in CI configuration, not a human signing blocker. Fixed on the same branch by making the CI build explicitly disable Xcode signing after Flutter configuration. No blind rerun was requested; the new commit naturally triggers exact-head CI.
- Vault entry implementation: user-selected 6–12 digit PIN enrollment through a hidden long-press on the normal equals key; no public Vault/Private/Lock hint; PBKDF2-HMAC-SHA256 verifier with random salt stored via platform secure storage; PIN is not a content/file key; authentication-first equals routing occurs before CalculatorEngine; wrong PIN falls through to ordinary calculator evaluation without a hint; correct PIN opens a protected session; lifecycle departure relocks and closes the protected route.
- README now records the existing `v0.2.0` baseline Release and the `0.3.0+3` release-candidate gate rather than claiming no Release exists.
- Android APK: pending exact-main release build; signing state must be measured and must not be described as production unless proven.
- iOS IPA: pending exact-main release `--no-codesign` build; must be named UNSIGNED/no-codesign.
- SHA-256/provenance: pending release artifacts.
- Tag/Release: pending.
- Vault PIN trigger: IMPLEMENTED; release status cannot become RELEASED until exact-head CI, merge, exact-main release build, publication and Releases API verification complete.
- Device-only checks: DEVICE_REQUIRED_PENDING.
