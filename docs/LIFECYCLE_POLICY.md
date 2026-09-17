# Protected session lifecycle policy

A protected session starts locked. Successful authentication may unlock it. Moving the application to inactive, paused, detached, or hidden state relocks it. Returning to the application does not implicitly restore an unlocked session.

Device-specific lifecycle behavior is validated on physical hardware in addition to software regression coverage.
