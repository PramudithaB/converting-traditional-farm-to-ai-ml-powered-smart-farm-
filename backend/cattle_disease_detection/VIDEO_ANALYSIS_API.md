# 🎥 VIDEO ANALYSIS API - COMPLETE GUIDE

## Overview

The new **`/api/video/analyze`** endpoint allows you to analyze complete video files for both **behavior detection** and **disease detection** simultaneously.

### ✅ What's New?

- **Direct video upload** - Upload MP4, AVI, MOV, MKV, WEBM files
- **Automatic frame extraction** - System extracts frames at your chosen interval
- **Dual detection** - Both behavior and disease detection in one request
- **Timeline results** - See detections with timestamps
- **Summary statistics** - Aggregated results across entire video

---

## 🚀 Quick Start

### 1. Basic Usage

```python
import requests

with open('cattle_video.mp4', 'rb') as video:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={'video': video},
        data={
            'frame_interval': 30,      # Extract 1 frame every 30 frames
            'detect_disease': 'true',
            'detect_behavior': 'true'
        }
    )

result = response.json()
print(f"Duration: {result['video_info']['duration']} seconds")
print(f"Behaviors: {list(result['summary']['behaviors'].keys())}")
print(f"Diseases: {list(result['summary']['diseases'].keys())}")
```

### 2. Postman Usage

1. Import **Cattle_Disease_API.postman_collection.json**
2. Find endpoint: **"9. Analyze Video File 🎥 (NEW)"**
3. Upload your video file
4. Adjust `frame_interval` (30 = ~1 fps)
5. Send request
6. View results with timeline and summary

### 3. cURL Usage

```bash
curl -X POST http://localhost:5000/api/video/analyze \
  -F "video=@cattle_video.mp4" \
  -F "frame_interval=30" \
  -F "detect_disease=true" \
  -F "detect_behavior=true"
```

---

## 📋 API Reference

### Endpoint
**POST** `/api/video/analyze`

### Request Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `video` | File | ✅ Yes | - | Video file (MP4, AVI, MOV, MKV, WEBM) |
| `frame_interval` | Integer | ❌ No | 30 | Extract 1 frame every N frames (30 = ~1fps at 30fps video) |
| `detect_disease` | Boolean | ❌ No | true | Enable disease detection |
| `detect_behavior` | ❌ No | true | Enable behavior detection |

### Supported Video Formats
- ✅ MP4 (H.264, H.265)
- ✅ AVI
- ✅ MOV (QuickTime)
- ✅ MKV (Matroska)
- ✅ WEBM

### Response Structure

```json
{
  "video_info": {
    "duration": 60.5,           // Video duration in seconds
    "fps": 30.0,                // Frames per second
    "total_frames": 1815,       // Total frames in video
    "analyzed_frames": 60,      // Frames that were analyzed
    "frame_interval": 30        // Frames skipped between analysis
  },
  "behavior_timeline": [
    {
      "timestamp": 0.0,         // Time in seconds
      "frame": 0,               // Frame number
      "behaviors": [
        {
          "behavior": "eating",
          "confidence": 0.8312
        },
        {
          "behavior": "standing",
          "confidence": 0.7541
        }
      ]
    },
    // ... more timeline entries
  ],
  "disease_detections": [
    {
      "timestamp": 5.2,         // Time in seconds
      "frame": 5,               // Frame number
      "disease": "Mastitis",
      "confidence": 0.8459
    },
    // ... more detections
  ],
  "summary": {
    "behaviors": {
      "eating": {
        "count": 35,            // Times detected
        "avg_confidence": 0.8123
      },
      "standing": {
        "count": 42,
        "avg_confidence": 0.7834
      }
      // ... more behaviors
    },
    "diseases": {
      "Mastitis": {
        "count": 48,            // Times detected
        "avg_confidence": 0.8312,
        "first_seen": 0.0,      // First detection time
        "last_seen": 58.5       // Last detection time
      }
      // ... more diseases
    }
  },
  "timestamp": "2026-01-03T10:30:00"
}
```

---

## ⚙️ Performance Optimization

### Frame Interval Guide

| Interval | FPS | Speed | Accuracy | Use Case |
|----------|-----|-------|----------|----------|
| 60 | 0.5 fps | ⚡ Fast | ⭐ Basic | Quick overview |
| 30 | 1 fps | ⚡⚡ Balanced | ⭐⭐⭐ Good | **Recommended** |
| 15 | 2 fps | ⚡⚡⚡ Slow | ⭐⭐⭐⭐ Better | High accuracy |
| 10 | 3 fps | ⚡⚡⚡⚡ Very Slow | ⭐⭐⭐⭐⭐ Best | Maximum accuracy |

### Processing Time Estimates

**60-second video:**
- `frame_interval=60`: ~5 seconds
- `frame_interval=30`: ~10 seconds ✅ Recommended
- `frame_interval=15`: ~20 seconds
- `frame_interval=10`: ~30 seconds

**Factors affecting speed:**
- Video resolution (lower = faster)
- Video length (shorter = faster)
- Detection modes (behavior-only = faster)
- Server hardware (GPU = much faster)

### Speed Optimization Examples

#### Fast Mode (Behavior Only)
```python
# Only detect behavior, skip disease detection
data = {
    'frame_interval': 60,       # 1 frame every 2 seconds
    'detect_disease': 'false',  # Skip disease
    'detect_behavior': 'true'
}
# Processing time: ~50% faster
```

#### Balanced Mode (Recommended)
```python
# Both detections with good accuracy
data = {
    'frame_interval': 30,       # 1 frame per second
    'detect_disease': 'true',
    'detect_behavior': 'true'
}
# Processing time: Good balance
```

#### Accuracy Mode
```python
# Maximum accuracy, more frames
data = {
    'frame_interval': 15,       # 2 frames per second
    'detect_disease': 'true',
    'detect_behavior': 'true'
}
# Processing time: 2x slower, better results
```

---

## 💡 Use Cases

### 1. Analyze CCTV Footage
```python
# Analyze recorded surveillance video
with open('cctv_recording.mp4', 'rb') as video:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={'video': video},
        data={'frame_interval': 30}
    )
    
    # Check if any diseases detected
    diseases = response.json()['summary']['diseases']
    if diseases:
        print("⚠️ Diseases detected:")
        for disease, stats in diseases.items():
            print(f"  - {disease}: {stats['count']} frames")
```

### 2. Mobile App Integration
```python
# Upload video from mobile phone
def analyze_mobile_video(video_path):
    with open(video_path, 'rb') as video:
        response = requests.post(
            'http://localhost:5000/api/video/analyze',
            files={'video': video},
            data={
                'frame_interval': 30,
                'detect_disease': 'true',
                'detect_behavior': 'true'
            }
        )
    return response.json()

# User records video on phone → upload → get analysis
result = analyze_mobile_video('phone_recording.mp4')
```

### 3. Batch Processing
```python
# Process multiple videos
import glob

video_files = glob.glob('cattle_videos/*.mp4')

for video_path in video_files:
    print(f"Processing: {video_path}")
    
    with open(video_path, 'rb') as video:
        response = requests.post(
            'http://localhost:5000/api/video/analyze',
            files={'video': video},
            data={'frame_interval': 60}  # Fast mode for batch
        )
    
    result = response.json()
    print(f"  Duration: {result['video_info']['duration']}s")
    print(f"  Behaviors: {len(result['summary']['behaviors'])} types")
    print(f"  Diseases: {len(result['summary']['diseases'])} types")
```

### 4. Disease Progression Monitoring
```python
# Track disease over time in video
response = requests.post(
    'http://localhost:5000/api/video/analyze',
    files={'video': open('cow_monitoring.mp4', 'rb')},
    data={
        'frame_interval': 15,  # More frames for accuracy
        'detect_disease': 'true',
        'detect_behavior': 'false'  # Focus on disease
    }
)

result = response.json()

# Check if disease appears/disappears
for disease, stats in result['summary']['diseases'].items():
    print(f"{disease}:")
    print(f"  First seen: {stats['first_seen']}s")
    print(f"  Last seen: {stats['last_seen']}s")
    print(f"  Persistence: {stats['last_seen'] - stats['first_seen']}s")
```

### 5. Behavior Pattern Analysis
```python
# Focus on behavior detection
response = requests.post(
    'http://localhost:5000/api/video/analyze',
    files={'video': open('cow_behavior.mp4', 'rb')},
    data={
        'frame_interval': 30,
        'detect_disease': 'false',  # Skip disease
        'detect_behavior': 'true'
    }
)

result = response.json()

# Find dominant behaviors
behaviors = result['summary']['behaviors']
dominant = max(behaviors.items(), key=lambda x: x[1]['count'])
print(f"Dominant behavior: {dominant[0]} ({dominant[1]['count']} frames)")
```

---

## 🔧 Technical Details

### How It Works

1. **Video Upload** - Server receives video file
2. **Frame Extraction** - OpenCV extracts frames at specified interval
3. **Detection Pipeline**:
   - YOLOv8s detects behaviors in each frame
   - YOLOv8x detects diseases in each frame
4. **Aggregation** - Results compiled with timestamps
5. **Cleanup** - Video file deleted from server
6. **Response** - Timeline + summary returned as JSON

### Models Used

- **Behavior Detection**: YOLOv8s (30-60 FPS per frame)
- **Disease Detection**: YOLOv8x-Classifier (10-20 FPS per frame)

### Confidence Thresholds

- **Behavior**: 0.3 (30%) minimum confidence
- **Disease**: 0.5 (50%) minimum confidence

---

## ❓ FAQ

### Q: What's the maximum video size?
**A:** Recommended: < 100 MB. Maximum: 500 MB (adjust Flask config if needed).

### Q: Can I process live camera feeds?
**A:** For live feeds, use `/api/behavior/detect-from-video` endpoint with individual frames instead of uploading entire videos.

### Q: How accurate is video analysis?
**A:** Accuracy depends on:
- Video quality (HD > SD)
- Frame interval (lower = more accurate)
- Lighting conditions (good lighting = better)
- Camera angle (side view best for disease, top for behavior)

### Q: Can I analyze only part of a video?
**A:** Currently analyzes entire video. To analyze specific segment, trim video first using ffmpeg:
```bash
ffmpeg -i input.mp4 -ss 00:00:10 -t 00:00:30 -c copy output.mp4
# Extracts 30 seconds starting at 10 seconds
```

### Q: What if video has multiple cows?
**A:** System detects all visible cows in each frame. Results represent aggregate across all cows in video.

### Q: How to handle large videos?
**A:** Options:
1. Increase `frame_interval` (faster, less accurate)
2. Split video into smaller segments
3. Use only disease OR behavior detection (not both)
4. Compress video before upload

---

## 🚨 Error Handling

### Common Errors

```python
# Error: Invalid video format
{
  "error": "Invalid video file format. Supported: mp4, avi, mov, mkv, webm"
}

# Error: Video processing failed
{
  "error": "Failed to process video file"
}

# Error: No video uploaded
{
  "error": "No video file uploaded"
}
```

### Retry Logic Example

```python
import time

def analyze_video_with_retry(video_path, max_retries=3):
    for attempt in range(max_retries):
        try:
            with open(video_path, 'rb') as video:
                response = requests.post(
                    'http://localhost:5000/api/video/analyze',
                    files={'video': video},
                    data={'frame_interval': 30},
                    timeout=300  # 5 minute timeout
                )
                
                if response.status_code == 200:
                    return response.json()
                else:
                    print(f"Attempt {attempt + 1} failed: {response.status_code}")
                    time.sleep(2)
        
        except requests.exceptions.Timeout:
            print(f"Attempt {attempt + 1} timeout")
            time.sleep(2)
    
    return None
```

---

## 📊 Comparison with Other Endpoints

| Feature | `/video/analyze` | `/disease/detect` | `/behavior/detect-from-video` |
|---------|------------------|-------------------|------------------------------|
| Input | Video file | Image | Image (frame) |
| Behavior | ✅ Yes | ❌ No | ✅ Yes |
| Disease | ✅ Yes | ✅ Yes | ❌ No |
| Timeline | ✅ Yes | ❌ No | ❌ No |
| Summary | ✅ Yes | ❌ No | ❌ No |
| Speed | 🐢 Slow | ⚡ Fast | ⚡ Fast |
| Use Case | Recorded video | Single diagnosis | Real-time CCTV |

---

## 🎯 Best Practices

1. **Optimize Video First**
   - Compress large videos before upload
   - Use H.264 codec for best compatibility
   - 720p or 1080p resolution recommended

2. **Choose Right Frame Interval**
   - Use 60 for quick overview
   - Use 30 for balanced analysis (recommended)
   - Use 15 for important diagnostic videos

3. **Enable Only Needed Detection**
   - For behavior monitoring: `detect_disease=false`
   - For disease diagnosis: `detect_behavior=false`
   - Enable both only when necessary

4. **Handle Long Videos**
   - Split videos > 5 minutes into segments
   - Process segments in parallel
   - Combine results programmatically

5. **Monitor Server Resources**
   - Video analysis is CPU/GPU intensive
   - Process one video at a time
   - Implement queue system for batch processing

---

## 🔗 Related Documentation

- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - Complete API reference
- [QUICK_START_API.md](QUICK_START_API.md) - Getting started guide
- [Cattle_Disease_API.postman_collection.json](Cattle_Disease_API.postman_collection.json) - Postman collection

---

## 📝 Testing

Run the test script:

```bash
python test_video_api.py
```

This will:
1. Check for video files in `cattels_images_videos/videos/`
2. Process first video found
3. Display results with timeline and summary
4. Show usage examples

---

## 💬 Support

For issues or questions:
1. Check error messages in response
2. Verify video format is supported
3. Try with smaller video first
4. Check server logs for detailed errors

---

**Last Updated:** January 3, 2026  
**API Version:** 1.1 (Added video analysis)
