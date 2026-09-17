# Security boundaries

Authentication credentials and content-encryption keys are separate domains. The user credential authorizes a protected session; it is not used as a file key. Content keys remain randomly generated and are wrapped through platform-owned key material.

The public calculator has no dedicated protected-content navigation control. Failed authentication must be indistinguishable from normal calculator evaluation.

Native credential persistence must be platform protected and must not persist a raw credential. Physical-device verification is tracked separately from software CI.
