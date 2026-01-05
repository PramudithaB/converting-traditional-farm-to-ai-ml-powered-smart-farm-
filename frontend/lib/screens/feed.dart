import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isCalculating = false;
  Map<String, dynamic>? _result;

  String _breed = 'Holstein';
  double _weight = 600.0;
  int _age = 36;
  double _milkYield = 25.0;
  String _activity = 'Medium';

  final List<String> _breeds = [
    'Holstein',
    'Jersey',
    'Ayrshire',
    'Guernsey',
    'Brown Swiss',
    'Other'
  ];

  final List<String> _activityLevels = ['Low', 'Medium', 'High'];

  Future<void> _calculateFeed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = null;
    });

    try {
      final response = await ApiService.predictCowFeedManual(
        breed: _breed,
        age: _age,
        weight: _weight,
        milkYield: _milkYield,
        activity: _activity,
      );

      setState(() {
        _result = response;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cow Feed Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primaryContainer, cs.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.restaurant, size: 48, color: cs.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'Daily Feed Calculator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calculate optimal feed requirements for your cattle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Breed
              Text(
                'Breed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _breed,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _breeds
                    .map((breed) => DropdownMenuItem(value: breed, child: Text(breed)))
                    .toList(),
                onChanged: (value) => setState(() => _breed = value!),
              ),
              const SizedBox(height: 16),
              
              // Weight
              Text(
                'Body Weight: ${_weight.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _weight,
                min: 300,
                max: 1000,
                divisions: 70,
                label: '${_weight.toStringAsFixed(0)}kg',
                onChanged: (value) => setState(() => _weight = value),
              ),
              const SizedBox(height: 16),
              
              // Age
              Text(
                'Age: $_age months',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _age.toDouble(),
                min: 12,
                max: 120,
                divisions: 108,
                label: '$_age months',
                onChanged: (value) => setState(() => _age = value.toInt()),
              ),
              const SizedBox(height: 16),
              
              // Milk Yield
              Text(
                'Milk Yield: ${_milkYield.toStringAsFixed(1)} L/day',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _milkYield,
                min: 0,
                max: 50,
                divisions: 50,
                label: '${_milkYield.toStringAsFixed(1)}L',
                onChanged: (value) => setState(() => _milkYield = value),
              ),
              const SizedBox(height: 16),
              
              // Activity Level
              Text(
                'Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _activity,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _activityLevels
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) => setState(() => _activity = value!),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isCalculating ? null : _calculateFeed,
                icon: _isCalculating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_isCalculating ? 'Calculating...' : 'Calculate Feed'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              if (_result != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.breakfast_dining, color: cs.primary, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Feed Recommendation',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildFeedItem(
                          'Daily Feed Required',
                          '${_result!['daily_feed_kg'] ?? 'N/A'} kg/day',
                          Icons.scale,
                          cs,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedItem(String label, String value, IconData icon, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}