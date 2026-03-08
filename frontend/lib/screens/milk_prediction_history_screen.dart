import 'package:flutter/material.dart';
import '../api/prediction_api.dart';

class MilkPredictionHistoryScreen extends StatefulWidget {
  const MilkPredictionHistoryScreen({super.key});

  @override
  State<MilkPredictionHistoryScreen> createState() =>
      _MilkPredictionHistoryScreenState();
}

class _MilkPredictionHistoryScreenState
    extends State<MilkPredictionHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  String? _error;

  static const List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await PredictionApi.getMilkMarketHistory();
      // Most recent first
      data.sort((a, b) {
        final ta = a['created_at'] as String? ?? '';
        final tb = b['created_at'] as String? ?? '';
        return tb.compareTo(ta);
      });
      if (mounted) setState(() { _history = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Summary stats ──────────────────────────────────────────────────────────

  double get _avgNextIncome {
    if (_history.isEmpty) return 0;
    final sum = _history.fold<double>(
        0, (acc, r) => acc + ((r['predicted_next_income'] as num?)?.toDouble() ?? 0));
    return sum / _history.length;
  }

  double get _avgPriceChange {
    if (_history.isEmpty) return 0;
    final sum = _history.fold<double>(
        0, (acc, r) => acc + ((r['predicted_price_change'] as num?)?.toDouble() ?? 0));
    return sum / _history.length;
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _summaryChip(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> record, int index) {
    final cs = Theme.of(context).colorScheme;

    final currentPrice = (record['current_price'] as num?)?.toDouble() ?? 0;
    final monthlyLitres = (record['monthly_milk_litres'] as num?)?.toDouble() ?? 0;
    final fatPct = (record['fat_percentage'] as num?)?.toDouble() ?? 0;
    final snfPct = (record['snf_percentage'] as num?)?.toDouble() ?? 0;
    final diseaseStage = (record['disease_stage'] as num?)?.toInt() ?? 0;
    final feedQuality = (record['feed_quality'] as num?)?.toInt() ?? 0;
    final lactationMonth = (record['lactation_month'] as num?)?.toInt() ?? 0;
    final month = (record['month'] as num?)?.toInt() ?? 0;
    final priceChange = (record['predicted_price_change'] as num?)?.toDouble() ?? 0;
    final nextPrice = (record['predicted_next_price'] as num?)?.toDouble() ?? 0;
    final nextIncome = (record['predicted_next_income'] as num?)?.toDouble() ?? 0;
    final createdAt = record['created_at'] as String? ?? '';

    final isPositive = priceChange >= 0;
    final trendColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final trendIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    String dateLabel = '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      dateLabel =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      dateLabel = createdAt;
    }

    final monthName = (month >= 1 && month <= 12) ? _monthNames[month] : 'N/A';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('${index + 1}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monthName,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(dateLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                // Price trend badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: trendColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, color: trendColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)} LKR',
                        style: TextStyle(
                            color: trendColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Prediction result highlights
            Row(
              children: [
                Expanded(
                  child: _resultTile(
                    'Predicted Next Price',
                    'LKR ${nextPrice.toStringAsFixed(2)}/L',
                    Icons.price_change_outlined,
                    cs.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _resultTile(
                    'Predicted Income',
                    'LKR ${_formatNumber(nextIncome)}',
                    Icons.account_balance_wallet_outlined,
                    Colors.green.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Input data chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _infoChip('Current: LKR ${currentPrice.toStringAsFixed(2)}/L', Icons.monetization_on_outlined),
                _infoChip('${monthlyLitres.toStringAsFixed(0)} L/mo', Icons.water_drop_outlined),
                _infoChip('Fat ${fatPct.toStringAsFixed(1)}%', Icons.science_outlined),
                _infoChip('SNF ${snfPct.toStringAsFixed(1)}%', Icons.science_outlined),
                _infoChip('Lactation M$lactationMonth', Icons.timeline_outlined),
                _infoChip('Feed Q$feedQuality', Icons.grass_outlined),
                if (diseaseStage > 0)
                  _infoChip('Disease Stg $diseaseStage', Icons.warning_amber_outlined, color: Colors.orange.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Format large numbers: 1234567 → 1,234,567
  String _formatNumber(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '$buffer.$decPart';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Market History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: 12),
                        Text('Failed to load history',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      // ── Header banner ─────────────────────────────────
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primaryContainer, cs.secondaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.show_chart,
                                  size: 40, color: cs.onPrimaryContainer),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Milk Market Predictions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: cs.onPrimaryContainer)),
                                    Text(
                                        '${_history.length} prediction${_history.length == 1 ? '' : 's'} recorded',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: cs.onPrimaryContainer
                                                    .withOpacity(0.8))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Summary chips ─────────────────────────────────
                      if (_history.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                _summaryChip(
                                  'Avg Income',
                                  'LKR ${_formatNumber(_avgNextIncome)}',
                                  Colors.green.shade600,
                                  Icons.account_balance_wallet_outlined,
                                ),
                                const SizedBox(width: 10),
                                _summaryChip(
                                  'Avg Price Δ',
                                  '${_avgPriceChange >= 0 ? '+' : ''}${_avgPriceChange.toStringAsFixed(2)} LKR',
                                  _avgPriceChange >= 0
                                      ? Colors.blue.shade600
                                      : Colors.red.shade600,
                                  _avgPriceChange >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                ),
                                const SizedBox(width: 10),
                                _summaryChip(
                                  'Total Records',
                                  '${_history.length}',
                                  cs.primary,
                                  Icons.history,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ── Empty state ───────────────────────────────────
                      if (_history.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.show_chart,
                                    size: 64,
                                    color: cs.onSurfaceVariant.withOpacity(0.4)),
                                const SizedBox(height: 16),
                                Text('No predictions yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: cs.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(
                                    'Run a prediction in Milk Market Analyzer\nto see your history here.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.7))),
                              ],
                            ),
                          ),
                        ),

                      // ── History list ──────────────────────────────────
                      if (_history.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          sliver: SliverList.builder(
                            itemCount: _history.length,
                            itemBuilder: (_, i) =>
                                _historyCard(_history[i], i),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
