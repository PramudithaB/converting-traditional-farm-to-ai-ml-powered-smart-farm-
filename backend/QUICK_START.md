# 🚀 Quick Start Guide - Smart Farm Backend

## Installation (One-time setup)

### Windows
```bash
cd backend
start.bat
```

### Linux/Mac
```bash
cd backend
chmod +x start.sh
./start.sh
```

## Manual Setup

```bash
cd backend
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

## Server URL
```
http://localhost:5000
```

## Quick API Test

### Health Check
```bash
curl http://localhost:5000/health
```

### Test Animal Birth Prediction
```bash
curl -X POST http://localhost:5000/animal-birth/predict ^
  -H "Content-Type: application/json" ^
  -d "{\"features\": [1, 2, 3, 4, 5]}"
```

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | API Info |
| `/health` | GET | Health Check |
| `/animal-birth/predict` | POST | Predict animal birth |
| `/cow-identify/detect` | POST | Identify cows |
| `/cow-feed/predict-from-image` | POST | Feed calc (image) |
| `/cow-feed/predict-manual` | POST | Feed calc (manual) |
| `/egg-hatch/predict` | POST | Predict egg hatch |
| `/milk-market/predict-income` | POST | Predict milk price |
| `/nutrition/predict` | POST | Nutrition recommendation |
| `/api/health` | GET | Cattle disease health |
| `/api/models/status` | GET | Cattle models status |
| `/api/disease/detect` | POST | Disease detection |
| `/api/disease/analyze` | POST | Complete analysis ⭐ |
| `/api/quick-diagnosis` | POST | Quick YOLO diagnosis |
| `/api/behavior/snapshot` | POST | Save behavior data |
| `/api/behavior/analyze/<cow_id>` | GET | Analyze behavior |
| `/api/behavior/detect-from-video` | POST | Detect from frame |
| `/api/video/analyze` | POST | Analyze video file 🎥 |

## Stopping the Server
Press `Ctrl+C` in the terminal

## Troubleshooting

### Port 5000 already in use
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :5000
kill -9 <PID>
```

### Module not found
```bash
pip install -r requirements.txt --force-reinstall
```

### Model not loading
1. Check model files exist in their folders
2. Verify model file names match code
3. Check console output for specific errors

## File Structure
```
backend/
├── app.py              ⭐ Main unified server
├── requirements.txt    ⭐ All dependencies
├── start.bat          ⭐ Windows quick start
├── start.sh           ⭐ Linux/Mac quick start
├── README.md          📖 Full documentation
├── API_MIGRATION_GUIDE.md  📖 API changes
└── [component folders with models]
```

## Next Steps

1. ✅ Install dependencies
2. ✅ Start the server
3. ✅ Test with `/health` endpoint
4. ✅ Update frontend API URLs
5. ✅ Test each endpoint
6. ✅ Deploy to production

## Production Deployment

```bash
# Install production server
pip install gunicorn

# Run with Gunicorn (4 workers)
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Support
- 📖 See [README.md](README.md) for detailed documentation
- 📖 See [API_MIGRATION_GUIDE.md](API_MIGRATION_GUIDE.md) for API changes
- 📮 Import `Smart_Farm_API.postman_collection.json` to Postman for easy testing
