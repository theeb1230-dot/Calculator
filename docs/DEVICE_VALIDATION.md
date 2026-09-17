# Device validation queue

Status: `DEVICE_REQUIRED_PENDING`

The following checks require physical Android/iOS devices and do not block automated CI:

- verify Android protected-storage persistence and hardware-backed behavior where the device supports it;
- verify iOS Keychain persistence and accessibility behavior on a provisioned device;
- verify lifecycle/background relock returns to the calculator and requires PIN authentication again;
- verify screen-capture protections within documented Android/iOS platform limitations.

No automated result is represented as physical-device evidence.
