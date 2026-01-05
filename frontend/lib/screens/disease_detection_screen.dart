import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

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

    try {
      // Call real backend API with BOTH models
      final result = await ApiService.detectDiseaseWithComparison(_selectedImage!);
      
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
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
    
    // Extract both model results
    final densenet = _analysisResult!['densenet'] as Map<String, dynamic>?;
    final yolo = _analysisResult!['yolo'] as Map<String, dynamic>?;
    
    // Get confidences
    final densenetConfidence = (densenet?['confidence'] as num?)?.toDouble() ?? 0.0;
    final yoloConfidence = (yolo?['confidence'] as num?)?.toDouble() ?? 0.0;
    
    // Determine which model has highest confidence
    final useDensenet = densenetConfidence >= yoloConfidence;
    final winningModel = useDensenet ? 'DenseNet121' : 'YOLOv8x';
    final disease = useDensenet 
        ? (densenet?['disease'] as String? ?? 'Unknown')
        : (yolo?['disease'] as String? ?? 'Unknown');
    final confidence = useDensenet ? densenetConfidence : yoloConfidence;
    
    // Extract all predictions from the winning model
    final allPredictions = useDensenet 
        ? (densenet?['all_predictions'] as Map<String, dynamic>?)
        : null; // YOLO doesn't provide all predictions, only top result
    
    Color confidenceColor = Colors.green;
    if (confidence < 0.5) {
      confidenceColor = Colors.red;
    } else if (confidence < 0.8) {
      confidenceColor = Colors.orange;
    }

    return Column(
      children: [
        // Model comparison info
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[300]!, width: 2),
          ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏆 Highest Confidence Model: $winningModel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DenseNet: ${(densenetConfidence * 100).toStringAsFixed(1)}%  |  YOLO: ${(yoloConfidence * 100).toStringAsFixed(1)}%',
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
        
        // Main result card
        Container(
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: confidenceColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: confidenceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (allPredictions != null && allPredictions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'All Predictions ($winningModel Model):',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...allPredictions.entries.map((entry) {
                  final prob = (entry.value as num).toDouble();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: cs.onErrorContainer,
                                  ),
                            ),
                            Text(
                              '${(prob * 100).toStringAsFixed(2)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onErrorContainer.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: prob,
                          backgroundColor: cs.onErrorContainer.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            prob > 0.7 ? Colors.red : prob > 0.4 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ],
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
