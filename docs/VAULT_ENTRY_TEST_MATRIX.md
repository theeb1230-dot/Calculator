# Vault entry regression matrix

| Scenario | Required result |
|---|---|
| Ordinary expression then `=` | Calculator evaluates normally |
| No enrollment, numeric candidate then `=` | Calculator behavior only |
| Wrong enrolled PIN then `=` | Calculator behavior only, no protected-feature hint |
| Correct enrolled PIN then `=` | Protected session opens before calculator evaluation |
| Background protected session | Session locks and protected route closes |
| Return after lifecycle lock | PIN authentication is required again |
| PIN material | Never used as file/content encryption key |
| Platform credential persistence | DEVICE_REQUIRED_PENDING on physical Android/iOS |
