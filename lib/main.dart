import 'package:flutter/material.dart';

import 'features/calculator/calculator_controller.dart';

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
  final _controller = CalculatorController();

  static const _keys = <String>[
    'C', '(', ')', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  void _press(String key) {
    // Vault authentication remains a separate boundary. This public surface
    // only delegates calculator state and expression evaluation.
    setState(() => _controller.press(key));
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
                          child: Text(
                            display,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: compact ? 40 : 48,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
                          child: FilledButton(
                            onPressed: () => _press(key),
                            style: FilledButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(key, style: const TextStyle(fontSize: 24)),
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
