import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../api/identify_cow_api.dart';
import '../api/prediction_api.dart';
import '../api/cow_api.dart';

class CompleteDiseaseAnalysisScreen extends StatefulWidget {
  const CompleteDiseaseAnalysisScreen({super.key});

  @override
  State<CompleteDiseaseAnalysisScreen> createState() => _CompleteDiseaseAnalysisScreenState();
}

class _CompleteDiseaseAnalysisScreenState extends State<CompleteDiseaseAnalysisScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _cowIdentityResult;
  final ImagePicker _picker = ImagePicker();

  // Clinical data inputs
  double _weight = 450.0;
  double _age = 40.0;
  double _temperature = 38.5;
  List<String> _selectedDiseases = [];
  bool _profileDirty = false;   // true when weight/diseases changed
  bool _savingProfile = false;

  // ── Cattle state ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _cows = [];
  Map<String, dynamic>? _selectedCow;
  bool _loadingCows = true;

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

  Widget _buildCattleSelector() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.tertiary.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: cs.tertiary, size: 20),
              const SizedBox(width: 8),
              Text('Select Cattle',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.tertiary)),
              const Spacer(),
              if (_selectedCow != null)
                GestureDetector(
                  onTap: () => setState(() => _selectedCow = null),
                  child: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _loadingCows
              ? const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))
              : _cows.isEmpty
                  ? Text('No cattle found. Add a cow first.',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
                  : DropdownButtonFormField<int>(
                      value: _selectedCow?['id'] as int?,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: cs.surface,
                        hintText: 'Choose a cattle...',
                      ),
                      items: _cows.map((cow) {
                        final label = '${cow['name'] ?? 'N/A'} (${cow['cow_id'] ?? ''}) - ${cow['breed'] ?? ''}';
                        return DropdownMenuItem<int>(
                          value: cow['id'] as int,
                          child: Text(label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (id) {
                        setState(() {
                          _selectedCow = _cows.firstWhere((c) => c['id'] == id);
                          _fillFromCow(_selectedCow!);
                        });
                      },
                    ),
          if (_selectedCow != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${_selectedCow!['name'] ?? 'N/A'} - ${_selectedCow!['breed'] ?? 'N/A'} - Lactation ${_selectedCow!['lactation_month'] ?? 'N/A'} mo',
                      style: TextStyle(fontSize: 12, color: cs.onTertiaryContainer, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Populates clinical inputs from the selected cow's stored data.
  void _fillFromCow(Map<String, dynamic> cow) {
    // Weight — MySQL DECIMAL arrives as a string from PHP/PDO JSON, so parse safely
    final w = cow['weight'];
    if (w != null) {
      _weight = double.tryParse(w.toString()) ?? _weight;
    }

    // Age in months from birthdate
    final bd = cow['birthdate']?.toString();
    if (bd != null && bd.isNotEmpty) {
      try {
        final birth = DateTime.parse(bd);
        final now = DateTime.now();
        final months = (now.year - birth.year) * 12 + (now.month - birth.month);
        _age = months.clamp(0, 240).toDouble();
      } catch (_) {}
    }

    // Previous disease — API returns a JSON array; only keep known model disease names
    const knownDiseases = {
      'Contagious', 'Dermatophilosis', 'FMD',
      'Lumpy Skin', 'Mastitis', 'Pediculosis', 'Ringworm',
    };
    final pd = cow['previous_disease'];
    if (pd is List) {
      _selectedDiseases = List<String>.from(pd)
          .where((d) => knownDiseases.contains(d))
          .toList();
    } else if (pd is String && pd.isNotEmpty && knownDiseases.contains(pd)) {
      _selectedDiseases = [pd];
    } else {
      _selectedDiseases = [];
    }

    _profileDirty = false;
  }

  /// Saves weight + previousDisease back to the cow record in Laravel.
  Future<void> _saveProfile() async {
    if (_selectedCow == null) return;
    setState(() => _savingProfile = true);
    try {
      final updated = await CowApi.updateCowProfile(
        cowId: _selectedCow!['id'] as int,
        weight: _weight,
      );
      // Refresh local cow data
      final idx = _cows.indexWhere((c) => c['id'] == updated['id']);
      if (idx >= 0) _cows[idx] = updated;
      setState(() {
        _selectedCow = updated;
        _profileDirty = false;
        _savingProfile = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cattle profile updated successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _savingProfile = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// After a completed analysis, adds the detected disease to the cow's stored profile.
  Future<void> _addDetectedDiseaseToProfile(String disease) async {
    if (_selectedCow == null) return;
    if (_selectedDiseases.contains(disease)) return; // already recorded
    final updatedDiseases = [..._selectedDiseases, disease];
    try {
      final updated = await CowApi.updateCowProfile(
        cowId: _selectedCow!['id'] as int,
        previousDisease: updatedDiseases,
      );
      final idx = _cows.indexWhere((c) => c['id'] == updated['id']);
      if (!mounted) return;
      setState(() {
        _selectedDiseases = updatedDiseases;
        if (idx >= 0) _cows[idx] = updated;
        _selectedCow = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$disease added to cattle previous diseases.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Failed to add disease to profile: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
          _cowIdentityResult = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // First, run both models to get disease comparison
      final comparisonResult = await ApiService.detectDiseaseWithComparison(_selectedImage!);
      
      // Then get full analysis with severity and treatment
      final fullAnalysis = await ApiService.analyzeCattleDisease(
        imageFile: _selectedImage!,
        weight: _weight,
        age: _age,
        temperature: _temperature,
        previousDisease: _selectedDiseases.isEmpty ? null : _selectedDiseases,
      );
      
      // Also identify the cow via Laravel API (separate URL)
      Map<String, dynamic>? cowResult;
      try {
        cowResult = await IdentifyCowApi.identifyCow(_selectedImage!);
      } catch (cowError) {
        // Cow identification is optional - don't fail the whole analysis
        debugPrint('Cow identification failed: $cowError');
      }
      
      // Merge results: Use winning disease from comparison, but keep severity/treatment from full analysis
      final densenet = comparisonResult['densenet'] as Map<String, dynamic>?;
      final yolo = comparisonResult['yolo'] as Map<String, dynamic>?;
      
      final densenetConfidence = (densenet?['confidence'] as num?)?.toDouble() ?? 0.0;
      final yoloConfidence = (yolo?['confidence'] as num?)?.toDouble() ?? 0.0;
      
      // Determine winner
      final useDensenet = densenetConfidence >= yoloConfidence;
      final winningModel = useDensenet ? 'DenseNet121' : 'YOLOv8x';
      final winningDisease = useDensenet 
          ? (densenet?['disease'] as String?) 
          : (yolo?['disease'] as String?);
      final winningConfidence = useDensenet ? densenetConfidence : yoloConfidence;
      
      // Create combined result
      final combinedResult = {
        ...fullAnalysis,
        'disease': {
          'name': winningDisease,
          'confidence': winningConfidence,
        },
        'model_comparison': {
          'winning_model': winningModel,
          'densenet_confidence': densenetConfidence,
          'yolo_confidence': yoloConfidence,
        },
      };
      
      setState(() {
        _analysisResult = combinedResult;
        _cowIdentityResult = cowResult;
        _isAnalyzing = false;
      });

      // Save complete disease analysis to smartfarm database
      final diseaseInfo = combinedResult['disease'] as Map<String, dynamic>?;
      final severityInfo = combinedResult['severity'] as Map<String, dynamic>?;
      final treatmentInfo = combinedResult['treatment'] as Map<String, dynamic>?;
      PredictionApi.saveDiseaseDetection(
        cowId: _selectedCow?['id'] as int?,
        modelUsed: winningModel,
        diseaseName: (diseaseInfo?['name'] as String?) ?? '',
        confidence: (diseaseInfo?['confidence'] as num?)?.toDouble() ?? 0.0,
        allPredictions: combinedResult['model_comparison']?.cast<String, dynamic>(),
        severity: severityInfo,
        treatment: treatmentInfo,
      ).catchError((e) => debugPrint('Save complete analysis failed: $e'));

      // Auto-add detected disease to the cattle previous diseases profile
      const _knownDiseases = {
        'Contagious', 'Dermatophilosis', 'FMD',
        'Lumpy Skin', 'Mastitis', 'Pediculosis', 'Ringworm',
      };
      if (_selectedCow != null &&
          winningDisease != null &&
          _knownDiseases.contains(winningDisease)) {
        _addDetectedDiseaseToProfile(winningDisease!);
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
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
        title: const Text('Complete Disease Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.tertiaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.biotech, size: 48, color: cs.onPrimaryContainer),
                  const SizedBox(height: 12),
                  Text(
                    'AI Disease Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detection + Severity + Treatment Recommendation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cattle selector
            _buildCattleSelector(),
            const SizedBox(height: 24),

            // Image picker buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Clinical data inputs
            if (_selectedImage != null) ...[
              Text(
                'Clinical Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              Text('Weight: ${_weight.toStringAsFixed(0)} kg'),
              Slider(
                value: _weight,
                min: 200,
                max: 800,
                divisions: 60,
                label: '${_weight.toStringAsFixed(0)}kg',
                onChanged: (v) => setState(() { _weight = v; _profileDirty = true; }),
              ),
              const SizedBox(height: 8),
              
              Text('Age: ${_age.toStringAsFixed(0)} months  (auto-computed from birthdate)'),
              Slider(
                value: _age,
                min: 1,
                max: 240,
                divisions: 239,
                label: '${_age.toStringAsFixed(0)} months',
                onChanged: (v) => setState(() => _age = v),
              ),
              const SizedBox(height: 8),
              
              Text('Body Temperature: ${_temperature.toStringAsFixed(1)}°C  (real-time)'),
              Slider(
                value: _temperature,
                min: 36.0,
                max: 42.0,
                divisions: 60,
                label: '${_temperature.toStringAsFixed(1)}°C',
                onChanged: (v) => setState(() => _temperature = v),
              ),
              const SizedBox(height: 8),
              
              const Text('Previous Disease(s)  (read-only from profile)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _selectedDiseases.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text('No previous diseases recorded',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _selectedDiseases.map((disease) => Chip(
                        avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                        label: Text(disease),
                        backgroundColor: Colors.orange.shade50,
                        side: BorderSide(color: Colors.orange.shade300),
                        labelStyle: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
              const SizedBox(height: 12),

              // Save profile button — visible when cattle selected & data changed
              if (_selectedCow != null && _profileDirty)
                ElevatedButton.icon(
                  onPressed: _savingProfile ? null : _saveProfile,
                  icon: _savingProfile
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_savingProfile ? 'Saving...' : 'Save to Cattle Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),

              // Selected image
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Complete Analysis'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
              ),
            ],

            // Analysis Results
            if (_analysisResult != null) ...[
              const SizedBox(height: 24),
              // Cow Identity Card (from Laravel API)
              if (_cowIdentityResult != null) _buildCowIdentityCard(),
              _buildAnalysisResults(cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCowIdentityCard() {
    final cow = _cowIdentityResult?['cow'] as Map<String, dynamic>?;
    final similarity = _cowIdentityResult?['similarity'] as num?;

    if (cow == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[300]!, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: Colors.teal[700], size: 28),
              const SizedBox(width: 10),
              Text(
                'Cow Identified',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (similarity != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(similarity.toDouble() * 100).toStringAsFixed(1)}% match',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCowInfoRow('Cow ID', cow['cow_id']?.toString() ?? 'N/A'),
          _buildCowInfoRow('Name', cow['name']?.toString() ?? 'N/A'),
          _buildCowInfoRow('Breed', cow['breed']?.toString() ?? 'N/A'),
          _buildCowInfoRow('Lactation Month', cow['lactation_month']?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildCowInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.teal[800],
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.teal[700],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults(ColorScheme cs) {
    final disease = _analysisResult!['disease'] as Map<String, dynamic>?;
    final severity = _analysisResult!['severity'] as Map<String, dynamic>?;
    final treatment = _analysisResult!['treatment'] as Map<String, dynamic>?;
    final clinicalData = _analysisResult!['clinical_data'] as Map<String, dynamic>?;
    final modelComparison = _analysisResult!['model_comparison'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Model Comparison Card
        if (modelComparison != null) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[300]!, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 Highest Confidence Model: ${modelComparison['winning_model']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DenseNet: ${(modelComparison['densenet_confidence'] * 100).toStringAsFixed(1)}%  |  YOLO: ${(modelComparison['yolo_confidence'] * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Disease Detection Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report, color: cs.error, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            disease?['name'] ?? 'Unknown',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Confidence: ${((disease?['confidence'] ?? 0) * 100).toStringAsFixed(2)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Severity Card
        if (severity != null) ...[
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Severity Analysis',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(severity['level']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      severity['level'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getSeverityColor(severity['level']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Confidence: ${((severity['confidence'] ?? 0) * 100).toStringAsFixed(2)}%'),
                  const SizedBox(height: 12),
                  if (severity['probabilities'] != null) ...[
                    Text('Severity Probabilities:',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    ...(severity['probabilities'] as Map<String, dynamic>).entries.map((e) {
                      final prob = (e.value as num).toDouble();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key),
                                Text('${(prob * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: prob,
                              backgroundColor: cs.surfaceContainerHighest,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Treatment Card
        if (treatment != null) ...[
          Card(
            elevation: 4,
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.green.shade700, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Treatment Recommendation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade700, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            treatment['primary'] ?? 'No treatment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Confidence: ${((treatment['confidence'] ?? 0) * 100).toStringAsFixed(2)}%'),
                  if (treatment['alternatives'] != null) ...[
                    const SizedBox(height: 16),
                    Text('Alternative Treatments:',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    ...(treatment['alternatives'] as List).map((alt) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.circle, size: 8),
                        title: Text(alt['treatment'] ?? ''),
                        trailing: Text('${((alt['probability'] ?? 0) * 100).toStringAsFixed(1)}%'),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getSeverityColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
