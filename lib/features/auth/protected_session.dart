/// In-memory protected-session state. Sensitive content must only be exposed
/// while this session is unlocked. App lifecycle integration calls [lock]
/// whenever the application leaves the active foreground state.
final class ProtectedSession {
  bool _unlocked = false;

  bool get isUnlocked => _unlocked;

  void unlock() {
    _unlocked = true;
  }

  void lock() {
    _unlocked = false;
  }
}
