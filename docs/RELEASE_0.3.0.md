# Release 0.3.0 acceptance

Target `0.3.0+3`.

The public surface remains a calculator and contains no visible private-feature hint. Initial PIN enrollment is available only through the hidden equals-button gesture. After enrollment, a matching PIN followed by equals authenticates before calculator evaluation and opens a lifecycle-lockable protected session. Wrong candidates continue through normal calculator behavior.

The PIN verifier is stored in platform-protected storage and derived with a maintained slow KDF. It is separate from the random vault content-key hierarchy.

Release is accepted only when exact-main CI succeeds and one GitHub Release contains a verified non-empty Android release APK, an explicitly UNSIGNED/no-codesign iOS IPA, SHA256SUMS, and build provenance for the same commit and version/build.
