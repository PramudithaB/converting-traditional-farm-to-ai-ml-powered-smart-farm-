import 'package:flutter/material.dart';
import '../api/cow_api.dart';
import '../api/prediction_api.dart';
import '../services/api_service.dart';

class AnimalBirthScreen extends StatefulWidget {
  const AnimalBirthScreen({super.key});

  @override
  State<AnimalBirthScreen> createState() => _AnimalBirthScreenState();
}

class _AnimalBirthScreenState extends State<AnimalBirthScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Cow list ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _cows = [];
  bool _loadingCows = true;
  int? _selectedCowDbId; // DB id of the selected cow

  // ── Prediction state ─────────────────────────────────────────────────────
  bool _isPredicting = false;
  Map<String, dynamic>? _result;

  // Backend expects: [age, parity, temp, milk, weight]
  double _ageMonths = 40;
  int _parity = 2;
  double _bodyTempCelsius = 38.5;
  double _milkYieldKg = 12.3;
  double _bodyWeightKg = 450;

  @override
  void initState() {
    super.initState();
    _loadCows();
  }

  Future<void> _loadCows() async {
    try {
      final cows = await CowApi.getCows();
      if (mounted) setState(() { _cows = cows; _loadingCows = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCows = false);
    }
  }

  void _onCowSelected(int? dbId) {
    setState(() => _selectedCowDbId = dbId);
    if (dbId == null) return;

    final cow = _cows.firstWhere((c) => c['id'] == dbId, orElse: () => {});
    if (cow.isEmpty) return;

    // Weight
    final w = cow['weight'];
    if (w != null) {
      final wVal = (w is num ? w.toDouble() : double.tryParse(w.toString()));
      if (wVal != null && wVal >= 150 && wVal <= 1000) {
        _bodyWeightKg = wVal;
      }
    }

    // Age from birthdate
    final bdRaw = cow['birthdate'] as String?;
    if (bdRaw != null) {
      try {
        final bd = DateTime.parse(bdRaw);
        final now = DateTime.now();
        final months = (now.year - bd.year) * 12 + (now.month - bd.month);
        if (months > 0 && months <= 200) _ageMonths = months.toDouble();
      } catch (_) {}
    }

    // Parity = number of times the cow has calved (stored as its own field)
    final p = cow['parity'];
    if (p != null) {
      final pVal = p is int ? p : int.tryParse(p.toString());
      if (pVal != null && pVal >= 0 && pVal <= 10) _parity = pVal;
    }
  }

  Future<void> _predictBirth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isPredicting = true; _result = null; });

    try {
      final features = <double>[
        _ageMonths,
        _parity.toDouble(),
        _bodyTempCelsius,
        _milkYieldKg,
        _bodyWeightKg,
      ];

      final response = await ApiService.predictAnimalBirth(features: features);

      // Save to Laravel
      final estDays = (response['estimated_days_to_birth'] as num?)?.toDouble() ?? 0;
      final willBirth = response['will_birth_in_next_2_days']?.toString() ?? 'No';
      await PredictionApi.saveAnimalBirth(
        cowId: _selectedCowDbId,
        features: features,
        estimatedDaysToBirth: estDays,
        willBirthIn2Days: willBirth,
      );

      setState(() { _result = response; _isPredicting = false; });
    } catch (e) {
      setState(() => _isPredicting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Animal Birth Prediction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────
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
                    Icon(Icons.pets_outlined, size: 48, color: cs.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'Predict Birth Timing',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select a cow or enter parameters manually',
                      style: TextStyle(color: cs.onPrimaryContainer.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Cow dropdown ─────────────────────────────────────────────
              _loadingCows
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedCowDbId,
                      decoration: InputDecoration(
                        labelText: 'Select Cow (optional)',
                        prefixIcon: const Icon(Icons.pets),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        suffixIcon: _selectedCowDbId != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  _selectedCowDbId = null;
                                }),
                              )
                            : null,
                      ),
                      hint: const Text('Auto-fill from cow record'),
                      items: [
                        ..._cows.map((c) {
                          final label =
                              '${c['cow_id'] ?? '—'}  ·  ${c['name'] ?? '—'}';
                          return DropdownMenuItem<int>(
                            value: c['id'] as int?,
                            child: Text(label),
                          );
                        }),
                      ],
                      onChanged: _onCowSelected,
                    ),

              if (_selectedCowDbId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Weight, age and parity pre-filled from cow record. Adjust sliders if needed.',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // ── Age ───────────────────────────────────────────────────────
              Text('Age (Months): ${_ageMonths.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _ageMonths,
                min: 1,
                max: 200,
                divisions: 199,
                label: _ageMonths.toStringAsFixed(0),
                onChanged: (v) => setState(() => _ageMonths = v),
              ),

              const SizedBox(height: 8),

              // ── Parity ───────────────────────────────────────────────────
              Text('Parity: $_parity',
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _parity.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: _parity.toString(),
                onChanged: (v) => setState(() => _parity = v.round()),
              ),

              const SizedBox(height: 8),

              // ── Body Temperature ─────────────────────────────────────────
              Text(
                'Body Temperature: ${_bodyTempCelsius.toStringAsFixed(1)} °C',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyTempCelsius,
                min: 34.0,
                max: 42.0,
                divisions: 80,
                label: '${_bodyTempCelsius.toStringAsFixed(1)} °C',
                onChanged: (v) => setState(() => _bodyTempCelsius = v),
              ),

              const SizedBox(height: 8),

              // ── Milk Yield ───────────────────────────────────────────────
              Text(
                'Milk Yield: ${_milkYieldKg.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _milkYieldKg,
                min: 0,
                max: 60,
                divisions: 600,
                label: '${_milkYieldKg.toStringAsFixed(1)} kg',
                onChanged: (v) => setState(() => _milkYieldKg = v),
              ),

              const SizedBox(height: 8),

              // ── Body Weight ──────────────────────────────────────────────
              Text(
                'Body Weight: ${_bodyWeightKg.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _bodyWeightKg,
                min: 150,
                max: 1000,
                divisions: 850,
                label: '${_bodyWeightKg.toStringAsFixed(0)} kg',
                onChanged: (v) => setState(() => _bodyWeightKg = v),
              ),

              const SizedBox(height: 24),

              // ── Predict button ───────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _isPredicting ? null : _predictBirth,
                icon: _isPredicting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.analytics),
                label: Text(_isPredicting ? 'Predicting…' : 'Predict Birth'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),

              const SizedBox(height: 24),

              // ── Result card ──────────────────────────────────────────────
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
                              'Prediction Results',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildResultItem(
                          'Will Birth in 1 Day',
                          _result!['will_birth_in_next_2_days'] ?? 'N/A',
                          cs,
                        ),
                        const SizedBox(height: 12),
                        _buildResultItem(
                          'Estimated Hours to Birth',
                          _result!['estimated_days_to_birth']?.toString() ?? 'N/A',
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
    final isYes = text.toLowerCase().contains('yes');
    final isNo = text.toLowerCase().contains('no');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(0.7))),
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

