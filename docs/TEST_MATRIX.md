# Protected entry regression matrix

Automated coverage must prove:

- missing enrollment cannot unlock a protected session;
- malformed/non-numeric input never crosses the credential verifier boundary;
- rejected credential input leaves the session locked;
- successful verification unlocks only after authentication;
- ordinary calculator expressions remain eligible for normal evaluation;
- lifecycle backgrounding relocks an unlocked session;
- platform credential calls fail closed when unavailable.

Physical-device platform persistence and capture-protection behavior remain in the device validation queue.
