# Security alignment notes

This release wave keeps authentication, key management, storage, and lifecycle boundaries explicit so they can be tested independently against OWASP MASVS/MASTG expectations.

Key properties under test are fail-closed authentication, credential/content-key separation, platform-owned key material, lifecycle relock, authenticated encryption boundaries, and no misleading secure-deletion claims.

This document records engineering intent; it is not a claim of formal OWASP certification.
