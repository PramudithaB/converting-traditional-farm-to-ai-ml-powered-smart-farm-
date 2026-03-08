import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/cow_api.dart';
import '../api/identify_cow_api.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  bool _loadingCows = true;
  String? _cowLoadError;
  List<Map<String, dynamic>> _cows = [];
  Map<String, dynamic>? _selectedCow;

  bool _isCalculating = false;
  bool _useImageMode = false;
  File? _selectedImage; // feed prediction image
  Map<String, dynamic>? _result;

  // Inputs to prediction
  String _breed = 'Holstein';
  double _weight = 600.0;
  int _age = 36; // months
  double _milkYield = 25.0; // L/day
  String _activity = 'Medium';

  final List<String> _activityLevels = ['Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _loadCows();
  }

  Future<void> _loadCows() async {
    setState(() {
      _loadingCows = true;
      _cowLoadError = null;
    });

    try {
      final cows = await CowApi.getCows();
      setState(() {
        _cows = cows;
        if (cows.isNotEmpty) {
          _selectedCow = cows.first;
          _applyCowDefaults();
        }
      });
    } catch (e) {
      setState(() {
        _cowLoadError = e.toString();
      });
    } finally {
      setState(() {
        _loadingCows = false;
      });
    }
  }

  void _applyCowDefaults() {
    if (_selectedCow == null) return;

    // Set breed from cow record
    _breed = (_selectedCow!['breed'] as String?) ?? _breed;

    // Auto-fill weight from cow record
    final w = _selectedCow!['weight'];
    if (w != null) {
      final wVal = w is num ? w.toDouble() : double.tryParse(w.toString());
      if (wVal != null) _weight = wVal.clamp(300.0, 1000.0);
    }

    // Derive age in months from birthdate if present
    final birthdateStr = _selectedCow!['birthdate'];
    if (birthdateStr is String && birthdateStr.isNotEmpty) {
      try {
        final birth = DateTime.parse(birthdateStr);
        final now = DateTime.now();
        final months = (now.year - birth.year) * 12 + now.month - birth.month;
        _age = months.clamp(12, 120); // keep within slider range
      } catch (_) {
        _age = 36;
      }
    } else {
      _age = 36;
    }

    setState(() {});
  }

  Future<void> _pickFeedImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialogForFeed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickFeedImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFeedImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Identify cow from an image and set _selectedCow from backend result
  Future<void> _identifyFromImageWithSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      // Call Laravel /api/cows/identify via IdentifyCowApi
      final identifyResult = await IdentifyCowApi.identifyCow(imageFile);
      final cow = identifyResult['cow'] as Map<String, dynamic>?;

      if (cow == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cow identified')),
        );
        return;
      }

      // Ensure this cow is in the list
      final idx = _cows.indexWhere((c) => c['id'] == cow['id']);
      if (idx == -1) {
        _cows.add(cow);
      } else {
        _cows[idx] = cow;
      }

      setState(() {
        _selectedCow = cow;
        _applyCowDefaults();
        _result = null;
        _selectedImage = null; // reset feed image; user will pick again if needed
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Identified cow: ${cow['cow_id']} - ${cow['name']}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Identify error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showIdentifyImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Identify Cow - Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _identifyFromImageWithSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _identifyFromImageWithSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _calculateFeed() async {
    if (_selectedCow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or identify a cow first')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_useImageMode && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cow image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _result = null;
    });

    try {
      final cowId = _selectedCow!['id'] as int;
      final double ageMonths = _age.toDouble();

      Map<String, dynamic> response;

      if (_useImageMode) {
        response = await CowApi.createFeedFromImage(
          cowId: cowId,
          imageFile: _selectedImage!,
          milkYield: _milkYield,
          activity: _activity,
          ageMonths: ageMonths,
        );
      } else {
        response = await CowApi.createFeedManual(
          cowId: cowId,
          weight: _weight,
          milkYield: _milkYield,
          activity: _activity,
          ageMonths: ageMonths,
        );
      }

      setState(() {
        _result = response;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _isCalculating = false;
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

    if (_loadingCows) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cow Feed Calculator')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cowLoadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cow Feed Calculator')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load cows:\n$_cowLoadError'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadCows,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cows.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cow Feed Calculator')),
        body:
        const Center(child: Text('No cows found. Please add a cow first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cow Feed Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cow selector + identify button (vertical to avoid overflow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Cow',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedCow,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _cows
                        .map(
                          (cow) =>
                          DropdownMenuItem<Map<String, dynamic>>(
                            value: cow,
                            child: Text(
                              '${cow['cow_id']} - ${cow['name']} (${cow['breed']})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    )
                        .toList(),
                    onChanged: (cow) {
                      setState(() {
                        _selectedCow = cow;
                        _applyCowDefaults();
                        _result = null;
                        _selectedImage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showIdentifyImageSourceDialog,
                    icon: const Icon(Icons.camera_enhance),
                    label: const Text('Identify Cow from Image'),
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Header
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
                    Icon(Icons.restaurant,
                        size: 48, color: cs.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      'Daily Feed Calculator',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calculate and save optimal feed for the selected cow',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                        cs.onPrimaryContainer.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mode Toggle
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Prediction Mode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Manual'),
                            icon: Icon(Icons.edit),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Image'),
                            icon: Icon(Icons.camera_alt),
                          ),
                        ],
                        selected: {_useImageMode},
                        onSelectionChanged:
                            (Set<bool> newSelection) {
                          setState(() {
                            _useImageMode = newSelection.first;
                            _result = null;
                            _selectedImage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Image Selection (feed prediction) only in image mode
              if (_useImageMode) ...[
                if (_selectedImage != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed:
                                _showImageSourceDialogForFeed,
                                icon: const Icon(Icons.change_circle),
                                label:
                                const Text('Change Image'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _result = null;
                                  });
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Remove'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _showImageSourceDialogForFeed,
                    icon: const Icon(Icons.add_photo_alternate,
                        size: 32),
                    label: const Text('Select Cow Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 40),
                      side: BorderSide(
                        color: cs.outline,
                        width: 2,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Breed display
              Text(
                'Breed: $_breed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Weight (manual mode only)
              if (!_useImageMode) ...[
                Text(
                  'Body Weight: ${_weight.toStringAsFixed(0)} kg',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _weight,
                  min: 5,
                  max: 1000,
                  divisions: 70,
                  label: '${_weight.toStringAsFixed(0)}kg',
                  onChanged: (value) =>
                      setState(() => _weight = value),
                ),
                const SizedBox(height: 16),
              ],

              // Age
              Text(
                'Age: $_age months',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _age.toDouble(),
                min: 12,
                max: 120,
                divisions: 108,
                label: '$_age months',
                onChanged: (value) =>
                    setState(() => _age = value.toInt()),
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
                onChanged: (value) =>
                    setState(() => _milkYield = value),
              ),
              const SizedBox(height: 16),

              // Activity
              Text(
                'Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _activity,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _activityLevels
                    .map(
                      (level) => DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  ),
                )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _activity = value!),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed:
                _isCalculating ? null : _calculateFeed,
                icon: _isCalculating
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.calculate),
                label: Text(
                  _isCalculating
                      ? 'Calculating...'
                      : 'Calculate & Save Feed',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResultCard(context, cs),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, ColorScheme cs) {
    // Backend response:
    // { "message": "...", "cow_feed": { "daily_feed_kg": ..., "cow_weight_kg": ... } }
    final cowFeed =
        _result!['cow_feed'] ?? _result!;
    final dailyFeedKg =
        cowFeed['daily_feed_kg'] ?? _result!['daily_feed_kg'];
    final cowWeightKg =
        cowFeed['cow_weight_kg'] ?? _result!['cow_weight_kg'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.breakfast_dining,
                    color: cs.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Feed Recommendation Saved',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_useImageMode && cowWeightKg != null)
              _buildFeedItem(
                'Detected Weight',
                '$cowWeightKg kg',
                Icons.monitor_weight,
                cs,
              ),
            _buildFeedItem(
              'Daily Feed Required',
              '${dailyFeedKg ?? 'N/A'} kg/day',
              Icons.scale,
              cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(
      String label,
      String value,
      IconData icon,
      ColorScheme cs,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: cs.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
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