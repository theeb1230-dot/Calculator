# Key hierarchy

User authentication credentials are not encryption keys. Vault master material is created and owned by platform key facilities. Random data keys are generated per protected operation and wrapped under platform-owned master material with authenticated context.

The application should expose opaque handles rather than raw master keys. Storage encryption uses maintained authenticated-encryption primitives and must authenticate metadata/context relevant to the ciphertext.
