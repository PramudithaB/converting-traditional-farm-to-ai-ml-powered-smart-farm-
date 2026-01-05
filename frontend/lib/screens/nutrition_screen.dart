import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  int _ageMonths = 36;
  double _weightKg = 450.0;
  String _breed = 'Holstein';
  double _milkYield = 25.0;
  String _activityLevel = 'Medium';
  String _healthStatus = 'Healthy';
  String _disease = 'None';
  double _bodyConditionScore = 3.0;
  String _location = 'Farm';
  double _energyMJ = 120.0;
  double _crudeProtein = 1500.0;
  String _feedType = 'Mixed';

  final List<String> _breeds = ['Holstein', 'Jersey', 'Brown Swiss', 'Guernsey', 'Ayrshire'];
  final List<String> _activityLevels = ['Low', 'Medium', 'High'];
  final List<String> _healthStatuses = ['Healthy', 'Disease', 'Recovering'];
  final List<String> _diseases = ['None', 'Mastitis', 'Lameness', 'Metabolic', 'Respiratory'];
  final List<String> _locations = ['Farm', 'Pasture', 'Barn', 'Open'];
  final List<String> _feedTypes = ['Mixed', 'Hay', 'Silage', 'Concentrate', 'Pasture'];

  Future<void> _getNutritionRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final response = await ApiService.recommendNutrition(
        ageMonths: _ageMonths,
        weightKg: _weightKg,
        breed: _breed,
        milkYield: _milkYield,
        activityLevel: _activityLevel,
        healthStatus: _healthStatus,
        disease: _disease,
        bodyConditionScore: _bodyConditionScore,
        location: _location,
        energyMJ: _energyMJ,
        crudeProtein: _crudeProtein,
        feedType: _feedType,
      );

      print('Nutrition API Response: $response'); // Debug output
      
      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
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
        title: const Text('Nutrition Recommendations'),
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
                      'AI-Powered Nutrition Advisor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get personalized feed recommendations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Age
              Text(
                'Age: $_ageMonths months',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _ageMonths.toDouble(),
                min: 12,
                max: 120,
                divisions: 108,
                label: '$_ageMonths months',
                onChanged: (value) => setState(() => _ageMonths = value.toInt()),
              ),
              const SizedBox(height: 16),
              
              // Weight
              Text(
                'Weight: ${_weightKg.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _weightKg,
                min: 200,
                max: 800,
                divisions: 60,
                label: '${_weightKg.toStringAsFixed(0)}kg',
                onChanged: (value) => setState(() => _weightKg = value),
              ),
              const SizedBox(height: 16),
              
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
                'Activity Level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _activityLevel,
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
                onChanged: (value) => setState(() => _activityLevel = value!),
              ),
              const SizedBox(height: 16),
              
              // Health Status
              Text(
                'Health Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _healthStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _healthStatuses
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _healthStatus = value!),
              ),
              const SizedBox(height: 16),
              
              // Disease
              Text(
                'Disease',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _disease,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _diseases
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => _disease = value!),
              ),
              const SizedBox(height: 16),
              
              // Body Condition Score
              Text(
                'Body Condition Score: ${_bodyConditionScore.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyConditionScore,
                min: 1.0,
                max: 5.0,
                divisions: 40,
                label: _bodyConditionScore.toStringAsFixed(1),
                onChanged: (value) => setState(() => _bodyConditionScore = value),
              ),
              const SizedBox(height: 16),
              
              // Location
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _locations
                    .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                    .toList(),
                onChanged: (value) => setState(() => _location = value!),
              ),
              const SizedBox(height: 16),
              
              // Energy
              Text(
                'Energy: ${_energyMJ.toStringAsFixed(0)} MJ/day',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _energyMJ,
                min: 50,
                max: 200,
                divisions: 150,
                label: '${_energyMJ.toStringAsFixed(0)} MJ',
                onChanged: (value) => setState(() => _energyMJ = value),
              ),
              const SizedBox(height: 16),
              
              // Crude Protein
              Text(
                'Crude Protein: ${_crudeProtein.toStringAsFixed(0)} g/day',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _crudeProtein,
                min: 500,
                max: 3000,
                divisions: 50,
                label: '${_crudeProtein.toStringAsFixed(0)}g',
                onChanged: (value) => setState(() => _crudeProtein = value),
              ),
              const SizedBox(height: 16),
              
              // Feed Type
              Text(
                'Feed Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _feedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _feedTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _feedType = value!),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getNutritionRecommendation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.science),
                label: Text(_isLoading ? 'Analyzing...' : 'Get Recommendations'),
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
                            Icon(Icons.recommend, color: cs.primary, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Recommendations',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildNutritionItem(
                          'Dry Matter Intake',
                          '${(_result!['prediction'] as Map?)?['Dry_Matter_Intake_kg_per_day'] ?? 'N/A'} kg/day',
                          Icons.grass,
                          cs,
                        ),
                        _buildNutritionItem(
                          'Calcium',
                          '${(_result!['prediction'] as Map?)?['Calcium_g_per_day'] ?? 'N/A'} g/day',
                          Icons.water_drop,
                          cs,
                        ),
                        _buildNutritionItem(
                          'Phosphorus',
                          '${(_result!['prediction'] as Map?)?['Phosphorus_g_per_day'] ?? 'N/A'} g/day',
                          Icons.science,
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

  Widget _buildNutritionItem(String label, String value, IconData icon, ColorScheme cs) {
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
                    fontSize: 18,
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
