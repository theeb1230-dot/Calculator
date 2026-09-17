# Calculator fallback contract

The public calculator must not reveal whether protected-session enrollment exists. Authentication rejection, missing enrollment, and non-credential expressions all return control to ordinary calculator evaluation. Public UI copy must not advertise protected storage or authentication entry.

Only a successful authentication decision may unlock a protected session. The session is relocked on lifecycle exit and must be authenticated again according to policy.
