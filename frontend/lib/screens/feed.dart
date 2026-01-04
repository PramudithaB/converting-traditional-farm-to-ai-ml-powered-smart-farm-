import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Feed Predictor')),
      body: Center(
        child: Text('Feed predictor page', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary)),
      ),
    );
  }
}