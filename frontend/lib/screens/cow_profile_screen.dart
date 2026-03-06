import 'package:flutter/material.dart';
import '../api/cow_api.dart';
import '../config/app_config.dart';

class CowProfileScreen extends StatefulWidget {
  static const routeName = '/cow-profile';

  /// If provided the cow is auto-selected; otherwise a dropdown appears.
  final int? initialCowId;

  const CowProfileScreen({super.key, this.initialCowId});

  @override
  State<CowProfileScreen> createState() => _CowProfileScreenState();
}

class _CowProfileScreenState extends State<CowProfileScreen> {
  List<Map<String, dynamic>> _cows = [];
  Map<String, dynamic>? _selectedCow;
  Map<String, dynamic>? _profile;

  bool _loadingCows = true;
  bool _loadingProfile = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCows();
  }

  Future<void> _loadCows() async {
    setState(() { _loadingCows = true; _error = null; });
    try {
      final cows = await CowApi.getCows();
      if (!mounted) return;
      setState(() { _cows = cows; _loadingCows = false; });

      if (widget.initialCowId != null && cows.isNotEmpty) {
        final match = cows.where((c) => c['id'] == widget.initialCowId).toList();
        if (match.isNotEmpty) _selectCow(match.first);
      }
    } catch (e) {
      if (mounted) setState(() { _loadingCows = false; _error = e.toString(); });
    }
  }

  Future<void> _selectCow(Map<String, dynamic> cow) async {
    setState(() { _selectedCow = cow; _loadingProfile = true; _profile = null; _error = null; });
    try {
      final profile = await CowApi.getCowProfile(cow['id'] as int);
      if (mounted) setState(() { _profile = profile; _loadingProfile = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingProfile = false; _error = e.toString(); });
    }
  }

  // ─── helpers ───────────────────────────────────────────────────────────────

  String _ageLabel(dynamic ageMonths) {
    if (ageMonths == null) return 'N/A';
    final m = ageMonths as int;
    if (m < 12) return '$m mo';
    final y = m ~/ 12;
    final rem = m % 12;
    return rem == 0 ? '${y}y' : '${y}y ${rem}mo';
  }

  Color _healthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':   return Colors.green;
      case 'unhealthy': return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData _healthIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':   return Icons.check_circle;
      case 'unhealthy': return Icons.warning_rounded;
      default:          return Icons.help_outline;
    }
  }

  // ─── sections ──────────────────────────────────────────────────────────────

  Widget _sectionTitle(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {IconData? icon}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
          ],
          SizedBox(
            width: 130,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.inbox, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── cow header card ───────────────────────────────────────────────────────

  Widget _buildHeader(Map<String, dynamic> cow, String healthStatus, dynamic ageMonths) {
    final cs = Theme.of(context).colorScheme;
    final img = cow['image_path'] as String?;
    final healthColor = _healthColor(healthStatus);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image
          img != null
              ? Image.network(
                  '${AppConfig.laravelBase}/$img',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _cowImagePlaceholder(cs),
                )
              : _cowImagePlaceholder(cs),
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Name + health badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cow['name']?.toString() ?? 'N/A',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800)),
                          Text(cow['cow_id']?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: healthColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: healthColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_healthIcon(healthStatus), color: healthColor, size: 16),
                          const SizedBox(width: 5),
                          Text(healthStatus,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: healthColor,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                // Stat pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statPill(
                        '${cow['weight'] != null ? double.tryParse(cow['weight'].toString())?.toStringAsFixed(0) ?? "—" : "—"} kg',
                        'Weight', Icons.monitor_weight_outlined, cs.primary),
                    _statPill(
                        _ageLabel(ageMonths), 'Age',
                        Icons.cake_outlined, cs.secondary),
                    _statPill(
                        'LM ${cow['lactation_month'] ?? "—"}', 'Lactation',
                        Icons.water_drop_outlined, Colors.teal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cowImagePlaceholder(ColorScheme cs) => Container(
        height: 180,
        color: cs.primaryContainer,
        child: Icon(Icons.pets, size: 64, color: cs.onPrimaryContainer.withOpacity(0.3)),
      );

  Widget _statPill(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  // ─── basic info card ───────────────────────────────────────────────────────

  Widget _buildBasicInfo(Map<String, dynamic> cow) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Cow ID',    cow['cow_id']?.toString() ?? 'N/A',   icon: Icons.tag),
            _infoRow('Name',      cow['name']?.toString() ?? 'N/A',      icon: Icons.badge_outlined),
            _infoRow('Breed',     cow['breed']?.toString() ?? 'N/A',     icon: Icons.grass),
            _infoRow('Birthdate', cow['birthdate']?.toString() ?? 'N/A', icon: Icons.cake_outlined),
            _infoRow('Weight',
                '${cow['weight'] != null ? '${double.tryParse(cow['weight'].toString())?.toStringAsFixed(1) ?? "—"} kg' : 'N/A'}',
                icon: Icons.monitor_weight_outlined),
            _infoRow('Lactation', '${cow['lactation_month'] ?? 'N/A'} months', icon: Icons.water_drop_outlined),
          ],
        ),
      ),
    );
  }

  // ─── previous diseases ─────────────────────────────────────────────────────

  Widget _buildPreviousDiseases(Map<String, dynamic> cow) {
    final pd = cow['previous_disease'];
    final List<String> diseases = pd is List ? List<String>.from(pd) : [];

    return diseases.isEmpty
        ? _emptyState('No previous diseases recorded')
        : Wrap(
            spacing: 8,
            runSpacing: 6,
            children: diseases.map((d) => Chip(
              avatar: const Icon(Icons.warning_amber_rounded, size: 14),
              label: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              backgroundColor: Colors.orange.shade50,
              side: BorderSide(color: Colors.orange.shade300),
              visualDensity: VisualDensity.compact,
            )).toList(),
          );
  }

  // ─── disease detections ────────────────────────────────────────────────────

  Widget _buildDiseaseDetections(List detections) {
    if (detections.isEmpty) return _emptyState('No disease detections yet');
    return Column(
      children: detections.map<Widget>((d) {
        final name = d['disease_name']?.toString() ?? 'Unknown';
        final conf = ((d['confidence'] as num?)?.toDouble() ?? 0) * 100;
        final model = d['model_used']?.toString() ?? '';
        final isHealthy = name.toLowerCase() == 'healthy';
        final color = isHealthy ? Colors.green : Colors.red;
        final date = _formatDate(d['created_at']?.toString());
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(isHealthy ? Icons.check_circle : Icons.medical_services,
                  color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(fontWeight: FontWeight.w700,
                            color: color, fontSize: 14)),
                    Text('$model · ${conf.toStringAsFixed(1)}%  ·  $date',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              if ((d['severity'] as Map?)?.isNotEmpty == true)
                _severityChip(d['severity']['level']?.toString()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _severityChip(String? level) {
    Color c;
    switch (level?.toLowerCase()) {
      case 'mild':     c = Colors.green; break;
      case 'moderate': c = Colors.orange; break;
      case 'severe':   c = Colors.red; break;
      default:         return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(level!, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // ─── behavior detections ───────────────────────────────────────────────────

  Widget _buildBehaviorDetections(List detections) {
    if (detections.isEmpty) return _emptyState('No behavior detections yet');
    return Column(
      children: detections.map<Widget>((d) {
        final behavior = d['behavior']?.toString() ?? 'Unknown';
        final conf = ((d['confidence'] as num?)?.toDouble() ?? 0) * 100;
        final type = d['detection_type']?.toString() ?? '';
        final date = _formatDate(d['created_at']?.toString());
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_walk, color: Colors.teal, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(behavior,
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            color: Colors.teal, fontSize: 14)),
                    Text('$type · ${conf.toStringAsFixed(1)}%  ·  $date',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── feed records ──────────────────────────────────────────────────────────

  Widget _buildFeedRecords(List feeds) {
    if (feeds.isEmpty) return _emptyState('No feed records yet');
    return Column(
      children: feeds.map<Widget>((f) {
        final date = _formatDate(f['created_at']?.toString());
        final weight = f['weight']?.toString() ?? '—';
        final milk = f['milk_yield']?.toString() ?? '—';
        final activity = f['activity']?.toString() ?? '—';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: Colors.green.shade100, shape: BoxShape.circle),
                child: Icon(Icons.restaurant, color: Colors.green.shade700, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight: ${weight}kg  ·  Milk: ${milk}L  ·  $activity',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── birth predictions ─────────────────────────────────────────────────────

  Widget _buildBirthPredictions(List births) {
    if (births.isEmpty) return _emptyState('No birth predictions yet');
    return Column(
      children: births.map<Widget>((b) {
        final days = b['estimated_days_to_birth']?.toString() ?? '—';
        final will = b['will_birth_in_2_days']?.toString() ?? 'No';
        final date = _formatDate(b['created_at']?.toString());
        final soon = will.toLowerCase() == 'yes';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: soon ? Colors.pink.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: soon ? Colors.pink.shade200 : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.child_friendly,
                  color: soon ? Colors.pink.shade600 : Colors.grey, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Est. $days days to birth',
                        style: TextStyle(fontWeight: FontWeight.w700,
                            color: soon ? Colors.pink.shade700 : Colors.black87,
                            fontSize: 13)),
                    Text('Birth in 2 days: $will  ·  $date',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              if (soon)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('SOON',
                      style: TextStyle(
                          color: Colors.pink.shade800,
                          fontSize: 10, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── nutrition records ─────────────────────────────────────────────────────

  Widget _buildNutrition(List nutrition) {
    if (nutrition.isEmpty) return _emptyState('No nutrition recommendations yet');
    return Column(
      children: nutrition.map<Widget>((n) {
        final dm   = n['dry_matter_intake_kg']?.toString() ?? '—';
        final ca   = n['calcium_g_per_day']?.toString() ?? '—';
        final phos = n['phosphorus_g_per_day']?.toString() ?? '—';
        final date = _formatDate(n['created_at']?.toString());
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: Colors.orange.shade100, shape: BoxShape.circle),
                child: Icon(Icons.local_dining, color: Colors.orange.shade700, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DM: ${dm}kg  ·  Ca: ${ca}g  ·  P: ${phos}g',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── date formatter ────────────────────────────────────────────────────────

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // ─── cow selector ──────────────────────────────────────────────────────────

  Widget _buildCowSelector() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text('Select Cattle',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 10),
          _loadingCows
              ? const Center(child: SizedBox(height: 24, width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)))
              : _cows.isEmpty
                  ? Text('No cattle found. Add a cow first.',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
                  : DropdownButtonFormField<int>(
                      value: _selectedCow?['id'] as int?,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: cs.surface,
                        hintText: 'Choose a cattle...',
                      ),
                      items: _cows.map((cow) {
                        final label =
                            '${cow['name'] ?? 'N/A'} (${cow['cow_id'] ?? ''}) - ${cow['breed'] ?? ''}';
                        return DropdownMenuItem<int>(
                          value: cow['id'] as int,
                          child: Text(label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (id) {
                        final cow = _cows.firstWhere((c) => c['id'] == id);
                        _selectCow(cow);
                      },
                    ),
        ],
      ),
    );
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final cowData    = _profile?['cow']    as Map<String, dynamic>?;
    final health     = (_profile?['health_status'] as String?) ?? 'Unknown';
    final ageMonths  = _profile?['age_months'];
    final diseases   = (_profile?['disease_detections']  as List?) ?? [];
    final behaviors  = (_profile?['behavior_detections'] as List?) ?? [];
    final births     = (_profile?['birth_predictions']   as List?) ?? [];
    final feeds      = (_profile?['feeds']               as List?) ?? [];
    final nutrition  = (_profile?['nutrition']           as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCow != null
            ? '${_selectedCow!['name'] ?? 'Cow'} Profile'
            : 'Cow Profile'),
        actions: [
          if (_selectedCow != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => _selectCow(_selectedCow!),
            ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadCows, child: const Text('Retry')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _selectedCow != null
                  ? () => _selectCow(_selectedCow!)
                  : _loadCows,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Cow selector ─────────────────────────────────────
                    _buildCowSelector(),
                    const SizedBox(height: 16),

                    // ── Loading spinner ───────────────────────────────────
                    if (_loadingProfile)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      )),

                    // ── Profile content ───────────────────────────────────
                    if (_profile != null && cowData != null) ...[
                      // Header
                      _buildHeader(cowData, health, ageMonths),

                      // ── Basic info ─────────────────────────────────────
                      _sectionTitle('Basic Information', Icons.info_outline, cs.primary),
                      _buildBasicInfo(cowData),

                      // ── Previous Diseases ──────────────────────────────
                      _sectionTitle('Previous Diseases', Icons.history,
                          Colors.orange.shade700),
                      _buildPreviousDiseases(cowData),

                      // ── Recent Disease Detections ──────────────────────
                      _sectionTitle('Disease Detection History',
                          Icons.medical_services, Colors.red.shade600),
                      _buildDiseaseDetections(diseases),

                      // ── Behavior Detections ────────────────────────────
                      _sectionTitle('Behavior Detection History',
                          Icons.directions_walk, Colors.teal),
                      _buildBehaviorDetections(behaviors),

                      // ── Feed Records ───────────────────────────────────
                      _sectionTitle('Feed Records',
                          Icons.restaurant, Colors.green.shade600),
                      _buildFeedRecords(feeds),

                      // ── Birth Predictions ──────────────────────────────
                      _sectionTitle('Birth Predictions',
                          Icons.child_friendly, Colors.pink.shade400),
                      _buildBirthPredictions(births),

                      // ── Nutrition ──────────────────────────────────────
                      _sectionTitle('Nutrition Recommendations',
                          Icons.local_dining, Colors.orange.shade600),
                      _buildNutrition(nutrition),
                    ],

                    // ── Empty state ─────────────────────────────────────
                    if (!_loadingProfile && _profile == null && _selectedCow == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.pets, size: 72,
                                color: cs.onSurface.withOpacity(0.15)),
                            const SizedBox(height: 16),
                            Text('Select a cattle to view its profile',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
