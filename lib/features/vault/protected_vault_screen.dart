import 'package:flutter/material.dart';

/// Minimal authenticated destination. It intentionally contains no public
/// navigation entry; callers must first establish a protected session.
final class ProtectedVaultScreen extends StatelessWidget {
  const ProtectedVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Protected storage'),
        ),
      ),
    );
  }
}
