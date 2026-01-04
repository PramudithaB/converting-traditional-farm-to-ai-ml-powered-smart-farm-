import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Market Analyze')),
      body: Center(
        child: Text('Market analysis page', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary)),
      ),
    );
  }
}