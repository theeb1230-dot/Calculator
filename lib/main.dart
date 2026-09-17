import 'package:flutter/material.dart';

import 'features/auth/authenticated_equals_router.dart';
import 'features/auth/lifecycle_lock.dart';
import 'features/auth/pin_auth_controller.dart';
import 'features/auth/protected_session.dart';
import 'features/auth/secure_pin_store.dart';
import 'features/calculator/calculator_controller.dart';

void main() => runApp(const CalculatorVaultApp());

class CalculatorVaultApp extends StatelessWidget {
  const CalculatorVaultApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calculator',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0B0C0F),
        ),
        home: const CalculatorScreen(),
      );
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _controller = CalculatorController();
  final _session = ProtectedSession();
  late final PinAuthController _auth;
  late final AuthenticatedEqualsRouter _router;

  static const _keys = <String>[
    'C', '(', ')', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  @override
  void initState() {
    super.initState();
    _auth = PinAuthController(SecurePinEnrollmentStore());
    _router = AuthenticatedEqualsRouter(_auth, _session);
  }

  Future<void> _press(String key) async {
    if (key == '=') {
      final candidate = _controller.display;
      if (await _router.tryOpen(candidate)) {
        if (!mounted) return;
        _controller.press('C');
        setState(() {});
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ProtectedArea(session: _session)),
        );
        _session.lock();
        return;
      }
    }
    if (!mounted) return;
    setState(() => _controller.press(key));
  }

  Future<void> _beginEnrollment() async {
    if (await _auth.isEnrolled || !mounted) return;
    final first = TextEditingController();
    final second = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: first,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: const InputDecoration(labelText: 'PIN (6–12 digits)'),
            ),
            TextField(
              controller: second,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (first.text == second.text && RegExp(r'^\d{6,12}$').hasMatch(first.text)) {
                Navigator.pop(context, first.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    first.dispose();
    second.dispose();
    if (pin != null) await _auth.enroll(pin);
  }

  @override
  Widget build(BuildContext context) {
    final display = _controller.display;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 620;
            final padding = compact ? 12.0 : 20.0;
            final gap = compact ? 8.0 : 12.0;
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Expanded(
                    flex: compact ? 2 : 3,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Semantics(
                        label: 'Calculator display',
                        value: display,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomRight,
                          child: Text(display, textAlign: TextAlign.right, maxLines: 1,
                            style: TextStyle(fontSize: compact ? 40 : 48, fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 24),
                  Expanded(
                    flex: compact ? 5 : 6,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        childAspectRatio: compact ? 1.7 : 1.25,
                      ),
                      itemCount: _keys.length,
                      itemBuilder: (context, index) {
                        final key = _keys[index];
                        return Semantics(
                          button: true,
                          label: key,
                          child: GestureDetector(
                            onLongPress: key == '=' ? _beginEnrollment : null,
                            child: FilledButton(
                              onPressed: () => _press(key),
                              style: FilledButton.styleFrom(shape: const StadiumBorder(), padding: EdgeInsets.zero),
                              child: FittedBox(fit: BoxFit.scaleDown, child: Text(key, style: const TextStyle(fontSize: 24))),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProtectedArea extends StatefulWidget {
  const ProtectedArea({required this.session, super.key});
  final ProtectedSession session;

  @override
  State<ProtectedArea> createState() => _ProtectedAreaState();
}

class _ProtectedAreaState extends State<ProtectedArea> with WidgetsBindingObserver {
  late final LifecycleLock _lifecycleLock;

  @override
  void initState() {
    super.initState();
    _lifecycleLock = LifecycleLock(widget.session);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.session.lock();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _lifecycleLock.onBackgrounded();
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.session.isUnlocked) {
      return const SizedBox.shrink();
    }
    return const Scaffold(
      appBar: AppBar(title: Text('Files')),
      body: Center(child: Text('No files yet')),
    );
  }
}
