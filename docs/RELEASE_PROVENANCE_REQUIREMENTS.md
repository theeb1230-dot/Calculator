# Release provenance requirements

The 0.3.0 release manifest must record the exact main commit, application version/build, Flutter/Dart toolchain, Android package identity and observed signing state, iOS bundle identity/version and explicit unsigned/no-codesign state, artifact filenames, sizes, and SHA-256 digests.

The published GitHub Release must contain the Android APK, iOS IPA, SHA256SUMS, and provenance manifest. Release API verification must confirm both packages exist and have non-zero sizes.
