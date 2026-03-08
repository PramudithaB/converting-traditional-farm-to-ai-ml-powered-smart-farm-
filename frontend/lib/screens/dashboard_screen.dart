import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/cow_api.dart';
import '../config/app_config.dart';
import '../api/prediction_api.dart';
import 'add_cow_screen.dart';
import 'login_screen.dart';
// AI Service Screens
import 'animal_birth_screen.dart';
import 'hatching.dart';
import 'market.dart';
import 'feed.dart';
import 'identico.dart';
import 'disease_detection_screen.dart';
import 'complete_disease_analysis_screen.dart';
import 'behavior_detection_screen.dart';
import 'milk_prediction_history_screen.dart';
import 'model_comparison_screen.dart';
import 'video_analysis_screen.dart';
import 'nutrition_screen.dart';
import 'cow_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── state ──────────────────────────────────────────────────────────────────
  int _cowCount = 0;
  double _avgLm = 0;
  int _upcomingBirths = 0;   // will_birth_in_2_days == "Yes"
  int _diseaseAlerts = 0;    // detections where disease != Healthy
  List<Map<String, dynamic>> _cows = [];
  List<Map<String, dynamic>> _recentAlerts = [];   // last 5 disease/behavior
  bool _loading = true;
  String _userName = 'Farmer';

  // ── load ───────────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('userName') ?? 'Farmer';

      // all three in parallel
      final results = await Future.wait([
        CowApi.getCows(),
        PredictionApi.getAnimalBirthHistory(),
        PredictionApi.getDiseaseHistory(),
        PredictionApi.getBehaviorHistory(),
      ]);

      final cows     = results[0] as List<Map<String, dynamic>>;
      final births   = results[1] as List<Map<String, dynamic>>;
      final diseases = results[2] as List<Map<String, dynamic>>;
      final behaviors = results[3] as List<Map<String, dynamic>>;

      // Cow metrics
      double totalLm = 0;
      int lmCount = 0;
      for (final c in cows) {
        final lm = c['lactation_month'];
        if (lm != null) {
          totalLm += (lm is int ? lm.toDouble() : double.tryParse(lm.toString()) ?? 0);
          lmCount++;
        }
      }

      // Upcoming births in next 2 days
      final upcoming = births
          .where((b) => (b['will_birth_in_2_days'] as String? ?? '').toLowerCase() == 'yes')
          .length;

      // Disease alerts (non-healthy)
      final alerts = diseases
          .where((d) => (d['disease_name'] as String? ?? '').toLowerCase() != 'healthy')
          .toList();

      // Build recent alerts list (disease + behavior, sorted by created_at desc)
      final diseaseItems = diseases.take(5).map((d) => {
        ...d,
        '_alert_type': 'disease',
      }).toList();
      final behaviorItems = behaviors.take(5).map((b) => {
        ...b,
        '_alert_type': 'behavior',
      }).toList();

      final allAlerts = [...diseaseItems, ...behaviorItems];
      allAlerts.sort((a, b) {
        final ta = a['created_at'] as String? ?? '';
        final tb = b['created_at'] as String? ?? '';
        return tb.compareTo(ta);
      });

      if (!mounted) return;
      setState(() {
        _userName      = storedName;
        _cows          = cows;
        _cowCount      = cows.length;
        _avgLm         = lmCount > 0 ? totalLm / lmCount : 0;
        _upcomingBirths = upcoming;
        _diseaseAlerts  = alerts.length;
        _recentAlerts   = allAlerts.take(5).toList();
        _loading        = false;
      });
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserId');
    await prefs.remove('authToken');
    await prefs.remove('userName');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── widgets ────────────────────────────────────────────────────────────────

  Widget _statCard(String title, String value, IconData icon, {Color? accent}) {
    final cs = Theme.of(context).colorScheme;
    final color = accent ?? cs.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: cs.primary, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final cs = Theme.of(context).colorScheme;
    final type = alert['_alert_type'] as String;
    final isDisease = type == 'disease';

    final title = isDisease
        ? (alert['disease_name'] as String? ?? 'Unknown disease')
        : (alert['behavior'] as String? ?? 'Unknown behavior');

    final sub = isDisease
        ? 'Model: ${alert['model_used'] ?? '—'} · Conf: ${((alert['confidence'] as num? ?? 0) * 100).toStringAsFixed(0)}%'
        : 'Type: ${alert['detection_type'] ?? '—'} · Conf: ${(((alert['confidence'] as num?) ?? 0) * 100).toStringAsFixed(0)}%';

    final isHealthy = title.toLowerCase() == 'healthy';
    final color = isHealthy ? Colors.green : (isDisease ? Colors.red : Colors.orange);
    final icon = isHealthy
        ? Icons.check_circle_outline
        : (isDisease ? Icons.medical_services : Icons.directions_walk);

    final cow = alert['cow'] as Map<String, dynamic>?;
    final cowLabel = cow != null
        ? '${cow['cow_id'] ?? ''}  ${cow['name'] ?? ''}'.trim()
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(sub,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                if (cowLabel != null && cowLabel.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.pets, size: 11, color: cs.primary.withOpacity(0.7)),
                      const SizedBox(width: 3),
                      Text(
                        cowLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isDisease)
            Chip(
              label: Text(
                isHealthy ? 'Healthy' : 'Unhealthy',
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: isHealthy ? Colors.green.shade500 : Colors.red.shade500,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          else
            Chip(
              label: const Text(
                'Behavior',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.teal.shade500,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _componentCard(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    final accent = color ?? cs.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
                color: accent.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ── cow card ───────────────────────────────────────────────────────────────

  Widget _cowCard(Map<String, dynamic> row) {
    final cs = Theme.of(context).colorScheme;
    final name  = (row['name']  ?? '') as String;
    final breed = (row['breed'] ?? '—') as String;
    final lm    = row['lactation_month'] ?? 0;
    final img   = row['image_path'] as String?;
    final cowId = (row['cow_id'] ?? '') as String;
    final id    = row['id'] as int?;

    return GestureDetector(
      onTap: id != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CowProfileScreen(initialCowId: id)))
          : null,
      child: Container(
      width: 180,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: cs.primary.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: img != null
                ? Image.network(
                    '${AppConfig.laravelBase}/$img',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _cowPlaceholder(cs),
                  )
                : _cowPlaceholder(cs),
          ),
          // info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.grass, size: 13, color: cs.primary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(breed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.water_drop, size: 13, color: cs.secondary),
                  const SizedBox(width: 3),
                  Text('LM $lm',
                      style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  Text(cowId,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _cowPlaceholder(ColorScheme cs) => Container(
        height: 100,
        width: double.infinity,
        color: cs.primaryContainer,
        child: Icon(Icons.image_not_supported_outlined,
            color: cs.onPrimaryContainer.withOpacity(0.4), size: 32),
      );

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              stretch: true,
              backgroundColor: cs.surface,
              actions: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                else
                  IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
                IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_greeting()}, $_userName 👋',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: cs.onPrimary.withOpacity(0.9))),
                        const SizedBox(height: 4),
                        Text('Smart Farm Dashboard',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: cs.onPrimary, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Track metrics, monitor health & manage your herd',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onPrimary.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats grid (2 × 2) ───────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.0,
                children: [
                  _statCard('Total Cows', '$_cowCount', Icons.pets),
                  _statCard('Avg Lactation', _avgLm.toStringAsFixed(1), Icons.auto_graph,
                      accent: cs.secondary),
                  _statCard('Upcoming Births', '$_upcomingBirths', Icons.child_friendly,
                      accent: Colors.green.shade600),
                  _statCard('Disease Alerts', '$_diseaseAlerts', Icons.warning_amber_rounded,
                      accent: _diseaseAlerts > 0 ? Colors.red.shade600 : Colors.green.shade600),
                ],
              ),
            ),

            // ── Quick Actions ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _quickAction('Add Cow', Icons.add_circle_outline, () async {
                          await Navigator.pushNamed(context, AddCowScreen.routeName);
                          _loadAll();
                        }),
                        const SizedBox(width: 10),
                        _quickAction('Identify\nCow', Icons.qr_code_scanner, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const IdenticoScreen()));
                        }),
                        const SizedBox(width: 10),
                        _quickAction('Disease\nCheck', Icons.medical_services_outlined, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen()));
                        }),
                        const SizedBox(width: 10),
                        _quickAction('Feed\nCalc', Icons.restaurant_outlined, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FeedScreen()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Recent Health Alerts ──────────────────────────────────────
            if (_recentAlerts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Recent Health Alerts',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          if (_diseaseAlerts > 0)
                            Chip(
                              label: Text('$_diseaseAlerts active',
                                  style: const TextStyle(fontSize: 11)),
                              backgroundColor: const ui.Color.fromARGB(255, 11, 11, 11),
                              side: BorderSide(color: const ui.Color.fromARGB(255, 240, 212, 3)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._recentAlerts.map(_alertCard),
                    ],
                  ),
                ),
              ),

            // ── AI Components ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text('AI Services',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverList.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _components.length,
                itemBuilder: (context, i) {
                  final c = _components[i];
                  return _componentCard(c.title, c.icon, c.onTap, color: c.color);
                },
              ),
            ),

            // ── Recently Added Cows ───────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text('Your Herd',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(
              child: _cows.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('No cows yet. Tap + to add.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    )
                  : SizedBox(
                      height: 210,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _cows.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _cowCard(_cows[i]),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AddCowScreen.routeName);
          _loadAll();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Cow'),
      ),
    );
  }

  // ── component list ─────────────────────────────────────────────────────────

  late final List<_ComponentItem> _components = [
    _ComponentItem('Animal Birth Prediction', Icons.child_friendly,
        Colors.pink.shade400,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnimalBirthScreen()))),
    _ComponentItem('Egg Hatching Predictor', Icons.egg,
        Colors.amber.shade600,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HatchingScreen()))),
    _ComponentItem('Milk Market Analyzer', Icons.show_chart,
        Colors.blue.shade600,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()))),
    _ComponentItem('Milk Prediction History', Icons.history,
        Colors.cyan.shade700,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilkPredictionHistoryScreen()))),
    _ComponentItem('Cow Feed Calculator', Icons.restaurant,
        Colors.green.shade600,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen()))),
    _ComponentItem('Cow Identifier', Icons.qr_code_scanner,
        Colors.purple.shade400,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IdenticoScreen()))),
    _ComponentItem('Disease Detection', Icons.medical_services,
        Colors.red.shade500,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen()))),
    _ComponentItem('Complete Disease Analysis', Icons.biotech,
        Colors.deepOrange.shade500,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompleteDiseaseAnalysisScreen()))),
    _ComponentItem('Model Comparison', Icons.compare_arrows,
        Colors.indigo.shade400,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModelComparisonScreen()))),
    _ComponentItem('Behavior Detection', Icons.directions_walk,
        Colors.teal.shade500,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BehaviorDetectionScreen()))),
    _ComponentItem('Video Analysis', Icons.video_library,
        Colors.blueGrey.shade500,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoAnalysisScreen()))),
    _ComponentItem('Nutrition Advisor', Icons.local_dining,
        Colors.orange.shade600,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionScreen()))),
    _ComponentItem('Cow Profile', Icons.account_circle,
        Colors.teal.shade600,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CowProfileScreen()))),
  ];
}

class _ComponentItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ComponentItem(this.title, this.icon, this.color, this.onTap);
}