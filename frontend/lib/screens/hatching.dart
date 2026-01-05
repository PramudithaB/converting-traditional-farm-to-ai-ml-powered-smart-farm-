import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HatchingScreen extends StatefulWidget {
  const HatchingScreen({super.key});

  @override
  State<HatchingScreen> createState() => _HatchingScreenState();
}

class _HatchingScreenState extends State<HatchingScreen> {
  final _formKey = GlobalKey<FormState>();
  double _temperature = 37.5;
  double _humidity = 60.0;
  double _eggWeight = 60.0;
  int _turningFrequency = 4;
  int _incubationDuration = 1;
  bool _isPredicting = false;
  Map<String, dynamic>? _result;

  Future<void> _predictHatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPredicting = true;
      _result = null;
    });

    try {
      final response = await ApiService.predictEggHatch(
        temperature: _temperature,
        humidity: _humidity,
        eggWeight: _eggWeight,
        turningFrequency: _turningFrequency,
        incubationDuration: _incubationDuration,
      );

      if (!mounted) return;

      setState(() {
        _result = response;
        _isPredicting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPredicting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final probability = (_result!['hatch_probability'] as num?)?.toDouble() ?? 0.0;
    final isLikelyToHatch = probability > 0.5;

    return Container(
      decoration: BoxDecoration(
        color: isLikelyToHatch ? cs.primaryContainer : cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isLikelyToHatch ? cs.primary : cs.error).withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLikelyToHatch ? Icons.check_circle : Icons.warning,
                color: isLikelyToHatch ? cs.primary : cs.error,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLikelyToHatch ? 'Good Hatch Probability' : 'Low Hatch Probability',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isLikelyToHatch
                                ? cs.onPrimaryContainer
                                : cs.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(probability * 100).toStringAsFixed(1)}% chance of hatching',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: (isLikelyToHatch
                                    ? cs.onPrimaryContainer
                                    : cs.onErrorContainer)
                                .withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Egg Hatch Predictor')),
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
                    Icon(Icons.egg, size: 48, color: cs.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'Egg Hatch Prediction',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Temperature: ${_temperature.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _temperature,
                min: 30,
                max: 42,
                divisions: 120,
                label: '${_temperature.toStringAsFixed(1)}°C',
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Humidity: ${_humidity.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _humidity,
                min: 30,
                max: 80,
                divisions: 50,
                label: '${_humidity.toStringAsFixed(1)}%',
                onChanged: (value) {
                  setState(() {
                    _humidity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Egg Weight: ${_eggWeight.toStringAsFixed(1)}g',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _eggWeight,
                min: 40,
                max: 80,
                divisions: 40,
                label: '${_eggWeight.toStringAsFixed(1)}g',
                onChanged: (value) {
                  setState(() {
                    _eggWeight = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Turning Frequency: $_turningFrequency times/day',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _turningFrequency.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_turningFrequency times',
                onChanged: (value) {
                  setState(() {
                    _turningFrequency = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Incubation Duration: $_incubationDuration days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _incubationDuration.toDouble(),
                min: 1,
                max: 28,
                divisions: 27,
                label: 'Day $_incubationDuration',
                onChanged: (value) {
                  setState(() {
                    _incubationDuration = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isPredicting ? null : _predictHatch,
                icon: _isPredicting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(_isPredicting ? 'Predicting...' : 'Predict Hatch'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (_result != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}
