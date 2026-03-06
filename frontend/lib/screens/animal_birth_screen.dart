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

  // Model inputs
  double _temperatureFahrenheit = 101.5;
  double _bodyWeight = 150.0;
  int _milkYield = 5;
  double _parity = 2;
  double _ageMonths = 12;

  Future<void> _predictBirth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPredicting = true;
      _result = null;
    });

    try {
      // Correct order expected by Flask model
      final features = [
        _ageMonths,            // Age_Months
        _parity,               // Parity
        _temperatureFahrenheit,// Body_Temp_C
        _milkYield.toDouble(), // Milk_Yield_kg
        _bodyWeight            // Weight_kg
      ];

      final response =
      await ApiService.predictAnimalBirth(features: features);

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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
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

              // TEMPERATURE
              Text(
                "Temperature: ${_temperatureFahrenheit.toStringAsFixed(1)}°F",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _temperatureFahrenheit,
                min: 98,
                max: 104,
                divisions: 60,
                label: "${_temperatureFahrenheit.toStringAsFixed(1)}°F",
                onChanged: (v) {
                  setState(() => _temperatureFahrenheit = v);
                },
              ),

              const SizedBox(height: 16),

              // BODY WEIGHT
              Text(
                "Body Weight: ${_bodyWeight.toStringAsFixed(0)} kg",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyWeight,
                min: 150,
                max: 1000,
                divisions: 850,
                label: "${_bodyWeight.toStringAsFixed(0)} kg",
                onChanged: (v) {
                  setState(() => _bodyWeight = v);
                },
              ),

              const SizedBox(height: 16),

              // MILK YIELD
              Text(
                "Milk Yield: $_milkYield L",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _milkYield.toDouble(),
                min: 5,
                max: 50,
                divisions: 45,
                label: "$_milkYield L",
                onChanged: (v) {
                  setState(() => _milkYield = v.toInt());
                },
              ),

              const SizedBox(height: 16),

              // PARITY
              Text(
                "Parity: ${_parity.toStringAsFixed(0)}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _parity,
                min: 1,
                max: 10,
                divisions: 9,
                label: _parity.toStringAsFixed(0),
                onChanged: (v) {
                  setState(() => _parity = v);
                },
              ),

              const SizedBox(height: 16),

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
                onChanged: (v) {
                  setState(() => _ageMonths = v);
                },
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
                label: Text(_isPredicting
                    ? "Predicting..."
                    : "Predict Birth"),
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
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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