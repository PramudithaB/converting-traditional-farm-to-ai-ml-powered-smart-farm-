# Cattle Disease Detection - API Endpoints Added to Unified Collection

## ✅ Successfully Added 9 Cattle Disease Detection Endpoints

The unified `Smart_Farm_API.postman_collection.json` now includes all cattle disease detection endpoints.

### 📋 Added Endpoints

#### 1. **Disease Detection Health Check**
- **Method:** GET
- **URL:** `http://localhost:5000/api/health`
- **Purpose:** Check if cattle disease detection API is running

#### 2. **Models Status**
- **Method:** GET
- **URL:** `http://localhost:5000/api/models/status`
- **Purpose:** Check which disease detection models are loaded

#### 3. **Disease Detection (DenseNet)**
- **Method:** POST
- **URL:** `http://localhost:5000/api/disease/detect`
- **Body:** Form-data with `image` file and optional `use_yolo` parameter
- **Purpose:** Detect disease from cattle image using DenseNet121 CNN

#### 4. **Complete Disease Analysis ⭐**
- **Method:** POST
- **URL:** `http://localhost:5000/api/disease/analyze`
- **Body:** Form-data with:
  - `image` (required)
  - `weight` (default: 450 kg)
  - `age` (default: 40 months)
  - `temperature` (default: 38.5°C)
  - `previous_disease` (optional)
- **Purpose:** Complete analysis with disease detection, severity assessment, and treatment recommendation

#### 5. **Quick Diagnosis (YOLO - Fast)**
- **Method:** POST
- **URL:** `http://localhost:5000/api/quick-diagnosis`
- **Body:** Form-data with `image` file
- **Purpose:** Fast disease diagnosis using YOLOv8x-Classifier (~50ms response time)

#### 6. **Save Behavior Snapshot**
- **Method:** POST
- **URL:** `http://localhost:5000/api/behavior/snapshot`
- **Body:** JSON with:
  - `cow_id`
  - `eating_time` (minutes per hour)
  - `lying_time` (hours per hour, 0-1)
  - `steps` (steps per hour)
  - `rumination_time` (minutes per hour)
  - `temperature` (°C)
- **Purpose:** Save behavior data snapshot for a cow

#### 7. **Analyze Behavior**
- **Method:** GET
- **URL:** `http://localhost:5000/api/behavior/analyze/{cow_id}?hours=24`
- **Query Parameters:** `hours` (default: 24)
- **Purpose:** Analyze behavior patterns for a specific cow

#### 8. **Detect Behavior from Video Frame**
- **Method:** POST
- **URL:** `http://localhost:5000/api/behavior/detect-from-video`
- **Body:** Form-data with `image` (video frame)
- **Purpose:** Detect behavior from video frame using YOLOv8s

#### 9. **Analyze Video File 🎥**
- **Method:** POST
- **URL:** `http://localhost:5000/api/video/analyze`
- **Body:** Form-data with:
  - `video` (MP4, AVI, MOV, MKV, WEBM)
  - `frame_interval` (default: 30)
  - `detect_disease` (default: true)
  - `detect_behavior` (default: true)
- **Purpose:** Analyze complete video file for behavior and disease detection

## 🎯 Collection Structure

The collection is now organized as follows:

1. **Health & Status** (2 endpoints)
2. **Cattle Disease Detection** (9 endpoints) ⭐ NEW
3. **Animal Birth** (1 endpoint)
4. **Cow Identification** (1 endpoint)
5. **Cow Daily Feed** (2 endpoints)
6. **Egg Hatch** (1 endpoint)
7. **Milk Market** (1 endpoint)
8. **Nutrition** (1 endpoint)

**Total Endpoints:** 18

## 📦 How to Use

### Import to Postman:
1. Open Postman
2. Click **Import**
3. Select `backend/Smart_Farm_API.postman_collection.json`
4. All 18 endpoints will be available in organized folders

### Test Disease Detection:
```bash
# Health check
curl http://localhost:5000/api/health

# Quick diagnosis
curl -X POST http://localhost:5000/api/quick-diagnosis \
  -F "image=@path/to/cattle_image.jpg"

# Complete analysis
curl -X POST http://localhost:5000/api/disease/analyze \
  -F "image=@path/to/cattle_image.jpg" \
  -F "weight=450" \
  -F "age=40" \
  -F "temperature=39.5"
```

## 🔗 Related Files

- **Postman Collection:** `backend/Smart_Farm_API.postman_collection.json`
- **API Server:** `backend/cattle_disease_detection/api_server.py`
- **Original Collection:** `backend/cattle_disease_detection/Cattle_Disease_API.postman_collection.json`
- **API Documentation:** `backend/cattle_disease_detection/API_DOCUMENTATION.md`

## ⚠️ Important Notes

1. **Port:** The cattle disease detection API runs on the same port (5000) but uses `/api/*` prefix
2. **File Paths:** Update image/video file paths in Postman based on your local directory structure
3. **Models Required:** Ensure all required models are present in `cattle_disease_detection/models/`
4. **Dependencies:** Run `pip install -r cattle_disease_detection/requirements.txt`

## 🚀 Next Steps

1. ✅ Import the updated Postman collection
2. ✅ Test the cattle disease detection endpoints
3. ✅ Update frontend to use these API endpoints
4. ✅ Start the cattle disease detection server: `python cattle_disease_detection/api_server.py`

---

**Last Updated:** January 5, 2026
