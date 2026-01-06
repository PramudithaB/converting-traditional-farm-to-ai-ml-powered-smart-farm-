import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  bool _isCalculating = false;
  bool _useImageMode = false;
  File? _selectedImage;
  Map<String, dynamic>? _result;

  String _breed = 'Holstein';
  double _weight = 600.0;
  int _age = 36;
  double _milkYield = 25.0;
  String _activity = 'Medium';

  final List<String> _breeds = [
    'Holstein',
    'Jersey',
    'Ayrshire',
    'Guernsey',
    'Brown Swiss',
    'Other'
  ];

  final List<String> _activityLevels = ['Low', 'Medium', 'High'];

  Future<void> _pickImage(ImageSource source) async {
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

  void _showImageSourceDialog() {
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
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _calculateFeed() async {
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
      Map<String, dynamic> response;
      
      if (_useImageMode) {
        response = await ApiService.predictCowFeedFromImage(
          _selectedImage!,
          breed: _breed,
          age: _age,
          milkYield: _milkYield,
          activity: _activity,
        );
      } else {
        response = await ApiService.predictCowFeedManual(
          breed: _breed,
          age: _age,
          weight: _weight,
          milkYield: _milkYield,
          activity: _activity,
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
                      'Daily Feed Calculator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calculate optimal feed requirements for your cattle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer.withOpacity(0.8),
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
                        onSelectionChanged: (Set<bool> newSelection) {
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
              
              // Image Selection (only in image mode)
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: _showImageSourceDialog,
                                icon: const Icon(Icons.change_circle),
                                label: const Text('Change Image'),
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
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.add_photo_alternate, size: 32),
                    label: const Text('Select Cow Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      side: BorderSide(color: cs.outline, width: 2),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
              
              // Breed
              Text(
                'Breed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _breed,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _breeds
                    .map((breed) => DropdownMenuItem(value: breed, child: Text(breed)))
                    .toList(),
                onChanged: (value) => setState(() => _breed = value!),
              ),
              const SizedBox(height: 16),
              
              // Weight (only in manual mode)
              if (!_useImageMode) ...[
                Text(
                  'Body Weight: ${_weight.toStringAsFixed(0)} kg',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _weight,
                  min: 300,
                  max: 1000,
                  divisions: 70,
                  label: '${_weight.toStringAsFixed(0)}kg',
                  onChanged: (value) => setState(() => _weight = value),
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
                onChanged: (value) => setState(() => _age = value.toInt()),
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
                onChanged: (value) => setState(() => _milkYield = value),
              ),
              const SizedBox(height: 16),
              
              // Activity Level
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
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) => setState(() => _activity = value!),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isCalculating ? null : _calculateFeed,
                icon: _isCalculating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_isCalculating ? 'Calculating...' : 'Calculate Feed'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              if (_result != null) ...[
                const SizedBox(height: 24),
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
                            Icon(Icons.breakfast_dining, color: cs.primary, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Feed Recommendation',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (_useImageMode && _result!['cow_weight_kg'] != null)
                          _buildFeedItem(
                            'Detected Weight',
                            '${_result!['cow_weight_kg']} kg',
                            Icons.monitor_weight,
                            cs,
                          ),
                        _buildFeedItem(
                          'Daily Feed Required',
                          '${_result!['daily_feed_kg'] ?? 'N/A'} kg/day',
                          Icons.scale,
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

  Widget _buildFeedItem(String label, String value, IconData icon, ColorScheme cs) {
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.7),
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