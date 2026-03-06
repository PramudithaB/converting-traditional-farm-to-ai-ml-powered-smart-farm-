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

  // Backend expects: [age, parity, temp, milk, weight]
  // columns = ["Age_Months","Parity","Body_Temp_C","Milk_Yield_kg","Weight_kg"]

  double _ageMonths = 40;
  int _parity = 2;
  double _bodyTempCelsius = 38.5;
  double _milkYieldKg = 12.3;
  double _bodyWeightKg = 450;

  Future<void> _predictBirth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPredicting = true;
      _result = null;
    });

    try {
      // Option A: send List<double> to match ApiService signature
      final features = <double>[
        _ageMonths.toDouble(), // age
        _parity.toDouble(), // parity
        _bodyTempCelsius.toDouble(), // temp (C)
        _milkYieldKg.toDouble(), // milk
        _bodyWeightKg.toDouble(), // weight
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
        title: const Text("Animal Birth Prediction"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER CARD
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
                      "Predict Birth Timing",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Enter cow health parameters to predict birth timing",
                      style: TextStyle(
                        color: cs.onPrimaryContainer.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // AGE
              Text(
                "Age (Months): ${_ageMonths.toStringAsFixed(0)}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _ageMonths,
                min: 1,
                max: 200,
                divisions: 199,
                label: _ageMonths.toStringAsFixed(0),
                onChanged: (v) => setState(() => _ageMonths = v),
              ),

              const SizedBox(height: 16),

              // PARITY
              Text(
                "Parity: $_parity",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _parity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _parity.toString(),
                onChanged: (v) => setState(() => _parity = v.round()),
              ),

              const SizedBox(height: 16),

              // TEMP (Celsius)
              Text(
                "Body Temperature: ${_bodyTempCelsius.toStringAsFixed(1)} °C",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyTempCelsius,
                min: 34.0,
                max: 42.0,
                divisions: 80,
                label: "${_bodyTempCelsius.toStringAsFixed(1)} °C",
                onChanged: (v) => setState(() => _bodyTempCelsius = v),
              ),

              const SizedBox(height: 16),

              // MILK (kg)
              Text(
                "Milk Yield: ${_milkYieldKg.toStringAsFixed(1)} kg",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _milkYieldKg,
                min: 0,
                max: 60,
                divisions: 600,
                label: "${_milkYieldKg.toStringAsFixed(1)} kg",
                onChanged: (v) => setState(() => _milkYieldKg = v),
              ),

              const SizedBox(height: 16),

              // WEIGHT (kg)
              Text(
                "Body Weight: ${_bodyWeightKg.toStringAsFixed(0)} kg",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyWeightKg,
                min: 150,
                max: 1000,
                divisions: 850,
                label: "${_bodyWeightKg.toStringAsFixed(0)} kg",
                onChanged: (v) => setState(() => _bodyWeightKg = v),
              ),

              const SizedBox(height: 24),

              // PREDICT BUTTON
              ElevatedButton.icon(
                onPressed: _isPredicting ? null : _predictBirth,
                icon: _isPredicting
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.analytics),
                label: Text(_isPredicting ? "Predicting..." : "Predict Birth"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 24),

              // RESULT CARD
              if (_result != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.baby_changing_station,
                                size: 30, color: cs.primary),
                            const SizedBox(width: 10),
                            Text(
                              "Prediction Results",
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
                          "Will Birth in 2 Days",
                          _result!["will_birth_in_next_2_days"] ?? "N/A",
                          cs,
                        ),
                        const SizedBox(height: 12),
                        _buildResultItem(
                          "Estimated Days to Birth",
                          _result!["estimated_days_to_birth"]?.toString() ??
                              "N/A",
                          cs,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, dynamic value, ColorScheme cs) {
    final text = value.toString();

    final isYes = text.toLowerCase().contains("yes");
    final isNo = text.toLowerCase().contains("no");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: cs.onSurface.withOpacity(0.7),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isYes
                ? Colors.green.withOpacity(0.2)
                : isNo
                ? Colors.orange.withOpacity(0.2)
                : cs.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isYes
                  ? Colors.green
                  : isNo
                  ? Colors.orange
                  : cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}