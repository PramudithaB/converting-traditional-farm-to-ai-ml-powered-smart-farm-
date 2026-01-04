import 'package:flutter/material.dart';

class IdenticoScreen extends StatelessWidget {
  const IdenticoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Identify Cow')),
      body: Center(
        child: Text('Identify cow page', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary)),
      ),
    );
  }
}