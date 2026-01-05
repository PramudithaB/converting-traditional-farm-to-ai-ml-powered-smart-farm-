import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class BehaviorDetectionScreen extends StatefulWidget {
  const BehaviorDetectionScreen({super.key});

  @override
  State<BehaviorDetectionScreen> createState() => _BehaviorDetectionScreenState();
}

class _BehaviorDetectionScreenState extends State<BehaviorDetectionScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();

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
          _result = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _detectBehavior() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ApiService.detectBehaviorFromVideo(_selectedImage!);
      
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detection failed: $e'),
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
        title: const Text('Behavior Detection'),
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
                  colors: [Colors.purple.shade100, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.pets, size: 48, color: Colors.purple.shade700),
                  const SizedBox(height: 12),
                  Text(
                    'Cattle Behavior Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detect eating, standing, lying behaviors',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.purple.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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

            // Selected image and analyze button
            if (_selectedImage != null) ...[
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
                onPressed: _isAnalyzing ? null : _detectBehavior,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isAnalyzing ? 'Detecting...' : 'Detect Behavior'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            // Results
            if (_result != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: cs.primary, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Detected Behaviors',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Count: ${_result!['count'] ?? 0}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const Divider(height: 24),
                      if (_result!['behaviors'] != null) ...[
                        ...(_result!['behaviors'] as List).map((behavior) {
                          return Card(
                            color: _getBehaviorColor(behavior['behavior']).withOpacity(0.1),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getBehaviorColor(behavior['behavior']),
                                child: Icon(
                                  _getBehaviorIcon(behavior['behavior']),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                (behavior['behavior'] as String).toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: LinearProgressIndicator(
                                value: (behavior['confidence'] as num).toDouble(),
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(
                                  _getBehaviorColor(behavior['behavior']),
                                ),
                              ),
                              trailing: Text(
                                '${((behavior['confidence'] as num) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Behavior guide
            const SizedBox(height: 24),
            _buildBehaviorGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavior Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildBehaviorItem('Eating', Icons.restaurant, Colors.green,
                'Cow is feeding or grazing'),
            _buildBehaviorItem('Standing', Icons.accessibility_new, Colors.blue,
                'Cow is standing upright'),
            _buildBehaviorItem('Lying', Icons.bed, Colors.orange,
                'Cow is resting or lying down'),
            _buildBehaviorItem('Walking', Icons.directions_walk, Colors.purple,
                'Cow is in motion'),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorItem(String name, IconData icon, Color color, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBehaviorColor(String? behavior) {
    switch (behavior?.toLowerCase()) {
      case 'eating':
        return Colors.green;
      case 'standing':
        return Colors.blue;
      case 'lying':
        return Colors.orange;
      case 'walking':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getBehaviorIcon(String? behavior) {
    switch (behavior?.toLowerCase()) {
      case 'eating':
        return Icons.restaurant;
      case 'standing':
        return Icons.accessibility_new;
      case 'lying':
        return Icons.bed;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.pets;
    }
  }
}
