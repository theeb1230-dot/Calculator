# Calculator 0.3.0

This release wave connects the existing authentication boundary to the application entry flow while preserving ordinary calculator behavior for rejected input. It also adds lifecycle relocking, a platform credential-storage boundary, regression coverage, and release verification requirements.

The iOS package remains explicitly unsigned/no-codesign. Android signing state is reported from the produced package and is not represented as production signing unless verified.
