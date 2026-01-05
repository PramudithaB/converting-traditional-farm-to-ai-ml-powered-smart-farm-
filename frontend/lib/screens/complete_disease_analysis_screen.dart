import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class CompleteDiseaseAnalysisScreen extends StatefulWidget {
  const CompleteDiseaseAnalysisScreen({super.key});

  @override
  State<CompleteDiseaseAnalysisScreen> createState() => _CompleteDiseaseAnalysisScreenState();
}

class _CompleteDiseaseAnalysisScreenState extends State<CompleteDiseaseAnalysisScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  final ImagePicker _picker = ImagePicker();

  // Clinical data inputs
  double _weight = 450.0;
  double _age = 40.0;
  double _temperature = 38.5;
  String _previousDisease = 'None';

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
      final result = await ApiService.analyzeCattleDisease(
        imageFile: _selectedImage!,
        weight: _weight,
        age: _age,
        temperature: _temperature,
        previousDisease: _previousDisease,
      );
      
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
                onChanged: (v) => setState(() => _weight = v),
              ),
              const SizedBox(height: 8),
              
              Text('Age: ${_age.toStringAsFixed(0)} months'),
              Slider(
                value: _age,
                min: 12,
                max: 120,
                divisions: 108,
                label: '${_age.toStringAsFixed(0)} months',
                onChanged: (v) => setState(() => _age = v),
              ),
              const SizedBox(height: 8),
              
              Text('Temperature: ${_temperature.toStringAsFixed(1)}°C'),
              Slider(
                value: _temperature,
                min: 36.0,
                max: 42.0,
                divisions: 60,
                label: '${_temperature.toStringAsFixed(1)}°C',
                onChanged: (v) => setState(() => _temperature = v),
              ),
              const SizedBox(height: 8),
              
              DropdownButtonFormField<String>(
                value: _previousDisease,
                decoration: const InputDecoration(
                  labelText: 'Previous Disease',
                  border: OutlineInputBorder(),
                ),
                items: ['None', 'Mastitis', 'FMD', 'Lumpy Skin', 'Other']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _previousDisease = v!),
              ),
              const SizedBox(height: 16),

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
              _buildAnalysisResults(cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(ColorScheme cs) {
    final disease = _analysisResult!['disease'] as Map<String, dynamic>?;
    final severity = _analysisResult!['severity'] as Map<String, dynamic>?;
    final treatment = _analysisResult!['treatment'] as Map<String, dynamic>?;
    final clinicalData = _analysisResult!['clinical_data'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
