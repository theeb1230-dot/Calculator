import 'package:flutter/widgets.dart';

import 'protected_session.dart';

/// Locks protected state whenever the application is no longer resumed.
final class LifecycleLockObserver with WidgetsBindingObserver {
  LifecycleLockObserver(this.session);

  final ProtectedSession session;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) session.lock();
  }
}
