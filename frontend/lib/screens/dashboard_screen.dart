import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_db.dart';
import 'add_cow_screen.dart';
import 'login_screen.dart';
// New pages
import 'hatching.dart';
import 'market.dart';
import 'feed.dart';
import 'identico.dart';
import 'disease_detection_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _cowCount = 0;
  double _avgLm = 0;
  int _recentBirths = 0;

  Future<void> _loadMetrics() async {
    final db = AppDb.instance;
    final cowCount = await db.getCowCount();
    final avgLm = await db.getAverageLactationMonth();
    final births = await db.getRecentBirthsCount(days: 30);
    setState(() {
      _cowCount = cowCount;
      _avgLm = avgLm;
      _recentBirths = births;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserId');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Widget _glassStat(String title, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primary.withOpacity(0.15),
                foregroundColor: cs.primary,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _componentCard(String title, IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer,
              cs.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: cs.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Reduced height header
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            actions: [
              IconButton(onPressed: _loadMetrics, icon: const Icon(Icons.refresh)),
              IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 24,
                      bottom: 16,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('Manage cows, track metrics and insights',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: cs.onPrimary.withOpacity(0.85))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stack stats vertically (one card per row)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverList.list(
              children: [
                _glassStat('Total Cows', '$_cowCount', Icons.pets),
                const SizedBox(height: 12),
                _glassStat('Avg Lactation Month', _avgLm.toStringAsFixed(1), Icons.auto_graph),
                const SizedBox(height: 12),
                _glassStat('Births (last 30 days)', '$_recentBirths', Icons.cake_outlined),
                const SizedBox(height: 20),
                Text(
                  'Components',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Components: one card per row
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                _componentCard('Birth & Hatching', Icons.catching_pokemon, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HatchingScreen()));
                }),
                const SizedBox(height: 12),
                _componentCard('Market Analyze', Icons.show_chart, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
                }),
                const SizedBox(height: 12),
                _componentCard('Feed Predictor', Icons.restaurant, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen()));
                }),
                const SizedBox(height: 12),
                _componentCard('Identify Cow', Icons.qr_code_scanner, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const IdenticoScreen()));
                }),
                const SizedBox(height: 12),
                _componentCard('Disease Detection', Icons.medical_services, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen()));
                }),
              ],
            ),
          ),
          // Recent cows
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            sliver: SliverList.list(
              children: [
                Text('Recently Added Cows',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                FutureBuilder<List<Map<String, Object?>>>(
                  future: AppDb.instance.listCows(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final items = snap.data!;
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No cows yet. Tap + to add.'),
                      );
                    }
                    return SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final row = items[i];
                          final name = row['name'] as String;
                          final breed = row['breed'] as String;
                          final lm = row['lactation_month'] as int;
                          final img = row['image_path'] as String?;

                          return Container(
                            width: 240,
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                    color: cs.primaryContainer,
                                    image: img != null
                                        ? DecorationImage(
                                      image: AssetImage(img),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: img == null
                                      ? Icon(Icons.image, color: cs.onPrimaryContainer)
                                      : null,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.grass, size: 16, color: cs.primary),
                                            const SizedBox(width: 4),
                                            Text(breed, style: Theme.of(context).textTheme.bodySmall),
                                            const SizedBox(width: 12),
                                            Icon(Icons.calendar_month, size: 16, color: cs.primary),
                                            const SizedBox(width: 4),
                                            Text('LM $lm', style: Theme.of(context).textTheme.bodySmall),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AddCowScreen.routeName);
          await _loadMetrics();
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Cow'),
      ),
    );
  }
}