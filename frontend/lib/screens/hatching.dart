import 'package:flutter/material.dart';

class HatchingScreen extends StatelessWidget {
  const HatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Birth & Hatching')),
      body: Center(
        child: Text('Hatching page', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary)),
      ),
    );
  }
}