# 🚀 QUICK START GUIDE - Cattle Disease Detection API

## ✅ What You Now Have

A **complete production-ready API backend** similar to your cow weight app.py, but for cattle disease detection!

### 📦 Files Created:

1. **`api_server.py`** - Main Flask API server (800+ lines)
2. **`API_DOCUMENTATION.md`** - Complete API documentation
3. **`api_test_client.py`** - Test client to verify all endpoints

---

## 🚀 How to Use

### Step 1: Start the API Server

```bash
cd "c:\Users\Deshan\Downloads\cattle disease detection"
python api_server.py
```

**Expected Output:**
```
======================================================================
🐄 CATTLE DISEASE DETECTION API SERVER
======================================================================

📋 Available Endpoints:
  GET  /api/health - Health check
  GET  /api/models/status - Models status
  POST /api/disease/detect - Disease detection
  POST /api/disease/analyze - Complete analysis
  POST /api/quick-diagnosis - Fast YOLO diagnosis
  POST /api/behavior/snapshot - Save behavior data
  GET  /api/behavior/analyze/<cow_id> - Analyze behavior
  POST /api/behavior/detect-from-video - Detect from video frame

======================================================================
🚀 Starting server on http://0.0.0.0:5000
======================================================================

🔄 Loading models...
✅ DenseNet121 loaded
✅ YOLOv8x Disease model loaded
✅ YOLOv8s Behavior model loaded
✅ Severity model loaded
✅ Treatment model loaded
✅ Behavior system loaded
✅ All available models loaded successfully!
```

### Step 2: Test the API

**Open a new terminal:**

```bash
python api_test_client.py
```

**Or test with cURL:**

```bash
# Health check
curl http://localhost:5000/api/health

# Disease detection
curl -X POST http://localhost:5000/api/disease/detect \
  -F "image=@cattels_images_videos/images/Disease_test_photo/mastitis/cattle_mastitis_012_jpg.rf.c5251eda8b68b716bc146d53bc692cd6.jpg"
```

---

## 📡 8 API Endpoints

### 1. **GET** `/api/health`
Check if server is running
```bash
curl http://localhost:5000/api/health
```

### 2. **GET** `/api/models/status`
Check which models are loaded
```bash
curl http://localhost:5000/api/models/status
```

### 3. **POST** `/api/disease/detect`
Detect disease from image (DenseNet121 + optional YOLO)
```bash
curl -X POST http://localhost:5000/api/disease/detect \
  -F "image=@path/to/cattle_image.jpg"
```

### 4. **POST** `/api/disease/analyze`
**Complete diagnosis** (Disease + Severity + Treatment)
```bash
curl -X POST http://localhost:5000/api/disease/analyze \
  -F "image=@path/to/cattle_image.jpg" \
  -F "weight=450" \
  -F "age=40" \
  -F "temperature=39.5"
```

### 5. **POST** `/api/quick-diagnosis`
Fast YOLO-based diagnosis
```bash
curl -X POST http://localhost:5000/api/quick-diagnosis \
  -F "image=@path/to/cattle_image.jpg"
```

### 6. **POST** `/api/behavior/snapshot`
Save behavior data
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

### 7. **GET** `/api/behavior/analyze/<cow_id>`
Analyze behavior patterns
```bash
curl http://localhost:5000/api/behavior/analyze/COW-001?hours=24
```

### 8. **POST** `/api/behavior/detect-from-video`
Detect behavior from video frame
```bash
curl -X POST http://localhost:5000/api/behavior/detect-from-video \
  -F "image=@path/to/video_frame.jpg"
```

---

## 🎯 Integration Examples

### Python Client

```python
import requests

# Complete disease analysis
url = "http://localhost:5000/api/disease/analyze"

with open("cattle_image.jpg", "rb") as f:
    files = {"image": f}
    data = {
        "weight": 450,
        "age": 40,
        "temperature": 39.5
    }
    response = requests.post(url, files=files, data=data)

result = response.json()
print(f"Disease: {result['disease']['name']}")
print(f"Severity: {result['severity']['level']}")
print(f"Treatment: {result['treatment']['primary']}")
```

### JavaScript (React/Next.js)

```javascript
const uploadImage = async (file) => {
  const formData = new FormData();
  formData.append('image', file);
  formData.append('weight', '450');
  formData.append('age', '40');
  formData.append('temperature', '39.5');

  const response = await fetch('http://localhost:5000/api/disease/analyze', {
    method: 'POST',
    body: formData
  });

  const result = await response.json();
  console.log(result);
};
```

### Mobile App (React Native)

```javascript
const diagnoseCattle = async (imageUri) => {
  const formData = new FormData();
  formData.append('image', {
    uri: imageUri,
    type: 'image/jpeg',
    name: 'cattle.jpg'
  });

  const response = await fetch('http://YOUR_SERVER_IP:5000/api/quick-diagnosis', {
    method: 'POST',
    body: formData
  });

  const result = await response.json();
  alert(`Disease: ${result.disease} (${result.confidence})`);
};
```

---

## 📊 Response Examples

### Complete Analysis Response

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
      }
    ]
  },
  "clinical_data": {
    "weight": 450,
    "age": 40,
    "temperature": 39.5
  },
  "timestamp": "2026-01-02T10:30:00"
}
```

---

## 🔧 Troubleshooting

### Server won't start?

```bash
# Check if port 5000 is available
netstat -ano | findstr :5000

# Kill process if needed
taskkill /PID <PID_NUMBER> /F

# Try again
python api_server.py
```

### Models not loading?

Check that all model files exist:
- `models/DenseNet121_Disease/best_model.h5`
- `models/All_Cattle_Disease/best.pt`
- `models/All_Behaviore/best.pt`
- `models/Treatment_Severity/best_model_gradient_boosting.pkl`
- `models/Treatment_Recommendation/best_model_gradient_boosting.pkl`

### Image upload fails?

- Max image size: 10MB
- Allowed formats: JPG, PNG, JPEG
- Check file path is correct

---

## 🚀 Deployment Options

### 1. **Local Network** (for farm use)
```bash
python api_server.py
# Access from any device: http://YOUR_PC_IP:5000
```

### 2. **Production Server** (Gunicorn)
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 api_server:app
```

### 3. **Cloud Deployment**
- **Heroku**: `git push heroku main`
- **AWS**: Deploy to Elastic Beanstalk
- **Google Cloud**: Deploy to App Engine
- **Azure**: Deploy to App Service

### 4. **Docker**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["python", "api_server.py"]
```

---

## 📱 Mobile App Integration

Your API is **mobile-ready**! Use `/api/quick-diagnosis` for fast mobile inference:

**Flutter/Dart:**
```dart
Future<void> uploadImage(File image) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://YOUR_SERVER:5000/api/quick-diagnosis')
  );
  request.files.add(await http.MultipartFile.fromPath('image', image.path));
  
  var response = await request.send();
  var result = await response.stream.bytesToString();
  print(result);
}
```

---

## 🔐 Security (Production)

### Add Authentication

```python
from flask_httpauth import HTTPBasicAuth
auth = HTTPBasicAuth()

users = {
    "admin": "secure_password_here"
}

@auth.verify_password
def verify_password(username, password):
    if username in users and users[username] == password:
        return username

@app.route('/api/disease/detect', methods=['POST'])
@auth.login_required
def detect_disease():
    # ... existing code
```

### Add Rate Limiting

```bash
pip install flask-limiter
```

```python
from flask_limiter import Limiter

limiter = Limiter(
    app,
    key_func=lambda: request.remote_addr,
    default_limits=["100 per hour"]
)

@app.route('/api/disease/detect', methods=['POST'])
@limiter.limit("10 per minute")
def detect_disease():
    # ... existing code
```

---

## ✅ Features Comparison

| Feature | Your Cow Weight API | New Disease API | Status |
|---------|-------------------|-----------------|--------|
| **Flask Backend** | ✅ | ✅ | Same framework |
| **Image Upload** | ✅ | ✅ | Same implementation |
| **Model Loading** | ✅ | ✅ | Enhanced (5 models) |
| **JSON Responses** | ✅ | ✅ | Same format |
| **Error Handling** | ✅ | ✅ | Improved |
| **Multiple Models** | 2 models | 5 models | ✅ More comprehensive |
| **Multimodal** | No | Yes | ✅ Visual+Behavioral+Clinical |
| **Complete Pipeline** | Weight only | Disease→Severity→Treatment | ✅ Full diagnosis |
| **Behavior Analysis** | No | Yes | ✅ Time-series support |
| **CORS Support** | No | Yes | ✅ Frontend-ready |
| **API Documentation** | No | Yes | ✅ Complete docs |
| **Test Client** | No | Yes | ✅ Automated testing |

---

## 📚 Documentation

- **API Docs**: See [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Model Testing**: See [TEST_RESULTS_SUMMARY.md](TEST_RESULTS_SUMMARY.md)
- **Workflow**: See [WORKFLOW_EXPLANATION.md](WORKFLOW_EXPLANATION.md)
- **Multimodal**: See [SUPERVISOR_RESPONSE.md](SUPERVISOR_RESPONSE.md)

---

## 🎉 Summary

You now have a **complete, production-ready API** that:

✅ Integrates **all 5 models** (YOLOv8s, YOLOv8x, DenseNet121, Severity, Treatment)  
✅ Provides **8 REST endpoints** for all functionality  
✅ Supports **multimodal analysis** (visual + behavioral + clinical)  
✅ Returns **JSON responses** (mobile/web friendly)  
✅ Handles **image uploads** (similar to your cow weight app)  
✅ Includes **complete documentation** and **test client**  
✅ Ready for **mobile app integration**  
✅ Deployable to **cloud platforms**  

**Your system is now API-ready for production use!** 🚀

---

**Questions?**
- Test endpoint: `http://localhost:5000/api/health`
- Check models: `http://localhost:5000/api/models/status`
- Run tests: `python api_test_client.py`
