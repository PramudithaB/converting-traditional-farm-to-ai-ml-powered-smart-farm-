# 🐄 CATTLE DISEASE DETECTION API - Documentation

## 📋 Overview

Complete REST API for cattle disease detection system with multimodal analysis.

**Base URL**: `http://localhost:5000/api`

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install flask flask-cors tensorflow ultralytics opencv-python joblib pandas numpy
```

### 2. Start Server

```bash
python api_server.py
```

Server will start on `http://0.0.0.0:5000`

---

## 📡 API Endpoints

### 1. Health Check

**GET** `/api/health`

Check if API is running.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-02T10:30:00",
  "models_loaded": true,
  "version": "1.0"
}
```

---

### 2. Models Status

**GET** `/api/models/status`

Check which models are loaded.

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

### 3. Disease Detection

**POST** `/api/disease/detect`

Detect disease from cattle image.

**Request:**
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `image` (file): Cattle image (JPG/PNG)
  - `use_yolo` (optional, string): "true" or "false" (default: "false")

**Response:**
```json
{
  "disease": "Mastitis",
  "confidence": 0.8459,
  "densenet": {
    "disease": "Mastitis",
    "confidence": 0.8459,
    "all_predictions": {
      "Contagious": 0.0012,
      "Dermatophilosis": 0.0034,
      "FMD": 0.0156,
      "Healthy": 0.0789,
      "Lumpy Skin": 0.0234,
      "Mastitis": 0.8459,
      "Pediculosis": 0.0123,
      "Ringworm": 0.0193
    }
  },
  "recommended": "densenet",
  "timestamp": "2026-01-02T10:30:00"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:5000/api/disease/detect \
  -F "image=@/path/to/cattle_image.jpg" \
  -F "use_yolo=false"
```

---

### 4. Complete Analysis

**POST** `/api/disease/analyze`

Complete diagnosis: Disease + Severity + Treatment.

**Request:**
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `image` (file): Cattle image
  - `weight` (float): Cow weight in kg (default: 450)
  - `age` (float): Cow age in months (default: 40)
  - `temperature` (float): Body temperature in °C (default: 38.5)
  - `previous_disease` (optional, string): Previous disease name

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
    "confidence": 1.0000,
    "alternatives": [
      {
        "treatment": "Anti-inflammatory + Rest",
        "probability": 1.0000
      },
      {
        "treatment": "Antibiotics + Isolation",
        "probability": 0.0000
      },
      {
        "treatment": "Topical Treatment + Monitoring",
        "probability": 0.0000
      }
    ]
  },
  "clinical_data": {
    "weight": 450,
    "age": 40,
    "temperature": 39.5,
    "previous_disease": null
  },
  "timestamp": "2026-01-02T10:30:00"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:5000/api/disease/analyze \
  -F "image=@/path/to/cattle_image.jpg" \
  -F "weight=450" \
  -F "age=40" \
  -F "temperature=39.5" \
  -F "previous_disease=None"
```

---

### 5. Quick Diagnosis (YOLO)

**POST** `/api/quick-diagnosis`

Fast diagnosis using YOLOv8x-Classifier only.

**Request:**
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `image` (file): Cattle image

**Response:**
```json
{
  "disease": "FMD",
  "confidence": 0.9994,
  "top3": [
    {
      "disease": "FMD",
      "confidence": 0.9994
    },
    {
      "disease": "Healthy",
      "confidence": 0.0005
    },
    {
      "disease": "Ringworm",
      "confidence": 0.0001
    }
  ],
  "model": "YOLOv8x-Classifier",
  "timestamp": "2026-01-02T10:30:00"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:5000/api/quick-diagnosis \
  -F "image=@/path/to/cattle_image.jpg"
```

---

### 6. Save Behavior Snapshot

**POST** `/api/behavior/snapshot`

Save behavior data for a cow.

**Request:**
- **Content-Type**: `application/json`
- **Body**:
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
  "timestamp": "2026-01-02T10:30:00"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:5000/api/behavior/snapshot \
  -H "Content-Type: application/json" \
  -d '{
    "cow_id": "COW-001",
    "eating_time": 10.5,
    "lying_time": 0.55,
    "steps": 180,
    "rumination_time": 20.0,
    "temperature": 38.6
  }'
```

---

### 7. Analyze Behavior

**GET** `/api/behavior/analyze/<cow_id>`

Analyze behavior patterns for a cow.

**Parameters:**
- `cow_id` (path): Cow identifier (e.g., "COW-001")
- `hours` (query, optional): Hours of data to analyze (default: 24)

**Response:**
```json
{
  "cow_id": "COW-001",
  "status": "NORMAL",
  "confidence": 0.85,
  "hours_analyzed": 24,
  "current_metrics": {
    "eating_time": 10.2,
    "lying_time": 0.52,
    "steps": 175,
    "rumination_time": 19.5,
    "temperature": 38.7
  },
  "baseline_comparison": {
    "eating_deviation": "+5%",
    "lying_deviation": "-3%",
    "steps_deviation": "+2%"
  },
  "message": "Behavior within normal range",
  "timestamp": "2026-01-02T10:30:00"
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:5000/api/behavior/analyze/COW-001?hours=24"
```

---

### 8. Detect Behavior from Video Frame

**POST** `/api/behavior/detect-from-video`

Detect behavior from video frame using YOLOv8s.

**Request:**
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `image` (file): Video frame or cattle image

**Response:**
```json
{
  "behaviors": [
    {
      "behavior": "eating",
      "confidence": 0.8312
    },
    {
      "behavior": "standing",
      "confidence": 0.8440
    }
  ],
  "count": 2,
  "timestamp": "2026-01-02T10:30:00"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:5000/api/behavior/detect-from-video \
  -F "image=@/path/to/video_frame.jpg"
```

---

## 🔧 Error Handling

All endpoints return errors in JSON format:

```json
{
  "error": "Error message description"
}
```

**HTTP Status Codes:**
- `200`: Success
- `400`: Bad Request (invalid input)
- `500`: Internal Server Error (model error, etc.)

---

## 📊 Response Times

| Endpoint | Average Response Time |
|----------|----------------------|
| `/api/disease/detect` (DenseNet) | ~150ms |
| `/api/quick-diagnosis` (YOLO) | ~50ms |
| `/api/disease/analyze` (Complete) | ~300ms |
| `/api/behavior/snapshot` | ~10ms |
| `/api/behavior/analyze` | ~20ms |
| `/api/behavior/detect-from-video` | ~30ms |

---

## 🔒 Security Recommendations

For production deployment:

1. **Add Authentication**:
```python
from flask_httpauth import HTTPBasicAuth
auth = HTTPBasicAuth()

@auth.verify_password
def verify_password(username, password):
    # Your authentication logic
    pass

@app.route('/api/disease/detect', methods=['POST'])
@auth.login_required
def detect_disease():
    # ...
```

2. **Add Rate Limiting**:
```bash
pip install flask-limiter
```

3. **Use HTTPS** in production

4. **Add API Keys** for tracking usage

---

## 📱 Integration Examples

### Python Client

```python
import requests

# Disease detection
url = "http://localhost:5000/api/disease/detect"
files = {'image': open('cattle_image.jpg', 'rb')}
response = requests.post(url, files=files)
print(response.json())

# Complete analysis
url = "http://localhost:5000/api/disease/analyze"
files = {'image': open('cattle_image.jpg', 'rb')}
data = {
    'weight': 450,
    'age': 40,
    'temperature': 39.5
}
response = requests.post(url, files=files, data=data)
print(response.json())
```

### JavaScript (Fetch API)

```javascript
// Disease detection
const formData = new FormData();
formData.append('image', fileInput.files[0]);

fetch('http://localhost:5000/api/disease/detect', {
  method: 'POST',
  body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Behavior snapshot
fetch('http://localhost:5000/api/behavior/snapshot', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    cow_id: 'COW-001',
    eating_time: 10.5,
    lying_time: 0.55,
    steps: 180,
    rumination_time: 20.0,
    temperature: 38.6
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

### Mobile (React Native)

```javascript
const uploadImage = async (uri) => {
  const formData = new FormData();
  formData.append('image', {
    uri: uri,
    type: 'image/jpeg',
    name: 'cattle.jpg'
  });

  const response = await fetch('http://localhost:5000/api/quick-diagnosis', {
    method: 'POST',
    body: formData
  });

  const result = await response.json();
  console.log(result);
};
```

---

## 🚀 Deployment

### Local Development

```bash
python api_server.py
```

### Production (Gunicorn)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 api_server:app
```

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "api_server:app"]
```

### Cloud Deployment Options

- **AWS**: Elastic Beanstalk, EC2, Lambda (with API Gateway)
- **Google Cloud**: App Engine, Cloud Run
- **Azure**: App Service
- **Heroku**: Direct deployment

---

## 📈 Monitoring

### Health Check Endpoint

Use `/api/health` for monitoring:

```bash
# Check every minute
*/1 * * * * curl http://localhost:5000/api/health
```

### Logging

Add logging for production:

```python
import logging

logging.basicConfig(
    filename='api.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

@app.before_request
def log_request():
    logging.info(f"{request.method} {request.path}")
```

---

## ❓ FAQ

**Q: Can I run multiple models simultaneously?**  
A: Yes, the API loads all models at startup and handles requests concurrently.

**Q: What's the maximum image size?**  
A: Images are resized to 224x224, so any size works. Recommended < 10MB.

**Q: Can I use this for mobile apps?**  
A: Yes! Use `/api/quick-diagnosis` for fast mobile inference.

**Q: How do I add authentication?**  
A: Use Flask-HTTPAuth or implement JWT tokens.

**Q: Can I deploy this on Raspberry Pi?**  
A: Yes, but use YOLO models only (lightweight). DenseNet may be slow.

---

## 📞 Support

For issues or questions:
- Check logs in `api.log`
- Test with `/api/health` and `/api/models/status`
- Verify all model files exist in `models/` directory

---

**API Version**: 1.0  
**Last Updated**: January 2, 2026
