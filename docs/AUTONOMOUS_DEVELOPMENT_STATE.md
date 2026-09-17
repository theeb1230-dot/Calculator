# Autonomous Development State

## Current release wave

- Base main SHA: `e1e6334185a6f4f70f9f74034a93cc090347feac`
- Target version/build: `0.3.0+3`
- Vault PIN trigger: `IMPLEMENTED`
- Failure classification: `NO_CI_FAILURE` before PR CI
- Android APK: pending exact-head release build; signing state must be measured and must not be described as production unless verified.
- iOS IPA: pending exact-head `--no-codesign` release build; must remain explicitly UNSIGNED/no-codesign.
- SHA-256/provenance: pending release artifacts.
- Tag/Release: pending.

## Wave scope

1. User-selected PIN enrollment through a platform-protected credential boundary; no production default and PIN remains independent from file encryption keys.
2. Authentication-first equals routing. Rejected candidates fall through to ordinary calculator evaluation with no Vault hint.
3. Regression/lifecycle/relock coverage, documentation, version bump, and complete APK + unsigned IPA release.

## Device evidence

Native secure-storage behavior and lifecycle behavior requiring physical Android/iOS hardware are `DEVICE_REQUIRED_PENDING`; this does not weaken automated analysis/tests or the release gate.
