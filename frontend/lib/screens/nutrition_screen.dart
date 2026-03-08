import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../api/prediction_api.dart';
import '../api/cow_api.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  // ── Cattle picker ──
  List<Map<String, dynamic>> _cows = [];
  Map<String, dynamic>? _selectedCow;
  bool _isLoadingCows = true;

  // ── Input fields ──
  int _ageMonths = 36;
  double _weightKg = 450.0;
  String _breed = 'Friesian';
  double _milkYield = 25.0;
  String _activityLevel = 'Medium';
  String _healthStatus = 'Healthy';
  String _disease = 'None';
  double _bodyConditionScore = 3.0;
  String _location = 'Dry Zone';
  double _energyMJ = 100.0;
  double _crudeProtein = 1500.0;
  String _feedType = 'Mixed';

  List<String> _breeds = [
    // ── Dairy breeds widely used in Sri Lanka ──
    'Friesian', 'Jersey', 'Ayrshire', 'Brown Swiss',
    // ── South Asian breeds popular in Sri Lanka ──
    'Sahiwal', 'Red Sindhi', 'Gir (Gyr)', 'Tharparkar', 'Ongole',
    // ── Indigenous / local breeds ──
    'Lanka White (Sinhala)', 'Local',
    // ── Fallback ──
    'Other',
  ];
  final List<String> _activityLevels = ['Medium', 'High'];
  final List<String> _healthStatuses = ['Healthy', 'Disease', 'Recovering'];
  final List<String> _diseases = ['None', 'Mastitis', 'Lameness', 'Metabolic', 'Respiratory'];
  final List<String> _locations = ['Dry Zone', 'Wet Zone'];
  final List<String> _feedTypes = ['Mixed', 'Grass clippings', 'Milk'];

  @override
  void initState() {
    super.initState();
    _loadCows();
  }

  Future<void> _loadCows() async {
    try {
      final cows = await CowApi.getCows();
      if (mounted) setState(() { _cows = cows; _isLoadingCows = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingCows = false);
    }
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  /// Called when user picks a cow from the dropdown.
  /// Prefills fields from cow DB data, then overlays saved inputs from the
  /// latest nutrition recommendation (if any).
  Future<void> _onCowSelected(Map<String, dynamic> cow) async {
    // ── Prefill from cow DB fields (all in one setState to avoid partial rebuilds) ──
    setState(() {
      _selectedCow = cow;

      // Breed — VARCHAR, always a string
      final breed = cow['breed'] as String?;
      if (breed != null && breed.isNotEmpty) {
        if (!_breeds.contains(breed)) _breeds = [..._breeds, breed];
        _breed = breed;
      }

      // Weight — DECIMAL from MySQL may come back as a string ("450.00") or num
      final rawW = cow['weight'];
      if (rawW != null) {
        final wVal = rawW is num
            ? rawW.toDouble()
            : double.tryParse(rawW.toString());
        if (wVal != null) _weightKg = wVal.clamp(200.0, 800.0);
      }

      // Age from birthdate
      final birthdateStr = cow['birthdate'] as String?;
      if (birthdateStr != null && birthdateStr.isNotEmpty) {
        final birth = DateTime.tryParse(birthdateStr);
        if (birth != null) {
          final months = _monthsBetween(birth, DateTime.now());
          _ageMonths = months.clamp(12, 120);
        }
      }

      // Health Status from previous_disease (disease is fixed to 'None')
      final prevDisease = cow['previous_disease'];
      _healthStatus = (prevDisease is List && prevDisease.isNotEmpty)
          ? 'Disease'
          : 'Healthy';
    });

    // ── Overlay with latest saved nutrition input_data ──
    try {
      final cowDbId = cow['id'] as int;
      final latest = await CowApi.getLatestNutrition(cowDbId);
      if (latest != null) {
        final input = latest['input_data'] as Map<String, dynamic>?;
        if (input != null && mounted) {
          setState(() {
            final b = input['Breed'] as String?;
            if (b != null && b.isNotEmpty) {
              if (!_breeds.contains(b)) _breeds = [..._breeds, b];
              _breed = b;
            }

            final w = (input['Weight_kg'] as num?)?.toDouble();
            if (w != null) _weightKg = w.clamp(200.0, 800.0);

            final a = (input['Age_Months'] as num?)?.toInt();
            if (a != null) _ageMonths = a.clamp(12, 120);

            final hs = input['Health_Status'] as String?;
            if (hs != null && _healthStatuses.contains(hs)) _healthStatus = hs;

            // Disease is fixed to 'None' — skip overlay

            final m = (input['Milk_Yield_L_per_day'] as num?)?.toDouble();
            if (m != null) _milkYield = m.clamp(0.0, 50.0);

            final al = input['Activity_Level'] as String?;
            if (al != null && _activityLevels.contains(al)) _activityLevel = al;

            final bcs = (input['Body_Condition_Score'] as num?)?.toDouble();
            if (bcs != null) _bodyConditionScore = bcs.clamp(1.0, 5.0);

            final loc = input['Location'] as String?;
            if (loc != null && _locations.contains(loc)) _location = loc;

            final e = (input['Energy_MJ_per_day'] as num?)?.toDouble();
            // Energy has fixed default of 100 — skip overlay

            final cp = (input['Crude_Protein_g_per_day'] as num?)?.toDouble();
            if (cp != null) _crudeProtein = cp.clamp(500.0, 3000.0);

            final ft = input['Recommended_Feed_Type'] as String?;
            if (ft != null && _feedTypes.contains(ft)) _feedType = ft;
          });
        }
      }
    } catch (_) {
      // No previous nutrition data — cow fields alone are used
    }
  }

  Future<void> _getNutritionRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _result = null; });

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

      setState(() { _result = response; _isLoading = false; });

      // ── Save to database ──
      final pred = response['prediction'] as Map<String, dynamic>?;
      if (pred != null) {
        final inputData = {
          'Age_Months': _ageMonths,
          'Weight_kg': _weightKg,
          'Breed': _breed,
          'Milk_Yield_L_per_day': _milkYield,
          'Activity_Level': _activityLevel,
          'Health_Status': _healthStatus,
          'Disease': _disease,
          'Body_Condition_Score': _bodyConditionScore,
          'Location': _location,
          'Energy_MJ_per_day': _energyMJ,
          'Crude_Protein_g_per_day': _crudeProtein,
          'Recommended_Feed_Type': _feedType,
        };

        PredictionApi.saveNutrition(
          cowId: (_selectedCow?['id'] as int?),
          inputData: inputData,
          dryMatterIntakeKg: (pred['Dry_Matter_Intake_kg_per_day'] as num).toDouble(),
          calciumGPerDay: (pred['Calcium_g_per_day'] as num).toDouble(),
          phosphorusGPerDay: (pred['Phosphorus_g_per_day'] as num).toDouble(),
        ).catchError((e) => debugPrint('Save nutrition failed: $e'));

        // ── Sync changed inputs back to the cow record ──
        if (_selectedCow != null) {
          final cowDbId = _selectedCow!['id'] as int;
          CowApi.updateCowProfile(
            cowId: cowDbId,
            weight: _weightKg,
            previousDisease: _disease != 'None' ? [_disease] : [],
          ).catchError((e) => debugPrint('Update cow failed: $e'));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Recommendations')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
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
                      'Select a cattle to auto-fill fields from database',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Cattle Dropdown ──
              Text('Select Cattle', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _isLoadingCows
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedCow,
                      hint: const Text('Choose a cattle (optional)'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cs.primaryContainer.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.primary),
                        ),
                        prefixIcon: const Icon(Icons.pets),
                      ),
                      items: [
                        const DropdownMenuItem<Map<String, dynamic>>(
                          value: null,
                          child: Text('-- Manual entry --'),
                        ),
                        ..._cows.map((cow) => DropdownMenuItem<Map<String, dynamic>>(
                              value: cow,
                              child: Text(
                                '${cow['name'] ?? 'Unnamed'} (${cow['cow_id'] ?? ''})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (cow) {
                        if (cow == null) {
                          setState(() => _selectedCow = null);
                        } else {
                          _onCowSelected(cow);
                        }
                      },
                    ),

              if (_selectedCow != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: cs.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fields pre-filled from database. You can adjust before predicting.',
                          style: TextStyle(fontSize: 12, color: cs.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),

              // ── Age ──
              Text('Age: $_ageMonths months', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _ageMonths.toDouble(),
                min: 12, max: 120, divisions: 108,
                label: '$_ageMonths months',
                onChanged: (v) => setState(() => _ageMonths = v.toInt()),
              ),
              const SizedBox(height: 16),

              // ── Weight ──
              Text('Weight: ${_weightKg.toStringAsFixed(0)} kg', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _weightKg,
                min: 200, max: 800, divisions: 60,
                label: '${_weightKg.toStringAsFixed(0)}kg',
                onChanged: (v) => setState(() => _weightKg = v),
              ),
              const SizedBox(height: 16),

              // ── Breed ──
              Text('Breed', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _breed,
                decoration: InputDecoration(
                  filled: true, fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: _breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _breed = v!),
              ),
              const SizedBox(height: 16),

              // ── Milk Yield ──
              Text('Milk Yield: ${_milkYield.toStringAsFixed(1)} L/day', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _milkYield,
                min: 0, max: 50, divisions: 50,
                label: '${_milkYield.toStringAsFixed(1)}L',
                onChanged: (v) => setState(() => _milkYield = v),
              ),
              const SizedBox(height: 16),

              // ── Activity Level ──
              Text('Activity Level', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                decoration: InputDecoration(
                  filled: true, fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: _activityLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _activityLevel = v!),
              ),
              const SizedBox(height: 16),

              // ── Health Status ──
              Text('Health Status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _healthStatus,
                decoration: InputDecoration(
                  filled: true, fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: _healthStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _healthStatus = v!),
              ),
              const SizedBox(height: 16),

              // ── Body Condition Score ──
              Text('Body Condition Score: ${_bodyConditionScore.toStringAsFixed(1)}', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _bodyConditionScore,
                min: 1.0, max: 5.0, divisions: 40,
                label: _bodyConditionScore.toStringAsFixed(1),
                onChanged: (v) => setState(() => _bodyConditionScore = v),
              ),
              const SizedBox(height: 16),

              // ── Location ──
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: InputDecoration(
                  filled: true, fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _location = v!),
              ),
              const SizedBox(height: 16),

              // ── Crude Protein ──
              Text('Crude Protein: ${_crudeProtein.toStringAsFixed(0)} g/day', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _crudeProtein,
                min: 500, max: 3000, divisions: 50,
                label: '${_crudeProtein.toStringAsFixed(0)}g',
                onChanged: (v) => setState(() => _crudeProtein = v),
              ),
              const SizedBox(height: 16),

              // ── Feed Type ──
              Text('Feed Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _feedType,
                decoration: InputDecoration(
                  filled: true, fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: _feedTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _feedType = v!),
              ),
              const SizedBox(height: 24),

              // ── Predict Button ──
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getNutritionRecommendation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.science),
                label: Text(_isLoading ? 'Analyzing...' : 'Get Recommendations'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // ── Results ──
              if (_result != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (_selectedCow != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Cattle: ${_selectedCow!['name']} (${_selectedCow!['cow_id']})',
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
                          ),
                        ],
                        const Divider(height: 24),
                        _buildNutritionItem(
                          'Dry Matter Intake',
                          '${(_result!['prediction'] as Map?)?['Dry_Matter_Intake_kg_per_day'] ?? 'N/A'} kg/day',
                          Icons.grass, cs,
                        ),
                        _buildNutritionItem(
                          'Calcium',
                          '${(_result!['prediction'] as Map?)?['Calcium_g_per_day'] ?? 'N/A'} g/day',
                          Icons.water_drop, cs,
                        ),
                        _buildNutritionItem(
                          'Phosphorus',
                          '${(_result!['prediction'] as Map?)?['Phosphorus_g_per_day'] ?? 'N/A'} g/day',
                          Icons.science, cs,
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
                Text(label, style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
