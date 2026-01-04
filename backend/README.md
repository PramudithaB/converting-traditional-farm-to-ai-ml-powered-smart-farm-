# Smart Farm AI Backend - Unified API Server

A consolidated Flask backend that serves all AI/ML models for the Smart Farm application on a single port (5000).

## 🚀 Features

This unified backend consolidates the following services:
- **Animal Birth Prediction** - Predicts days until animal birth
- **Cow Identification** - Detects and identifies individual cows using YOLO
- **Cow Daily Feed** - Calculates optimal daily feed from images or manual input
- **Egg Hatch Prediction** - Predicts egg hatching probability
- **Milk Market Prediction** - Forecasts milk prices and income
- **Nutrition Recommendation** - Provides nutritional recommendations for cattle
- **Cattle Disease Detection** ⭐ **NEW** - Complete disease diagnosis system with:
  - Disease detection using DenseNet121 and YOLO
  - Severity assessment
  - Treatment recommendation
  - Behavior tracking and analysis
  - Video analysis for disease and behavior detection

## 📋 Prerequisites

- Python 3.9 or higher
- All model files properly placed in their respective folders

## 🔧 Installation

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment (recommended):**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Verify model files exist:**
   - `animal_birth/clf.pkl`
   - `cow_identify/best.pt`
   - `cow_daily_feed/models/best_seg_model.h5`
   - `cow_daily_feed/models/best_reg_model.h5`
   - `cow_daily_feed/models/cow_feed_predictor.pkl`
   - `cow_daily_feed/models/breed_encoder.pkl`
   - `cow_daily_feed/models/activity_encoder.pkl`
   - `egg_hatch/egg_hatch_scaler.joblib`
   - `egg_hatch/egg_hatch_nn.h5`
   - `milk_market_prediction/rf_milk_price_model.pkl`
   - `nutrition_recommended/multi_output_nutrition_model.pkl`

## ▶️ Running the Server

### Unified Backend (Recommended)

Run all services on port 5000:

```bash
python app.py
```

The server will start at `http://localhost:5000`

### Individual Services (Optional)

You can still run individual services if needed:

```bash
# Animal Birth
cd animal_birth && python app.py

# Cow Identification
cd cow_identify && python app.py

# Cow Daily Feed
cd cow_daily_feed && python app.py

# Egg Hatch
cd egg_hatch && python app.py

# Milk Market
cd milk_market_prediction && python app.py

# Nutrition
cd nutrition_recommended && python app.py
```

## 📡 API Endpoints

### Base URLs
- **Root:** `http://localhost:5000/`
- **Health Check:** `http://localhost:5000/health`

### Service Endpoints

#### 1. Animal Birth Prediction
**POST** `/animal-birth/predict`

```json
{
  "features": [value1, value2, value3, ...]
}
```

**Response:**
```json
{
  "Will Birth in Next 2 Days": "Yes/No",
  "Estimated Days to Birth": 1.5
}
```

---

#### 2. Cow Identification
**POST** `/cow-identify/detect`

**Form Data:**
- `image`: Image file

**Response:**
```json
{
  "detected": true,
  "cow_ids": ["cow_1", "cow_2"]
}
```

---

#### 3. Cow Daily Feed (From Image)
**POST** `/cow-feed/predict-from-image`

**Form Data:**
- `image`: Image file
- `breed`: Cow breed (e.g., "Holstein")
- `age`: Age in months
- `milk_yield`: Milk yield in L/day
- `activity`: Activity level (e.g., "High")

**Response:**
```json
{
  "mode": "image",
  "cow_weight_kg": 450.5,
  "daily_feed_kg": 25.3
}
```

---

#### 4. Cow Daily Feed (Manual Input)
**POST** `/cow-feed/predict-manual`

```json
{
  "breed": "Holstein",
  "age": 36,
  "weight": 450.5,
  "milk_yield": 25.0,
  "activity": "High"
}
```

**Response:**
```json
{
  "mode": "manual",
  "cow_weight_kg": 450.5,
  "daily_feed_kg": 25.3
}
```

---

#### 5. Egg Hatch Prediction
**POST** `/egg-hatch/predict`

```json
{
  "Temperature": 37.5,
  "Humidity": 60.0,
  "Egg_Weight": 55.0,
  "Egg_Turning_Frequency": 4,
  "Incubation_Duration": 18
}
```

**Response:**
```json
{
  "hatch_probability": 0.85,
  "predicted_class": 1
}
```

---

#### 6. Milk Market Prediction
**POST** `/milk-market/predict-income`

```json
{
  "current_price": 120.0,
  "monthly_milk_litres": 3000,
  "fat_percentage": 3.8,
  "snf_percentage": 8.5,
  "disease_stage": 0,
  "feed_quality": 2,
  "lactation_month": 4,
  "month": 6
}
```

**Response:**
```json
{
  "predicted_price_change_lkr_per_litre": 5.5,
  "predicted_next_month_price_lkr_per_litre": 125.5,
  "predicted_next_month_income_lkr": 376500.0
}
```

---

#### 7. Nutrition Recommendation
**POST** `/nutrition/predict`

```json
{
  "Age_Months": 36,
  "Weight_kg": 450,
  "Breed": "Holstein",
  "Milk_Yield_L_per_day": 25,
  "Health_Status": "Healthy",
  "Disease": "None",
  "Body_Condition_Score": 3.5,
  "Location": "Farm_A",
  "Energy_MJ_per_day": 150,
  "Crude_Protein_g_per_day": 2500,
  "Recommended_Feed_Type": "Mixed"
}
```

**Response:**
```json
{
  "status": "success",
  "prediction": {
    "Dry_Matter_Intake_kg_per_day": 22.5,
    "Calcium_g_per_day": 95.0,
    "Phosphorus_g_per_day": 65.0
  }
}
```

---

#### 8. Cattle Disease Detection (Health Check)
**GET** `/api/health`

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-05T10:30:00",
  "models_loaded": true,
  "version": "1.0"
}
```

---

#### 9. Cattle Models Status
**GET** `/api/models/status`

**Response:**
```json
{
  "densenet121": true,
  "yolo_disease": true,
  "yolo_behavior": true,
  "severity_model": true,
  "treatment_model": true,
  "behavior_system": true,
  "ultralytics": true
}
```

---

#### 10. Disease Detection (DenseNet)
**POST** `/api/disease/detect`

**Form Data:**
- `image`: Image file
- `use_yolo`: Optional (true/false)

**Response:**
```json
{
  "disease": "Mastitis",
  "confidence": 0.8459,
  "densenet": {
    "disease": "Mastitis",
    "confidence": 0.8459,
    "all_predictions": {...}
  },
  "recommended": "densenet",
  "timestamp": "2026-01-05T10:30:00"
}
```

---

#### 11. Complete Disease Analysis ⭐
**POST** `/api/disease/analyze`

**Form Data:**
- `image`: Image file (required)
- `weight`: Cow weight in kg (default: 450)
- `age`: Cow age in months (default: 40)
- `temperature`: Body temperature in °C (default: 38.5)
- `previous_disease`: Previous disease name (optional)

**Response:**
```json
{
  "disease": {
    "name": "Mastitis",
    "confidence": 0.8459
  },
  "severity": {
    "level": "Moderate",
    "confidence": 0.9999,
    "probabilities": {
      "Mild": 0.0001,
      "Moderate": 0.9999,
      "Severe": 0.0000
    }
  },
  "treatment": {
    "primary": "Anti-inflammatory + Rest",
    "confidence": 1.0,
    "alternatives": [...]
  },
  "clinical_data": {...}
}
```

---

#### 12. Quick Diagnosis (YOLO - Fast)
**POST** `/api/quick-diagnosis`

**Form Data:**
- `image`: Image file

**Response:**
```json
{
  "disease": "FMD",
  "confidence": 0.9994,
  "top3": [
    {"disease": "FMD", "confidence": 0.9994},
    {"disease": "Healthy", "confidence": 0.0005},
    {"disease": "Ringworm", "confidence": 0.0001}
  ],
  "model": "YOLOv8x-Classifier",
  "timestamp": "2026-01-05T10:30:00"
}
```

---

#### 13. Save Behavior Snapshot
**POST** `/api/behavior/snapshot`

**JSON Body:**
```json
{
  "cow_id": "COW-001",
  "eating_time": 10.5,
  "lying_time": 0.55,
  "steps": 180,
  "rumination_time": 20.0,
  "temperature": 38.6
}
```

**Response:**
```json
{
  "snapshot_id": 1,
  "cow_id": "COW-001",
  "hours_of_data": 0.5,
  "message": "Snapshot saved successfully",
  "timestamp": "2026-01-05T10:30:00"
}
```

---

#### 14. Analyze Behavior
**GET** `/api/behavior/analyze/{cow_id}?hours=24`

**Response:**
```json
{
  "cow_id": "COW-001",
  "status": "NORMAL",
  "confidence": 0.85,
  "hours_analyzed": 24,
  "current_metrics": {...},
  "baseline_comparison": {...}
}
```

---

#### 15. Detect Behavior from Video Frame
**POST** `/api/behavior/detect-from-video`

**Form Data:**
- `image`: Video frame or cattle image

**Response:**
```json
{
  "behaviors": [
    {"behavior": "eating", "confidence": 0.8312},
    {"behavior": "standing", "confidence": 0.8440}
  ],
  "count": 2,
  "timestamp": "2026-01-05T10:30:00"
}
```

---

#### 16. Analyze Video File 🎥
**POST** `/api/video/analyze`

**Form Data:**
- `video`: Video file (MP4, AVI, MOV, MKV, WEBM)
- `frame_interval`: Extract 1 frame every N frames (default: 30)
- `detect_disease`: Enable disease detection (default: true)
- `detect_behavior`: Enable behavior detection (default: true)

**Response:**
```json
{
  "video_info": {
    "duration": 60.5,
    "fps": 30.0,
    "total_frames": 1815,
    "analyzed_frames": 60,
    "frame_interval": 30
  },
  "behavior_timeline": [...],
  "disease_detections": [...],
  "summary": {
    "behaviors": {...},
    "diseases": {...}
  }
}
```

## 🧪 Testing with cURL

```bash
# Health Check
curl http://localhost:5000/health

# Animal Birth
curl -X POST http://localhost:5000/animal-birth/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [1, 2, 3, 4, 5]}'

# Cow Identification
curl -X POST http://localhost:5000/cow-identify/detect \
  -F "image=@cow_image.jpg"

# Cattle Disease Detection
curl http://localhost:5000/api/health

# Quick Diagnosis
curl -X POST http://localhost:5000/api/quick-diagnosis \
  -F "image=@cattle_image.jpg"

# Complete Analysis
curl -X POST http://localhost:5000/api/disease/analyze \
  -F "image=@cattle_image.jpg" \
  -F "weight=450" \
  -F "age=40" \
  -F "temperature=39.5"
```

# Egg Hatch
curl -X POST http://localhost:5000/egg-hatch/predict \
  -H "Content-Type: application/json" \
  -d '{"Temperature": 37.5, "Humidity": 60, "Egg_Weight": 55, "Egg_Turning_Frequency": 4, "Incubation_Duration": 18}'
```

## 🔍 Health Check

Check which services are loaded successfully:

```bash
curl http://localhost:5000/health
```

Returns:
```json
{
  "status": "healthy",
  "services": {
    "animal_birth": true,
    "cow_identify": true,
    "egg_hatch": true,
    "milk_market": true,
    "nutrition": true,
    "cow_feed": true
  }
}
```

## 📁 Project Structure

```
backend/
├── app.py                      # ⭐ Main unified server
├── requirements.txt            # Consolidated dependencies
├── README.md                   # This file
├── uploads/                    # Temporary image uploads
│
├── animal_birth/
│   ├── app.py                  # Individual service (optional)
│   ├── clf.pkl                 # Model file
│   └── requirements.txt
│
├── cow_identify/
│   ├── app.py
│   ├── best.pt
│   └── requirements.txt
│
├── cow_daily_feed/
│   ├── app.py
│   ├── models/
│   │   ├── best_seg_model.h5
│   │   ├── best_reg_model.h5
│   │   ├── cow_feed_predictor.pkl
│   │   ├── breed_encoder.pkl
│   │   └── activity_encoder.pkl
│   └── requirements.txt
│
├── egg_hatch/
│   ├── app.py
│   ├── egg_hatch_nn.h5
│   ├── egg_hatch_scaler.joblib
│   └── requirment.txt
│
├── milk_market_prediction/
│   ├── app.py
│   ├── rf_milk_price_model.pkl
│   └── requirements.txt
│
└── nutrition_recommended/
    ├── app.py
    ├── multi_output_nutrition_model.pkl
    └── requirements.txt
```

## 🐛 Troubleshooting

### Issue: Model not loading
- Check that model files exist in the correct locations
- Verify model file names match those in the code
- Check the console output when starting the server for specific error messages

### Issue: Port already in use
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :5000
kill -9 <PID>
```

### Issue: Module not found
```bash
pip install -r requirements.txt --force-reinstall
```

## 📝 Environment Variables (Optional)

You can configure the following environment variables:

```bash
export FLASK_ENV=development
export FLASK_PORT=5000
export FLASK_HOST=0.0.0.0
```

## 🔒 CORS Configuration

CORS is enabled for all origins. For production, modify the CORS settings in `app.py`:

```python
CORS(app, resources={r"/*": {"origins": "https://your-frontend-domain.com"}})
```

## 📊 Performance Tips

1. **Use Production Server**: For production, use Gunicorn or uWSGI instead of Flask's built-in server
   ```bash
   pip install gunicorn
   gunicorn -w 4 -b 0.0.0.0:5000 app:app
   ```

2. **Model Caching**: Models are loaded once at startup and cached in memory

3. **Image Cleanup**: Temporary uploaded images are automatically deleted after processing

## 🤝 Contributing

When adding new endpoints:
1. Add the endpoint handler in `app.py`
2. Update this README with the new endpoint documentation
3. Follow the naming convention: `/<service-name>/<action>`

## 📄 License

[Your License Here]

## 👨‍💻 Support

For issues or questions, contact the development team.

---

**Last Updated:** January 2026
