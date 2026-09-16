import 'package:flutter/material.dart';

void main() => runApp(const CalculatorVaultApp());

class CalculatorVaultApp extends StatelessWidget {
  const CalculatorVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';

  static const _keys = <String>[
    'C', '(', ')', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  void _press(String key) {
    // This shell intentionally does not contain vault credentials or crypto.
    // Calculator parsing and secure unlock are separate, testable modules.
    setState(() {
      if (key == 'C') {
        _display = '0';
      } else if (key != '=') {
        _display = _display == '0' ? key : '$_display$key';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Semantics(
                    label: 'Calculator display',
                    value: _display,
                    child: Text(
                      _display,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _keys.length,
                itemBuilder: (context, index) {
                  final key = _keys[index];
                  return Semantics(
                    button: true,
                    label: key,
                    child: FilledButton(
                      onPressed: () => _press(key),
                      style: FilledButton.styleFrom(shape: const CircleBorder()),
                      child: Text(key, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
