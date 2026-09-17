# Release gate

A release is complete only when Android and iOS packages originate from one exact main SHA and one version/build, automated analysis/tests pass, package identity and signing state are inspected, checksums and provenance are generated, and GitHub Releases exposes both non-empty packages.

Actions artifacts alone do not satisfy this gate. iOS no-codesign output must be named and documented as unsigned. Android must not be described as production-signed unless the produced package proves that state.
