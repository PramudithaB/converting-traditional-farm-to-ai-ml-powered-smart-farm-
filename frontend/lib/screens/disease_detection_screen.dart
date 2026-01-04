import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
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
          _analysisResult = null;
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

    // Simulate AI analysis (replace with actual ML model integration)
    await Future.delayed(const Duration(seconds: 2));

    // Mock result - replace with actual disease detection logic
    setState(() {
      _analysisResult = {
        'disease': 'Foot and Mouth Disease',
        'confidence': 0.87,
        'severity': 'Moderate',
        'symptoms': [
          'Blisters on mouth and feet',
          'Fever and loss of appetite',
          'Excessive salivation',
          'Lameness'
        ],
        'recommendations': [
          'Isolate affected cattle immediately',
          'Contact veterinarian for confirmation',
          'Ensure proper hygiene and disinfection',
          'Monitor other cattle for symptoms',
          'Consider vaccination for herd'
        ],
      };
      _isAnalyzing = false;
    });
  }

  Widget _buildImagePickerButton(String label, IconData icon, ImageSource source) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(source),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildSymptomChecker() {
    final cs = Theme.of(context).colorScheme;
    final symptoms = [
      'Fever',
      'Loss of Appetite',
      'Coughing',
      'Nasal Discharge',
      'Diarrhea',
      'Weight Loss',
      'Lameness',
      'Swelling',
      'Skin Lesions',
      'Milk Production Drop',
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Common Symptoms',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms.map((symptom) {
              return Chip(
                label: Text(symptom),
                backgroundColor: cs.surfaceContainerHighest,
                labelStyle: Theme.of(context).textTheme.labelMedium,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonDiseases() {
    final cs = Theme.of(context).colorScheme;
    final diseases = [
      {
        'name': 'Mastitis',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'description': 'Inflammation of the mammary gland'
      },
      {
        'name': 'Foot and Mouth Disease',
        'icon': Icons.healing,
        'color': Colors.red,
        'description': 'Viral disease affecting hooves and mouth'
      },
      {
        'name': 'Bovine Tuberculosis',
        'icon': Icons.coronavirus,
        'color': Colors.purple,
        'description': 'Infectious disease of the respiratory system'
      },
      {
        'name': 'Brucellosis',
        'icon': Icons.medical_services,
        'color': Colors.blue,
        'description': 'Bacterial disease causing reproductive issues'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Cattle Diseases',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...diseases.map((disease) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (disease['color'] as Color).withOpacity(0.15),
                child: Icon(
                  disease['icon'] as IconData,
                  color: disease['color'] as Color,
                ),
              ),
              title: Text(
                disease['name'] as String,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: Text(disease['description'] as String),
              trailing: Icon(Icons.info_outline, color: cs.primary),
              onTap: () {
                // Show disease info dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(disease['name'] as String),
                    content: Text(disease['description'] as String),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final disease = _analysisResult!['disease'] as String;
    final confidence = _analysisResult!['confidence'] as double;
    final severity = _analysisResult!['severity'] as String;
    final symptoms = _analysisResult!['symptoms'] as List<String>;
    final recommendations = _analysisResult!['recommendations'] as List<String>;

    Color severityColor = Colors.orange;
    if (severity == 'High' || severity == 'Severe') {
      severityColor = Colors.red;
    } else if (severity == 'Low') {
      severityColor = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withOpacity(0.3), width: 2),
      ),
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
                      disease,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            severity,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: severityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: cs.onErrorContainer.withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Observed Symptoms:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...symptoms.map((symptom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: cs.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      symptom,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Text(
            'Recommendations:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
        backgroundColor: cs.surface,
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
                  colors: [cs.primaryContainer, cs.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.medical_services_rounded, size: 48, color: cs.onPrimaryContainer),
                  const SizedBox(height: 12),
                  Text(
                    'AI-Powered Disease Detection',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload an image of your cattle to detect potential diseases',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image selection buttons
            Row(
              children: [
                _buildImagePickerButton('Camera', Icons.camera_alt, ImageSource.camera),
                const SizedBox(width: 12),
                _buildImagePickerButton('Gallery', Icons.photo_library, ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 24),

            // Selected image preview
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
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Analysis result
            if (_analysisResult != null) ...[
              _buildAnalysisResult(),
              const SizedBox(height: 24),
            ],

            // Symptom checker
            _buildSymptomChecker(),
            const SizedBox(height: 24),

            // Common diseases
            _buildCommonDiseases(),
          ],
        ),
      ),
    );
  }
}
