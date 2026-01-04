# API Endpoint Migration Guide

## Overview
All backend components have been unified to run on **port 5000** with descriptive endpoint names.

## Endpoint Changes

### Before (Old) → After (New)

| Component | Old Endpoint | New Endpoint | Port Change |
|-----------|-------------|--------------|-------------|
| Animal Birth | `/predict` | `/animal-birth/predict` | Any → 5000 |
| Cow Identification | `/predict` | `/cow-identify/detect` | 5000 → 5000 |
| Cow Daily Feed (Image) | `/predict` | `/cow-feed/predict-from-image` | 5000 → 5000 |
| Cow Daily Feed (Manual) | `/predict_manual` | `/cow-feed/predict-manual` | 5000 → 5000 |
| Egg Hatch | `/predict` | `/egg-hatch/predict` | Any → 5000 |
| Milk Market | `/predict-income` | `/milk-market/predict-income` | 5000 → 5000 |
| Nutrition | `/predict` | `/nutrition/predict` | 5000 → 5000 |

## Base URL
**All endpoints now use:** `http://localhost:5000`

## Frontend Updates Required

Update your frontend API calls from:

### Animal Birth
```javascript
// OLD
fetch('http://localhost:XXXX/predict', {...})

// NEW
fetch('http://localhost:5000/animal-birth/predict', {...})
```

### Cow Identification
```javascript
// OLD
fetch('http://localhost:5000/predict', {...})

// NEW
fetch('http://localhost:5000/cow-identify/detect', {...})
```

### Cow Daily Feed (Image)
```javascript
// OLD
fetch('http://localhost:5000/predict', {...})

// NEW
fetch('http://localhost:5000/cow-feed/predict-from-image', {...})
```

### Cow Daily Feed (Manual)
```javascript
// OLD
fetch('http://localhost:5000/predict_manual', {...})

// NEW
fetch('http://localhost:5000/cow-feed/predict-manual', {...})
```

### Egg Hatch
```javascript
// OLD
fetch('http://localhost:XXXX/predict', {...})

// NEW
fetch('http://localhost:5000/egg-hatch/predict', {...})
```

### Milk Market
```javascript
// OLD
fetch('http://localhost:5000/predict-income', {...})

// NEW
fetch('http://localhost:5000/milk-market/predict-income', {...})
```

### Nutrition
```javascript
// OLD
fetch('http://localhost:5000/predict', {...})

// NEW
fetch('http://localhost:5000/nutrition/predict', {...})
```

## Benefits of New Structure

1. **Single Port**: All services run on port 5000 - no more port conflicts
2. **Clear Naming**: Endpoint names clearly indicate which service they belong to
3. **Easy Maintenance**: Update one server instead of managing multiple services
4. **Better Organization**: RESTful naming convention improves API discoverability
5. **Flexible Deployment**: Can still run individual services if needed

## Request/Response Format

**All request and response formats remain unchanged!** Only the endpoint URLs have changed.

## Running the Server

### Unified Server (Recommended)
```bash
cd backend
python app.py
```

### Individual Services (Still Supported)
```bash
cd backend/animal_birth
python app.py
```

## Health Check

Test all services are running:
```bash
curl http://localhost:5000/health
```

## Migration Checklist

- [ ] Update frontend API endpoint URLs
- [ ] Update base URL to `http://localhost:5000`
- [ ] Test each endpoint with existing request payloads
- [ ] Update any API documentation
- [ ] Update environment configuration files
- [ ] Test error handling with new endpoints

## Backward Compatibility

Individual service files (e.g., `animal_birth/app.py`) have also been updated with the new endpoint names. You can still run them individually if needed, but they will all use port 5000.

**Important**: Only one service can run on port 5000 at a time. Use the unified server (`backend/app.py`) to run all services together.
