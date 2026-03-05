import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnimalBirthScreen extends StatefulWidget {
  const AnimalBirthScreen({super.key});

  @override
  State<AnimalBirthScreen> createState() => _AnimalBirthScreenState();
}

class _AnimalBirthScreenState extends State<AnimalBirthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPredicting = false;
  Map<String, dynamic>? _result;

  // Features for animal birth prediction
  // Adjusted based on your requested ranges
  double _temperatureFahrenheit = 101.5;

  // Body weight: 350 – 1000 kg
  double _bodyWeight = 350.0;

  // Milk yield: 5 – 50 L (using _gestationDay variable as "milk yield" now)
  int _milkYield = 5;

  // Parity: 1 – 10 (unchanged)
  double _udderSize = 5.0;

  // Age in months: 1 – 200
  double _ageMonths = 12.0;

  Future<void> _predictBirth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPredicting = true;
      _result = null;
    });

    try {
      final features = [
        _temperatureFahrenheit,
        _bodyWeight,
        _milkYield.toDouble(),
        _udderSize,
        _ageMonths,
      ];

      final response = await ApiService.predictAnimalBirth(features: features);

      setState(() {
        _result = response;
        _isPredicting = false;
      });
    } catch (e) {
      setState(() {
        _isPredicting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prediction failed: $e'),
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
        title: const Text('Animal Birth Prediction'),
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
                    Icon(Icons.pets_outlined,
                        size: 48, color: cs.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'Predict Birth Timing',
                      style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter animal health parameters to predict birth timing',
                      style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Temperature
              Text(
                'Temperature: ${_temperatureFahrenheit.toStringAsFixed(1)}°F',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _temperatureFahrenheit,
                min: 98.0,
                max: 104.0,
                divisions: 60,
                label: '${_temperatureFahrenheit.toStringAsFixed(1)}°F',
                onChanged: (value) =>
                    setState(() => _temperatureFahrenheit = value),
              ),
              const SizedBox(height: 16),

              // Body Weight 350–1000 kg
              Text(
                'Body Weight: ${_bodyWeight.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyWeight,
                min: 350,
                max: 1000,
                divisions: 650, // 1 kg step
                label: '${_bodyWeight.toStringAsFixed(0)} kg',
                onChanged: (value) =>
                    setState(() => _bodyWeight = value),
              ),
              const SizedBox(height: 16),

              // Milk Yield 5–50 L
              Text(
                'Milk Yield: $_milkYield L',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _milkYield.toDouble(),
                min: 5,
                max: 50,
                divisions: 45, // 1 L step
                label: '$_milkYield L',
                onChanged: (value) =>
                    setState(() => _milkYield = value.toInt()),
              ),
              const SizedBox(height: 16),

              // Parity (kept same meaning as your text)
              Text(
                'Parity: ${_udderSize.toStringAsFixed(1)}/10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _udderSize,
                min: 1,
                max: 10,
                divisions: 9,
                label: _udderSize.toStringAsFixed(1),
                onChanged: (value) =>
                    setState(() => _udderSize = value),
              ),
              const SizedBox(height: 16),

              // Age Months 1–200
              Text(
                'Age Months: ${_ageMonths.toStringAsFixed(0)} / 200',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _ageMonths,
                min: 1,
                max: 200,
                divisions: 199,
                label: _ageMonths.toStringAsFixed(0),
                onChanged: (value) =>
                    setState(() => _ageMonths = value),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isPredicting ? null : _predictBirth,
                icon: _isPredicting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.analytics),
                label: Text(
                    _isPredicting ? 'Predicting...' : 'Predict Birth'),
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
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.baby_changing_station,
                                color: cs.primary, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Prediction Results',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildResultItem(
                          'Will Birth in 2 Days',
                          _result!['Will Birth in Next 2 Days'] ??
                              'N/A',
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

  Widget _buildResultItem(
      String label, String value, ColorScheme cs) {
    final isPositive = value.toLowerCase().contains('yes');
    final isNegative = value.toLowerCase().contains('no');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withOpacity(0.2)
                  : isNegative
                  ? Colors.orange
                  .withOpacity(0.2)
                  : cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPositive
                    ? Colors.green
                    : isNegative
                    ? Colors.orange
                    : cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}