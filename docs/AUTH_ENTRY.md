# Authenticated calculator routing

The calculator is the public application surface. Protected content has no public navigation control.

Equals is routed through authentication before ordinary evaluation. A valid enrolled credential can establish a protected session. Rejected or malformed input continues through normal calculator evaluation without a distinguishing user-facing result.

The user-selected credential is authentication material only and is separate from randomly generated content-encryption keys. Enrollment persistence belongs to platform-protected credential storage. Production default credentials are prohibited.
