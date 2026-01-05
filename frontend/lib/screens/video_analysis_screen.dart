import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class VideoAnalysisScreen extends StatefulWidget {
  const VideoAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<VideoAnalysisScreen> createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends State<VideoAnalysisScreen> {
  File? _videoFile;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  final ImagePicker _picker = ImagePicker();

  // Analysis options
  int _frameInterval = 30;
  bool _detectDisease = true;
  bool _detectBehavior = true;

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showError('Error picking video: $e');
    }
  }

  Future<void> _analyzeVideo() async {
    if (_videoFile == null) {
      _showError('Please select a video first');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ApiService.analyzeVideo(
        videoFile: _videoFile!,
        frameInterval: _frameInterval,
        detectDisease: _detectDisease,
        detectBehavior: _detectBehavior,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('Analysis failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Analysis'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildVideoPickerButtons(),
            const SizedBox(height: 24),
            if (_videoFile != null) ...[
              _buildOptionsCard(),
              const SizedBox(height: 16),
              _buildVideoInfo(),
              const SizedBox(height: 16),
              _buildAnalyzeButton(),
              const SizedBox(height: 24),
            ],
            if (_analysisResult != null) ...[
              _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.video_library, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Video Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze cattle videos for behavior and disease detection',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPickerButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : () => _pickVideo(ImageSource.camera),
            icon: const Icon(Icons.videocam),
            label: const Text('Record'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : () => _pickVideo(ImageSource.gallery),
            icon: const Icon(Icons.video_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Frame Interval: ${_frameInterval} frames (${_getIntervalSpeed()})'),
            Slider(
              value: _frameInterval.toDouble(),
              min: 10,
              max: 60,
              divisions: 5,
              label: '$_frameInterval',
              onChanged: (value) => setState(() => _frameInterval = value.toInt()),
            ),
            Text(
              _getIntervalDescription(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Detect Diseases'),
              subtitle: const Text('Enable disease detection from video frames'),
              value: _detectDisease,
              onChanged: (value) => setState(() => _detectDisease = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Detect Behaviors'),
              subtitle: const Text('Enable behavior detection (eating, standing, etc.)'),
              value: _detectBehavior,
              onChanged: (value) => setState(() => _detectBehavior = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  String _getIntervalSpeed() {
    if (_frameInterval >= 60) return '⚡ Fast';
    if (_frameInterval >= 30) return '⚡⚡ Balanced';
    if (_frameInterval >= 15) return '⚡⚡⚡ Slow';
    return '⚡⚡⚡⚡ Very Slow';
  }

  String _getIntervalDescription() {
    if (_frameInterval >= 60) return 'Quick overview, ~0.5 fps';
    if (_frameInterval >= 30) return 'Recommended, ~1 fps';
    if (_frameInterval >= 15) return 'High accuracy, ~2 fps';
    return 'Maximum accuracy, ~3 fps';
  }

  Widget _buildVideoInfo() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.video_file, color: Colors.blue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Selected',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _videoFile!.path.split('/').last,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton.icon(
      onPressed: _isAnalyzing ? null : _analyzeVideo,
      icon: _isAnalyzing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.analytics),
      label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Video'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResults() {
    final videoInfo = _analysisResult!['video_info'] as Map<String, dynamic>?;
    final summary = _analysisResult!['summary'] as Map<String, dynamic>?;
    final behaviorTimeline = _analysisResult!['behavior_timeline'] as List?;
    final diseaseDetections = _analysisResult!['disease_detections'] as List?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Video Info Card
        if (videoInfo != null) _buildVideoInfoCard(videoInfo),
        const SizedBox(height: 16),

        // Summary Cards
        if (summary != null) ...[
          _buildSummaryCards(summary),
          const SizedBox(height: 16),
        ],

        // Disease Detections
        if (diseaseDetections != null && diseaseDetections.isNotEmpty) ...[
          _buildDiseaseDetections(diseaseDetections),
          const SizedBox(height: 16),
        ],

        // Behavior Timeline
        if (behaviorTimeline != null && behaviorTimeline.isNotEmpty) ...[
          _buildBehaviorTimeline(behaviorTimeline),
        ],
      ],
    );
  }

  Widget _buildVideoInfoCard(Map<String, dynamic> videoInfo) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Video Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Duration', '${videoInfo['duration']?.toStringAsFixed(1)} seconds'),
            _buildInfoRow('FPS', '${videoInfo['fps']?.toStringAsFixed(1)}'),
            _buildInfoRow('Total Frames', '${videoInfo['total_frames']}'),
            _buildInfoRow('Analyzed Frames', '${videoInfo['analyzed_frames']}'),
            _buildInfoRow('Frame Interval', '${videoInfo['frame_interval']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    final behaviors = summary['behaviors'] as Map<String, dynamic>?;
    final diseases = summary['diseases'] as Map<String, dynamic>?;

    return Column(
      children: [
        if (behaviors != null && behaviors.isNotEmpty) ...[
          Card(
            color: Colors.green[50],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Detected Behaviors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...behaviors.entries.map((entry) {
                    final stats = entry.value as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${stats['count']} times (${(stats['avg_confidence'] * 100).toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (diseases != null && diseases.isNotEmpty) ...[
          Card(
            color: Colors.red[50],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Detected Diseases',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...diseases.entries.map((entry) {
                    final stats = entry.value as Map<String, dynamic>;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${stats['count']} detections',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Confidence: ${(stats['avg_confidence'] * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'First: ${stats['first_seen']?.toStringAsFixed(1)}s',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiseaseDetections(List diseaseDetections) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Disease Detection Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: diseaseDetections.length > 10 ? 10 : diseaseDetections.length,
                itemBuilder: (context, index) {
                  final detection = diseaseDetections[index] as Map<String, dynamic>;
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.red[100],
                      radius: 16,
                      child: Text(
                        '${detection['frame']}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    title: Text(detection['disease'] ?? 'Unknown'),
                    subtitle: Text('${detection['timestamp']?.toStringAsFixed(1)}s'),
                    trailing: Text(
                      '${(detection['confidence'] * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            if (diseaseDetections.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${diseaseDetections.length - 10} more detections',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorTimeline(List behaviorTimeline) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Behavior Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: behaviorTimeline.length > 10 ? 10 : behaviorTimeline.length,
                itemBuilder: (context, index) {
                  final entry = behaviorTimeline[index] as Map<String, dynamic>;
                  final behaviors = entry['behaviors'] as List?;
                  return ExpansionTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      radius: 16,
                      child: Text(
                        '${entry['frame']}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    title: Text('${entry['timestamp']?.toStringAsFixed(1)}s'),
                    subtitle: Text('${behaviors?.length ?? 0} behaviors'),
                    children: behaviors?.map((behavior) {
                      final b = behavior as Map<String, dynamic>;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.circle, size: 8),
                        title: Text(b['behavior'] ?? ''),
                        trailing: Text(
                          '${(b['confidence'] * 100).toStringAsFixed(1)}%',
                        ),
                      );
                    }).toList() ?? [],
                  );
                },
              ),
            ),
            if (behaviorTimeline.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${behaviorTimeline.length - 10} more entries',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
