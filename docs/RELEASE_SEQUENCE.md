# Release sequence

1. Complete native credential adapters and calculator UI integration on this branch.
2. Run exact-head analysis/tests and platform builds.
3. Fix code/test defects on this branch; do not weaken gates.
4. Merge only green and mergeable exact head.
5. Re-read exact main SHA.
6. Build and inspect Android APK and unsigned/no-codesign iOS IPA from that main SHA/version.
7. Generate checksums/provenance and publish one complete GitHub Release.
8. Verify non-empty APK and IPA through Releases API.
9. Only then begin the media/files/storage wave.
