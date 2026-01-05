import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _formKey = GlobalKey<FormState>();
  double _currentPrice = 50.0;
  double _monthlyMilkLitres = 1000.0;
  double _fatPercentage = 4.0;
  double _snfPercentage = 8.5;
  int _diseaseStage = 0;
  int _feedQuality = 5;
  int _lactationMonth = 3;
  int _month = 1;
  bool _isPredicting = false;
  Map<String, dynamic>? _result;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  Future<void> _predictIncome() async {
    setState(() {
      _isPredicting = true;
    });

    try {
      final response = await ApiService.predictMilkMarket(
        currentPrice: _currentPrice,
        monthlyMilkLitres: _monthlyMilkLitres,
        fatPercentage: _fatPercentage,
        snfPercentage: _snfPercentage,
        diseaseStage: _diseaseStage,
        feedQuality: _feedQuality,
        lactationMonth: _lactationMonth,
        month: _month,
      );
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
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Milk Market Analyzer')),
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
                    Icon(Icons.analytics, size: 48, color: cs.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'Milk Market Prediction',
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
                'Current Price: LKR ${_currentPrice.toStringAsFixed(2)}/liter',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _currentPrice,
                min: 20,
                max: 200,
                divisions: 180,
                label: 'LKR ${_currentPrice.toStringAsFixed(2)}',
                onChanged: (v) => setState(() => _currentPrice = v),
              ),
              const SizedBox(height: 16),
              Text(
                'Monthly Milk: ${_monthlyMilkLitres.toStringAsFixed(0)} liters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _monthlyMilkLitres,
                min: 100,
                max: 5000,
                divisions: 49,
                label: '${_monthlyMilkLitres.toStringAsFixed(0)}L',
                onChanged: (v) => setState(() => _monthlyMilkLitres = v),
              ),
              const SizedBox(height: 16),
              Text(
                'Fat Percentage: ${_fatPercentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _fatPercentage,
                min: 2.0,
                max: 6.0,
                divisions: 40,
                label: '${_fatPercentage.toStringAsFixed(1)}%',
                onChanged: (v) => setState(() => _fatPercentage = v),
              ),
              const SizedBox(height: 16),
              Text(
                'SNF Percentage: ${_snfPercentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _snfPercentage,
                min: 7.0,
                max: 10.0,
                divisions: 30,
                label: '${_snfPercentage.toStringAsFixed(1)}%',
                onChanged: (v) => setState(() => _snfPercentage = v),
              ),
              const SizedBox(height: 16),
              Text(
                'Disease Stage: $_diseaseStage',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _diseaseStage.toDouble(),
                min: 0,
                max: 3,
                divisions: 3,
                label: '$_diseaseStage',
                onChanged: (v) => setState(() => _diseaseStage = v.toInt()),
              ),
              const SizedBox(height: 16),
              Text(
                'Feed Quality: $_feedQuality/10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _feedQuality.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_feedQuality',
                onChanged: (v) => setState(() => _feedQuality = v.toInt()),
              ),
              const SizedBox(height: 16),
              Text(
                'Lactation Month: $_lactationMonth',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _lactationMonth.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_lactationMonth',
                onChanged: (v) => setState(() => _lactationMonth = v.toInt()),
              ),
              const SizedBox(height: 16),
              Text(
                'Month: ${_monthNames[_month - 1]}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _month.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: _monthNames[_month - 1],
                onChanged: (v) => setState(() => _month = v.toInt()),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isPredicting ? null : _predictIncome,
                icon: _isPredicting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_isPredicting ? 'Predicting...' : 'Predict Income'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (_result != null) ...[
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
                            Icon(Icons.attach_money, color: cs.primary, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Prediction Results',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildResultRow(
                          'Next Month Income',
                          'LKR ${(_result!['predicted_next_month_income_lkr'] as num?)?.toStringAsFixed(2) ?? 'N/A'}',
                          cs,
                        ),
                        _buildResultRow(
                          'Next Month Price',
                          'LKR ${(_result!['predicted_next_month_price_lkr_per_litre'] as num?)?.toStringAsFixed(2) ?? 'N/A'} / L',
                          cs,
                        ),
                        _buildResultRow(
                          'Price Change',
                          'LKR ${(_result!['predicted_price_change_lkr_per_litre'] as num?)?.toStringAsFixed(2) ?? 'N/A'} / L',
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

  Widget _buildResultRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
