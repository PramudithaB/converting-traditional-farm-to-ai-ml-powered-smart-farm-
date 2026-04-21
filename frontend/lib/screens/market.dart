import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _priceCtrl = TextEditingController();            // Local_Milk_Price_LKR_per_Litre
  final _monthlyLitresCtrl = TextEditingController();    // Monthly_Milk_Litres
  final _fatCtrl = TextEditingController();              // Fat_Percentage
  final _snfCtrl = TextEditingController();              // SNF_Percentage
  final _lactMonthCtrl = TextEditingController();        // Lactation_Month

  // NEW: Total cows
  final _totalCowsCtrl = TextEditingController();

  // Dropdowns
  int _diseaseStage = 0;        // Disease_Stage (0=None, 1=Mild, 2=Moderate, 3=Severe)
  int _feedQuality = 2;         // Feed_Quality_Encoded (1=Poor, 2=Average, 3=Good)
  int _month = DateTime.now().month; // Month (1..12)

  bool _predicting = false;
  String? _result;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _monthlyLitresCtrl.dispose();
    _fatCtrl.dispose();
    _snfCtrl.dispose();
    _lactMonthCtrl.dispose();
    _totalCowsCtrl.dispose(); // NEW
    super.dispose();
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      fillColor: Colors.white.withOpacity(0.12),
    );
  }

  Future<void> _predictMarket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _predicting = true;
      _result = null;
    });

    // Parse inputs
    final price = double.parse(_priceCtrl.text.trim());
    final litres = double.parse(_monthlyLitresCtrl.text.trim());
    final fat = double.parse(_fatCtrl.text.trim());
    final snf = double.parse(_snfCtrl.text.trim());
    final lactMonth = int.parse(_lactMonthCtrl.text.trim());

    // NEW
    final totalCows = int.parse(_totalCowsCtrl.text.trim());

    final diseaseStage = _diseaseStage;
    final feedQuality = _feedQuality;
    final month = _month;

    // IMPORTANT:
    // Your Flask API currently expects keys like:
    // data['current_price'], data['monthly_milk_litres'], ...
    // So this payload should match THAT (not your feature column names).
    final payload = {
      'current_price': price,
      'monthly_milk_litres': litres,
      'fat_percentage': fat,
      'snf_percentage': snf,
      'disease_stage': diseaseStage,
      'feed_quality': feedQuality,
      'lactation_month': lactMonth,
      'month': month,
      'total_cows': totalCows, // NEW
    };

    // TODO: Replace with real API call
    // final response = await http.post(Uri.parse("http://<your-ip>:5000/predict-income"),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(payload),
    // );

    // --- Temporary heuristic (simulation only) ---
    double revenue = price * litres;

    // OPTIONAL: Use total cows to show "per cow litres" hint (pure UI simulation)
    final litresPerCow = litres / (totalCows == 0 ? 1 : totalCows);

    final fatFactor = 1.0 + ((fat - 3.5) / 20.0); // baseline ~3.5%
    final snfFactor = 1.0 + ((snf - 8.5) / 40.0); // baseline ~8.5%

    double feedFactor;
    switch (feedQuality) {
      case 1: feedFactor = 0.95; break;
      case 2: feedFactor = 1.00; break;
      case 3: feedFactor = 1.05; break;
      default: feedFactor = 1.0;
    }

    double diseaseFactor;
    switch (diseaseStage) {
      case 0: diseaseFactor = 1.00; break;
      case 1: diseaseFactor = 0.97; break;
      case 2: diseaseFactor = 0.92; break;
      case 3: diseaseFactor = 0.85; break;
      default: diseaseFactor = 1.0;
    }

    final peak = 4.0;
    final lactFactor = (1.05 - (((lactMonth - peak).abs()) / 40.0)).clamp(0.9, 1.05);

    const seasonal = {
      1: 1.00, 2: 0.99, 3: 1.01, 4: 1.02, 5: 1.03, 6: 0.98,
      7: 0.97, 8: 0.98, 9: 1.00, 10: 1.02, 11: 1.01, 12: 1.00,
    };
    final monthFactor = seasonal[month] ?? 1.0;

    final adjustedRevenue = revenue * fatFactor * snfFactor * feedFactor * diseaseFactor * lactFactor * monthFactor;

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _predicting = false;
      _result =
      'Estimated monthly revenue: LKR ${adjustedRevenue.toStringAsFixed(0)}\n'
          'Inputs:\n'
          '• Price: LKR ${price.toStringAsFixed(2)} / L\n'
          '• Litres: ${litres.toStringAsFixed(0)} L\n'
          '• Total cows: $totalCows\n'
          '• Litres/cow: ${litresPerCow.toStringAsFixed(2)} L\n'
          '• Fat: ${fat.toStringAsFixed(2)}%\n'
          '• SNF: ${snf.toStringAsFixed(2)}%\n'
          '• Lactation month: $lactMonth\n'
          '• Month: $month';
    });
  }

  Widget _glassContainer(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Market Analyze')),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _glassContainer(
                context,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: cs.primaryContainer,
                            child: Icon(Icons.show_chart, color: cs.onPrimaryContainer),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Milk Market Predictor',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _priceCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(context, 'Local Milk Price (LKR/Litre)', Icons.currency_rupee),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0) return 'Enter a valid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _monthlyLitresCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(context, 'Monthly Milk (Litres)', Icons.water_drop),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0) return 'Enter litres for the month';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // NEW FIELD: Total Cows
                      TextFormField(
                        controller: _totalCowsCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(context, 'Total Cows', Icons.pets),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0) return 'Enter total number of cows';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _fatCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(context, 'Fat Percentage (%)', Icons.scale),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          if (n == null || n < 0) return 'Enter a valid %';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _snfCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(context, 'SNF Percentage (%)', Icons.bubble_chart),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          if (n == null || n < 0) return 'Enter a valid %';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),



                      TextFormField(
                        controller: _lactMonthCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(context, 'Lactation Month', Icons.calendar_month),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n < 0) return 'Enter a valid month number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      InputDecorator(
                        decoration: _inputDecoration(context, 'Month', Icons.event),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _month,
                            items: List.generate(12, (i) {
                              final m = i + 1;
                              return DropdownMenuItem(
                                value: m,
                                child: Text('Month $m'),
                              );
                            }),
                            onChanged: (v) => setState(() => _month = v ?? DateTime.now().month),
                            dropdownColor: Colors.black87,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_result != null)
                        Text(
                          _result!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _predicting ? null : _predictMarket,
                          icon: _predicting
                              ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.insights),
                          label: const Text('Predict Market'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}