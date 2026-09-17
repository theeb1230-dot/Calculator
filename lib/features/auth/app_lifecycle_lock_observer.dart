import 'package:flutter/widgets.dart';

import 'protected_session.dart';

final class AppLifecycleLockObserver with WidgetsBindingObserver {
  AppLifecycleLockObserver(this.session);

  final ProtectedSession session;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      session.lock();
    }
  }
}
