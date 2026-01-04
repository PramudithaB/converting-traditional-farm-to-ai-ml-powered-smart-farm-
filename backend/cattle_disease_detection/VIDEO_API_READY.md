# ✅ VIDEO ANALYSIS FEATURE - READY!

## 🎉 What's New?

You can now **analyze complete video files** for both behavior and disease detection in a single request!

---

## 🚀 Quick Start

### 1. Start the Server
```bash
python api_server.py
```

### 2. Test with Video
```bash
python test_video_api.py
```

### 3. Or Use Postman
- Import: `Cattle_Disease_API.postman_collection.json`
- Find: **"9. Analyze Video File 🎥 (NEW)"**
- Upload your video (MP4, AVI, MOV)
- Send request

---

## 📋 New API Endpoint

### **POST** `/api/video/analyze`

**Upload:** Video file (MP4, AVI, MOV, MKV, WEBM)

**Parameters:**
- `frame_interval`: Extract 1 frame every N frames (default: 30 = ~1fps)
- `detect_disease`: Enable disease detection (default: true)
- `detect_behavior`: Enable behavior detection (default: true)

**Returns:**
- Video info (duration, FPS, frames)
- Behavior timeline with timestamps
- Disease detections with timestamps
- Aggregated summary statistics

---

## 💡 Example Usage

### Python
```python
import requests

with open('cattle_video.mp4', 'rb') as video:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={'video': video},
        data={
            'frame_interval': 30,      # 1 frame per second
            'detect_disease': 'true',
            'detect_behavior': 'true'
        }
    )

result = response.json()

# Video info
print(f"Duration: {result['video_info']['duration']}s")
print(f"Analyzed: {result['video_info']['analyzed_frames']} frames")

# Behaviors detected
for behavior, stats in result['summary']['behaviors'].items():
    print(f"{behavior}: {stats['count']} times, {stats['avg_confidence']:.2%} confidence")

# Diseases detected
for disease, stats in result['summary']['diseases'].items():
    print(f"{disease}: {stats['count']} frames, first seen at {stats['first_seen']}s")
```

### cURL
```bash
curl -X POST http://localhost:5000/api/video/analyze \
  -F "video=@cattle_video.mp4" \
  -F "frame_interval=30" \
  -F "detect_disease=true" \
  -F "detect_behavior=true"
```

---

## 📊 Response Example

```json
{
  "video_info": {
    "duration": 60.5,
    "fps": 30.0,
    "total_frames": 1815,
    "analyzed_frames": 60,
    "frame_interval": 30
  },
  "behavior_timeline": [
    {
      "timestamp": 0.0,
      "frame": 0,
      "behaviors": [
        {"behavior": "eating", "confidence": 0.8312},
        {"behavior": "standing", "confidence": 0.7541}
      ]
    }
  ],
  "disease_detections": [
    {
      "timestamp": 5.2,
      "frame": 5,
      "disease": "Mastitis",
      "confidence": 0.8459
    }
  ],
  "summary": {
    "behaviors": {
      "eating": {"count": 35, "avg_confidence": 0.8123},
      "standing": {"count": 42, "avg_confidence": 0.7834}
    },
    "diseases": {
      "Mastitis": {
        "count": 48,
        "avg_confidence": 0.8312,
        "first_seen": 0.0,
        "last_seen": 58.5
      }
    }
  }
}
```

---

## ⚙️ Performance Tips

### Frame Interval Guide
- **60** - Fast (0.5 fps) - Quick overview
- **30** - Balanced (1 fps) - ⭐ **Recommended**
- **15** - Accurate (2 fps) - Better results
- **10** - Very accurate (3 fps) - Best quality

### Speed Optimization
```python
# Fast mode (behavior only)
data = {
    'frame_interval': 60,
    'detect_disease': 'false',
    'detect_behavior': 'true'
}
# Processing time: ~50% faster
```

### Accuracy Mode
```python
# Maximum accuracy
data = {
    'frame_interval': 15,  # 2 frames per second
    'detect_disease': 'true',
    'detect_behavior': 'true'
}
# Processing time: 2x slower, better results
```

---

## 🎯 Use Cases

### 1. **Analyze CCTV Recordings**
Upload recorded surveillance footage to detect diseases and monitor behavior patterns over time.

### 2. **Mobile App Upload**
Users record video on phone → upload to API → get complete analysis with timeline.

### 3. **Batch Processing**
Process multiple videos from different cameras or time periods.

### 4. **Disease Progression**
Monitor how disease symptoms change throughout the video duration.

### 5. **Behavior Monitoring**
Track cow behavior patterns over extended time periods.

---

## 📁 Files Updated/Created

### Modified Files:
- ✅ **api_server.py** - Added video processing endpoint
- ✅ **Cattle_Disease_API.postman_collection.json** - Added endpoint #9

### New Files:
- ✅ **test_video_api.py** - Test script for video analysis
- ✅ **VIDEO_ANALYSIS_API.md** - Complete documentation (this file)

---

## 🔧 Technical Details

### How It Works:
1. Upload video file (MP4, AVI, MOV, etc.)
2. Server extracts frames at specified interval using OpenCV
3. Each frame analyzed by:
   - YOLOv8s (behavior detection)
   - YOLOv8x (disease detection)
4. Results aggregated with timestamps
5. Return timeline + summary statistics

### Models Used:
- **YOLOv8s** - 9 behavior classes (eating, standing, lying, etc.)
- **YOLOv8x-Classifier** - 8 disease classes (Mastitis, FMD, etc.)

### Confidence Thresholds:
- Behavior: 0.3 (30%) minimum
- Disease: 0.5 (50%) minimum

---

## 📊 API Endpoints Summary

Now you have **9 total endpoints**:

| # | Endpoint | Method | Purpose |
|---|----------|--------|---------|
| 1 | `/api/health` | GET | Health check |
| 2 | `/api/models/status` | GET | Models status |
| 3 | `/api/disease/detect` | POST | Disease from image |
| 4 | `/api/disease/analyze` | POST | Complete analysis |
| 5 | `/api/quick-diagnosis` | POST | Fast YOLO diagnosis |
| 6 | `/api/behavior/snapshot` | POST | Save behavior data |
| 7 | `/api/behavior/analyze/<id>` | GET | Analyze patterns |
| 8 | `/api/behavior/detect-from-video` | POST | Detect from frame |
| 9 | **`/api/video/analyze`** | **POST** | **Analyze video file 🎥 NEW!** |

---

## ❓ FAQ

**Q: What video formats are supported?**  
A: MP4, AVI, MOV, MKV, WEBM

**Q: How long does processing take?**  
A: 60-second video with frame_interval=30 takes ~10 seconds

**Q: Can I process live camera feeds?**  
A: For live feeds, use `/api/behavior/detect-from-video` with individual frames instead

**Q: What's the maximum video size?**  
A: Recommended < 100 MB. Maximum 500 MB.

**Q: How accurate is it?**  
A: Depends on video quality, lighting, and frame_interval. Lower frame_interval = more accurate.

---

## 🎯 Testing Checklist

- [ ] Server running on http://localhost:5000
- [ ] Place video file in `cattels_images_videos/videos/`
- [ ] Run `python test_video_api.py`
- [ ] Or test with Postman (endpoint #9)
- [ ] Check response has `video_info`, `behavior_timeline`, `disease_detections`, `summary`
- [ ] Verify timestamps match video duration
- [ ] Test with different `frame_interval` values

---

## 📚 Documentation

- **[VIDEO_ANALYSIS_API.md](VIDEO_ANALYSIS_API.md)** - Complete guide (you are here!)
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Full API reference
- **[QUICK_START_API.md](QUICK_START_API.md)** - Getting started
- **[test_video_api.py](test_video_api.py)** - Test script

---

## 🎉 Summary

### ✅ What You Can Do Now:

1. **Upload video files** directly to API
2. **Get behavior timeline** with timestamps
3. **Get disease detections** throughout video
4. **See summary statistics** for entire video
5. **Process CCTV recordings** for monitoring
6. **Analyze mobile videos** from farmers
7. **Track disease progression** over time
8. **Monitor behavior patterns** in long videos

### 🔥 Key Benefits:

- ✅ **No frame extraction needed** - Upload video directly
- ✅ **Dual detection** - Behavior + disease in one request
- ✅ **Timeline results** - See when detections occur
- ✅ **Aggregated stats** - Summary across entire video
- ✅ **Flexible processing** - Adjust speed vs accuracy
- ✅ **Multiple formats** - MP4, AVI, MOV, MKV, WEBM

---

## 🚀 Next Steps

1. **Test the endpoint:**
   ```bash
   python test_video_api.py
   ```

2. **Try with Postman:**
   - Import collection
   - Use endpoint #9
   - Upload a video

3. **Integrate into your app:**
   - Use Python example above
   - Or cURL command
   - Or JavaScript fetch

4. **Optimize for your use case:**
   - Adjust `frame_interval` for speed
   - Enable/disable detection types
   - Process videos in batches

---

**🎥 Your API now supports video analysis!**

**Last Updated:** January 3, 2026  
**API Version:** 1.1
