# Release 0.3.0+3 checklist

- [x] Authentication-first equals routing foundation
- [x] Platform PIN credential boundary
- [x] Protected session lifecycle relock observer
- [x] Regression tests for wrong/normal input and relock
- [ ] Native PIN verifier adapters on Android and iOS
- [ ] Calculator UI wiring and first-use enrollment flow
- [ ] Exact-head CI green
- [ ] Merge to main and reread exact SHA
- [ ] Android release APK validation and signing-state report
- [ ] iOS release no-codesign IPA validation
- [ ] SHA256SUMS and BUILD_PROVENANCE
- [ ] GitHub Release API confirms non-zero APK and IPA

Vault PIN trigger remains IMPLEMENTED, not RELEASED, until every unchecked release gate above is complete.
