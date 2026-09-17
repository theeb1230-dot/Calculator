# Enrollment contract

Enrollment is user initiated when protected entry is first configured. There is no production default credential. The accepted credential policy is numeric, 6–12 digits, and validation occurs before persistence.

The native adapter persists only protected verifier material, never the raw credential. Enrollment state gates authentication so a verifier response cannot bypass an unconfigured installation.
