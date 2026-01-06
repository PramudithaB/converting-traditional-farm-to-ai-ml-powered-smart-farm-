# AI-Powered Smart Farm Management System for Cattle

## Converting Traditional Farm to AI/ML Powered Smart Farm

**Final Year Research Project 2025/2026**

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [System Architecture](#system-architecture)
4. [Technology Stack](#technology-stack)
5. [Project Structure](#project-structure)
6. [Core Components](#core-components)
7. [Installation & Setup](#installation--setup)
8. [Running the System](#running-the-system)
9. [API Documentation](#api-documentation)
10. [Machine Learning Models](#machine-learning-models)
11. [Mobile Application](#mobile-application)
12. [Deployment](#deployment)
13. [Contributing](#contributing)
14. [License](#license)

---

## Project Overview

This Final Year Research Project focuses on modernizing traditional cattle farming through **Artificial Intelligence** and **Machine Learning** technologies. The system provides comprehensive farm management capabilities including automated feeding, disease detection, health monitoring, and market prediction.

### Problem Statement
Traditional cattle farming faces challenges in:
- Manual disease detection leading to late diagnosis
- Inefficient feed management and nutrition planning
- Unpredictable birth timing for cattle and poultry
- Lack of real-time milk market insights
- Limited data-driven decision making

### Objectives
- Automate cattle disease detection with 99%+ accuracy
- Provide AI-driven nutrition recommendations based on cattle health
- Predict animal births and egg hatching with high precision
- Enable real-time milk market price forecasting
- Create unified mobile application for farmers
- Implement comprehensive cattle identification system

---

## Key Features

| Feature | Description | Technology |
|---------|-------------|------------|
| **Disease Detection** | Multi-model AI disease detection (8 diseases) | DenseNet121 + YOLOv8x |
| **Behavior Analysis** | Cattle behavior monitoring (9 behaviors) | YOLOv8s + ML |
| **Video Analysis** | Complete video processing for disease/behavior | YOLO + Computer Vision |
| **Nutrition AI** | Personalized feed recommendations | ML Regression |
| **Birth Prediction** | Animal birth timing prediction | Neural Networks |
| **Egg Hatching** | Egg hatch probability forecasting | Random Forest + NN |
| **Market Prediction** | Milk market price forecasting | Time Series + ML |
| **Cow Identification** | Individual cattle recognition | YOLOv8 Detection |
| **Weight Detection** | Automated cattle weight estimation | CNN + Segmentation |
| **Mobile App** | Cross-platform farm management | Flutter |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                   Smart Farm AI Management System - Architecture                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                            MOBILE APPLICATION                             │   │
│  │                           (Flutter - Dart)                                │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │   │
│  │  │  Disease     │  │  Feeding     │  │  Birth/Egg   │  │  Market      │  │   │
│  │  │  Detection   │  │  Management  │  │  Prediction  │  │  Forecast    │  │   │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │   │
│  │         │                 │                 │                 │          │   │
│  │         └─────────────────┴─────────────────┴─────────────────┘          │   │
│  │                                   │                                       │   │
│  │                             ┌─────▼─────┐                                 │   │
│  │                             │   HTTP    │                                 │   │
│  │                             │  Client   │                                 │   │
│  │                             │  REST API │                                 │   │
│  │                             └─────┬─────┘                                 │   │
│  └───────────────────────────────────┼─────────────────────────────────────┘   │
│                             │               │                                    │
│                             │  INTERNET     │                                    │
│                             │               │                                    │
│  ┌──────────────────────────▼───────────────▼────────────────────────────────┐   │
│  │                         BACKEND MICROSERVICES                              │   │
│  │                              (Python Flask)                                │   │
│  │                                                                            │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  DISEASE DETECTION SERVICE (Port 5000)                              │   │   │
│  │  │  ┌─────────────────────┐  ┌─────────────────────┐                   │   │   │
│  │  │  │  DenseNet121        │  │  YOLOv8x Classifier │                   │   │   │
│  │  │  │  - 99.45% Accuracy  │  │  - 99% Accuracy     │                   │   │   │
│  │  │  │  - 8 Diseases       │  │  - Fast Detection   │                   │   │   │
│  │  │  └──────────┬──────────┘  └──────────┬──────────┘                   │   │   │
│  │  │             │                        │                              │   │   │
│  │  │  ┌──────────▼────────────────────────▼──────────┐                   │   │   │
│  │  │  │  Model Comparison & Selection Engine         │                   │   │   │
│  │  │  │  - Chooses highest confidence model          │                   │   │   │
│  │  │  │  - Returns optimal disease prediction        │                   │   │   │
│  │  │  └──────────────────────────────────────────────┘                   │   │   │
│  │  │  ┌─────────────────────┐  ┌─────────────────────┐                   │   │   │
│  │  │  │  Severity Analysis  │  │  Treatment AI       │                   │   │   │
│  │  │  │  Gradient Boosting  │  │  Gradient Boosting  │                   │   │   │
│  │  │  └─────────────────────┘  └─────────────────────┘                   │   │   │
│  │  │  ┌─────────────────────────────────────────────┐                    │   │   │
│  │  │  │  Behavior Detection (YOLOv8s)               │                    │   │   │
│  │  │  │  - Eating, Standing, Lying, Walking, etc.   │                    │   │   │
│  │  │  └─────────────────────────────────────────────┘                    │   │   │
│  │  │  ┌─────────────────────────────────────────────┐                    │   │   │
│  │  │  │  Video Analysis Engine                      │                    │   │   │
│  │  │  │  - Frame extraction & processing            │                    │   │   │
│  │  │  │  - Timeline-based detection                 │                    │   │   │
│  │  │  └─────────────────────────────────────────────┘                    │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                            │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  FEEDING & NUTRITION SERVICE                                        │   │   │
│  │  │  ┌─────────────────────┐  ┌─────────────────────┐                   │   │   │
│  │  │  │  Feed Calculator    │  │  Nutrition AI       │                   │   │   │
│  │  │  │  CNN Regression     │  │  ML Recommender     │                   │   │   │
│  │  │  │  - Weight Detection │  │  - 11 Parameters    │                   │   │   │
│  │  │  │  - Feed Amount      │  │  - Health-based     │                   │   │   │
│  │  │  └─────────────────────┘  └─────────────────────┘                   │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                            │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  PREDICTION SERVICES                                                │   │   │
│  │  │  ┌─────────────────────┐  ┌─────────────────────┐                   │   │   │
│  │  │  │  Birth Prediction   │  │  Egg Hatch          │                   │   │   │
│  │  │  │  Neural Network     │  │  Random Forest + NN │                   │   │   │
│  │  │  │  - Animal Birth     │  │  - Probability      │                   │   │   │
│  │  │  │  - Timing           │  │  - Temperature      │                   │   │   │
│  │  │  └─────────────────────┘  └─────────────────────┘                   │   │   │
│  │  │  ┌─────────────────────────────────────────────┐                    │   │   │
│  │  │  │  Market Prediction (Time Series ML)         │                    │   │   │
│  │  │  │  - Next month income (LKR)                  │                    │   │   │
│  │  │  │  - Price per liter forecast                 │                    │   │   │
│  │  │  │  - Price change prediction                  │                    │   │   │
│  │  │  └─────────────────────────────────────────────┘                    │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                            │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  COW IDENTIFICATION SERVICE                                         │   │   │
│  │  │  ┌─────────────────────────────────────────────┐                    │   │   │
│  │  │  │  YOLOv8 Object Detection                    │                    │   │   │
│  │  │  │  - Individual cattle recognition            │                    │   │   │
│  │  │  │  - ID tracking                              │                    │   │   │
│  │  │  └─────────────────────────────────────────────┘                    │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                            │   │
│  └────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                    │
│  ┌────────────────────────────────────────────────────────────────────────────┐   │
│  │                            LOCAL DATABASE                                   │   │
│  │                              (SQLite)                                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │   │
│  │  │    Cows     │  │   Breeds    │  │    Users    │  │   Records   │       │   │
│  │  │  Management │  │  Catalogue  │  │   & Auth    │  │  & History  │       │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │   │
│  └────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                    │
└────────────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Farmer     │────▶│    Mobile    │────▶│   Backend    │────▶│  AI Models   │
│   Input      │     │     App      │     │   Services   │     │  Processing  │
│  (Images)    │     │  (Flutter)   │     │   (Flask)    │     │ (ML/DL)      │
└──────────────┘     └──────────────┘     └──────────────┘     └──────┬───────┘
                            ▲                                           │
                            │                                           │
                            │         ┌──────────────┐                  │
                            └─────────│  Predictions │◀─────────────────┘
                                      │   Results    │
                                      │   Actions    │
                                      └──────────────┘
```

---

## Technology Stack

### Backend Services

| Component | Technology | Purpose |
|-----------|------------|---------|
| API Framework | Python Flask | REST API server |
| Deep Learning | TensorFlow + Keras | Neural network models |
| Computer Vision | Ultralytics YOLOv8 | Object detection |
| ML Models | Scikit-learn | Traditional ML |
| Image Processing | OpenCV | Computer vision |
| Data Processing | Pandas + NumPy | Data manipulation |
| Model Storage | Joblib | Model serialization |

### Frontend Application

| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | Flutter | Cross-platform mobile |
| Language | Dart | App development |
| State Management | Provider | State handling |
| Database | SQLite (Sqflite) | Local storage |
| HTTP Client | http package | API communication |
| Image Picker | image_picker | Camera/gallery access |
| UI Design | Material Design 3 | Modern UI |

### AI/ML Models

| Model | Architecture | Task | Accuracy |
|-------|--------------|------|----------|
| DenseNet121 | CNN | Disease Classification | 99.45% |
| YOLOv8x | Detection + Classification | Fast Disease Detection | 99% |
| YOLOv8s | Object Detection | Behavior Detection | 83-86% |
| YOLOv8 | Object Detection | Cow Identification | - |
| Gradient Boosting | Ensemble ML | Severity Prediction | - |
| Gradient Boosting | Ensemble ML | Treatment Recommendation | - |
| Neural Network | Deep Learning | Animal Birth Prediction | - |
| Random Forest + NN | Hybrid ML | Egg Hatch Prediction | - |
| Time Series ML | Regression | Market Prediction | - |
| CNN | Deep Learning | Weight Detection | - |

---

## Project Structure

```
converting-traditional-farm-to-ai-ml-powered-smart-farm/
│
├── backend/                         # Python Flask Backend Services
│   ├── app.py                       # Main unified API server
│   ├── requirements.txt             # Python dependencies
│   ├── start.sh / start.bat         # Startup scripts
│   │
│   ├── cattle_disease_detection/    # Disease Detection Service
│   │   ├── api_server.py            # Disease API server
│   │   ├── models/
│   │   │   ├── All_Cattle_Disease/  # YOLOv8x model
│   │   │   │   └── best.pt
│   │   │   ├── DenseNet121_Disease/ # DenseNet model
│   │   │   │   └── best_model.h5
│   │   │   ├── All_Behaviore/       # Behavior YOLOv8s
│   │   │   │   └── best.pt
│   │   │   ├── Treatment_Severity/  # ML models
│   │   │   └── Treatment_Recommendation/
│   │   ├── datasets/                # Training datasets
│   │   ├── cattels_images_videos/   # Test data
│   │   ├── API_DOCUMENTATION.md     # Complete API docs
│   │   ├── REALTIME_MODEL_COMPARISON.md
│   │   └── VIDEO_ANALYSIS_API.md
│   │
│   ├── cow_daily_feed/              # Feeding Management Service
│   │   ├── app.py                   # Feed API server
│   │   ├── models/
│   │   │   ├── best_reg_model.h5    # Regression model
│   │   │   └── best_seg_model.h5    # Segmentation model
│   │   └── requirements.txt
│   │
│   ├── nutrition_recommended/       # Nutrition AI Service
│   │   ├── app.py                   # Nutrition API server
│   │   ├── nutrition_dataset.csv    # Training data
│   │   └── requirements.txt
│   │
│   ├── animal_birth/                # Birth Prediction Service
│   │   ├── app.py                   # Birth API server
│   │   ├── animal_birth.ipynb       # Training notebook
│   │   └── requirements.txt
│   │
│   ├── egg_hatch/                   # Egg Hatch Prediction Service
│   │   ├── app.py                   # Hatch API server
│   │   ├── egg_hatch_nn.h5          # Neural network
│   │   ├── egg_hatch_rf_pipeline.joblib # Random Forest
│   │   └── requirements.txt
│   │
│   ├── milk_market_prediction/      # Market Prediction Service
│   │   ├── app.py                   # Market API server
│   │   ├── milk_market_dataset.csv  # Historical data
│   │   └── requirements.txt
│   │
│   └── cow_identify/                # Cow Identification Service
│       ├── app.py                   # ID API server
│       ├── best.pt                  # YOLOv8 model
│       └── requirements.txt
│
├── frontend/                        # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── db/
│   │   │   └── app_db.dart          # SQLite database
│   │   ├── models/                  # Data models
│   │   │   ├── cow.dart
│   │   │   ├── breed.dart
│   │   │   └── user.dart
│   │   ├── screens/                 # UI Screens
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── disease_detection_screen.dart
│   │   │   ├── model_comparison_screen.dart
│   │   │   ├── complete_disease_analysis_screen.dart
│   │   │   ├── behavior_detection_screen.dart
│   │   │   ├── video_analysis_screen.dart
│   │   │   ├── feed_screen.dart
│   │   │   ├── nutrition_screen.dart
│   │   │   ├── animal_birth_screen.dart
│   │   │   ├── hatching_screen.dart
│   │   │   ├── market_screen.dart
│   │   │   └── identico_screen.dart
│   │   └── services/
│   │       └── api_service.dart     # API client
│   ├── pubspec.yaml                 # Flutter dependencies
│   └── android/ios/web/...          # Platform configs
│
├── README.md                        # This file
├── INTEGRATION_COMPLETE.md          # Integration guide
└── .gitignore                       # Git ignore rules
```

---

## Core Components

### 1. Disease Detection & Emergency Alerts System

**Technologies:** DenseNet121 (99.45% accuracy) + YOLOv8x (99% accuracy)

#### Features:
- **Dual-Model Detection**: Compares DenseNet121 and YOLOv8x, selects highest confidence
- **8 Disease Categories**: Contagious, Dermatophilosis, FMD, Healthy, Lumpy Skin, Mastitis, Pediculosis, Ringworm
- **Severity Analysis**: AI-powered severity classification (Mild/Moderate/Severe)
- **Treatment Recommendations**: ML-based treatment suggestions with alternatives
- **Behavior Monitoring**: 9 behavior types (eating, standing, lying, walking, etc.)
- **Video Analysis**: Complete video processing with timeline-based detection
- **Real-time Detection**: <150ms inference time

#### API Endpoints:
```bash
POST /api/disease/detect              # Disease detection
POST /api/disease/analyze             # Complete analysis (disease + severity + treatment)
POST /api/quick-diagnosis             # Fast YOLO detection
POST /api/behavior/detect-from-video  # Behavior detection from image
POST /api/video/analyze               # Full video analysis
GET  /api/models/status               # Model health check
```

#### Mobile Screens:
- **Disease Detection**: Upload image, get highest confidence disease
- **Model Comparison**: Side-by-side comparison of both AI models
- **Complete Analysis**: Disease + Severity + Treatment in one screen
- **Behavior Detection**: Cattle behavior analysis with confidence scores
- **Video Analysis**: Upload videos for comprehensive analysis

---

### 2. Automated Feeding System & Nutrition Recommender

**Technologies:** CNN Regression + ML Recommender

#### Features:
- **Automated Weight Detection**: CNN-based weight estimation from images
- **Feed Calculator**: Calculates optimal feed amount based on weight, breed, age
- **Nutrition AI**: Personalized nutrition recommendations using 11 health parameters
- **Breed-Specific**: Tailored recommendations for different cattle breeds
- **Activity-Level Based**: Adjusts nutrition for activity levels (Low/Medium/High)
- **Health-Aware**: Factors in health status and diseases

#### API Endpoints:
```bash
POST /cow-feed/predict-image    # Weight detection from image
POST /cow-feed/predict-manual   # Manual feed calculation
POST /nutrition/predict         # AI nutrition recommendations
```

#### Parameters:
- **Feed**: Breed, Age, Weight, Milk Yield, Activity Level
- **Nutrition**: Age, Weight, Breed, Milk Yield, Health Status, Disease, Body Condition, Location, Energy needs, Protein needs

---

### 3. Animal Birth & Egg Hatch Prediction

**Technologies:** Neural Networks + Random Forest

#### Features:
- **Animal Birth Prediction**: ML-based birth timing prediction for cattle
- **Egg Hatch Prediction**: Hybrid model (NN + RF) for poultry egg hatching
- **Environmental Factors**: Temperature, humidity, duration tracking
- **Probability Scores**: Confidence levels for predictions
- **Early Warning**: Advance notifications for preparations

#### API Endpoints:
```bash
POST /animal-birth/predict    # Animal birth prediction
POST /egg-hatch/predict       # Egg hatch probability
```

#### Input Parameters:
- **Birth**: Gestation features, health indicators
- **Egg Hatch**: Temperature (°C), Humidity (%), Egg Weight (g), Turning Frequency, Incubation Duration (days)

---

### 4. Customized Live Milk Market Prediction with AI/ML

**Technologies:** Time Series ML + Regression

#### Features:
- **Price Forecasting**: Next month milk price prediction (LKR per liter)
- **Income Prediction**: Monthly income forecasting (LKR)
- **Price Change Analysis**: Price change trends (increase/decrease)
- **Multi-Factor Analysis**: Considers current price, production volume, quality (fat%, SNF%), disease stage, feed quality
- **Market Trends**: Historical data-driven predictions

#### API Endpoints:
```bash
POST /milk-market/predict-income    # Comprehensive market prediction
```

#### Output:
- Predicted next month income (LKR)
- Predicted price per liter (LKR)
- Price change forecast (LKR)

---

### 5. Cow Identification System

**Technologies:** YOLOv8 Object Detection

#### Features:
- **Individual Recognition**: Identifies specific cattle from images
- **ID Tracking**: Maintains database of identified cattle
- **Quick Detection**: Fast YOLOv8-based recognition

#### API Endpoints:
```bash
POST /cow-identify/detect    # Identify cattle from image
```

---

## Installation & Setup

### Prerequisites

- **Python** >= 3.9
- **Flutter** >= 3.9.2
- **pip** (Python package manager)
- **Git**

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/converting-traditional-farm-to-ai-ml-powered-smart-farm-.git
cd converting-traditional-farm-to-ai-ml-powered-smart-farm-
```

### 2. Backend Setup

#### Install Python Dependencies

```bash
cd backend

# Create virtual environment (recommended)
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install service-specific dependencies
cd cattle_disease_detection && pip install -r requirements.txt && cd ..
cd cow_daily_feed && pip install -r requirements.txt && cd ..
cd nutrition_recommended && pip install -r requirements.txt && cd ..
cd animal_birth && pip install -r requirements.txt && cd ..
cd egg_hatch && pip install -r requirements.txt && cd ..
cd milk_market_prediction && pip install -r requirements.txt && cd ..
cd cow_identify && pip install -r requirements.txt && cd ..
```

#### Download ML Models

```bash
# Models should be placed in their respective directories:
# - cattle_disease_detection/models/
# - cow_daily_feed/models/
# - cow_identify/best.pt
# - egg_hatch/*.h5, *.joblib
```

### 3. Frontend Setup

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# For Android
flutter doctor --android-licenses

# Run the app
flutter run
```

---

## Running the System

### Option 1: Unified Backend (Recommended)

```bash
cd backend

# Windows
start.bat

# Linux/Mac
./start.sh

# Or manually
python app.py
```

This starts all services on port 5000 with a unified API.

### Option 2: Individual Services

```bash
# Terminal 1 - Disease Detection
cd backend/cattle_disease_detection
python api_server.py

# Terminal 2 - Feeding System
cd backend/cow_daily_feed
python app.py

# Terminal 3 - Nutrition
cd backend/nutrition_recommended
python app.py

# Terminal 4 - Birth Prediction
cd backend/animal_birth
python app.py

# Terminal 5 - Egg Hatch
cd backend/egg_hatch
python app.py

# Terminal 6 - Market Prediction
cd backend/milk_market_prediction
python app.py

# Terminal 7 - Cow Identification
cd backend/cow_identify
python app.py
```

### Frontend (Mobile App)

```bash
cd frontend

# Run on Android emulator
flutter run

# Run on physical device
flutter run -d <device-id>

# Build APK
flutter build apk --release

# Build iOS (Mac only)
flutter build ios --release
```

---

## API Documentation

### Base URLs

```
Unified API: http://localhost:5000
Disease Detection: http://localhost:5000/api
Feeding: http://localhost:5000/cow-feed
Nutrition: http://localhost:5000/nutrition
Birth: http://localhost:5000/animal-birth
Egg Hatch: http://localhost:5000/egg-hatch
Market: http://localhost:5000/milk-market
Cow ID: http://localhost:5000/cow-identify
```

### Example Requests

#### Disease Detection

```bash
curl -X POST http://localhost:5000/api/disease/detect \
  -F "image=@cattle_image.jpg" \
  -F "use_yolo=true"
```

#### Complete Disease Analysis

```bash
curl -X POST http://localhost:5000/api/disease/analyze \
  -F "image=@cattle_image.jpg" \
  -F "weight=450" \
  -F "age=40" \
  -F "temperature=39.5"
```

#### Video Analysis

```bash
curl -X POST http://localhost:5000/api/video/analyze \
  -F "video=@cattle_video.mp4" \
  -F "frame_interval=30" \
  -F "detect_disease=true" \
  -F "detect_behavior=true"
```

#### Nutrition Recommendation

```bash
curl -X POST http://localhost:5000/nutrition/predict \
  -H "Content-Type: application/json" \
  -d '{
    "Age_Months": 36,
    "Weight_kg": 450,
    "Breed": "Jersey",
    "Milk_Yield_L_per_day": 15,
    "Health_Status": "Healthy",
    "Disease": "None",
    "Body_Condition_Score": 3.0,
    "Location": "Colombo",
    "Energy_MJ_per_day": 120,
    "Crude_Protein_g_per_day": 1500,
    "Recommended_Feed_Type": "Concentrate"
  }'
```

#### Market Prediction

```bash
curl -X POST http://localhost:5000/milk-market/predict-income \
  -H "Content-Type: application/json" \
  -d '{
    "current_price": 100,
    "monthly_milk_litres": 3000,
    "fat_percentage": 3.8,
    "snf_percentage": 8.5,
    "disease_stage": 0,
    "feed_quality": 2,
    "lactation_month": 6,
    "month": 1
  }'
```

### Postman Collection

Import `Smart Farm AI Backend - Unified API.postman_collection.json` for complete API testing.

---

## Machine Learning Models

### Model Performance Summary

| Model | Task | Accuracy | Speed | Size |
|-------|------|----------|-------|------|
| DenseNet121 | Disease Classification | 99.45% | 5-10 FPS | ~50-100MB |
| YOLOv8x | Disease Detection | 99% | 10-20 FPS | 107MB |
| YOLOv8s | Behavior Detection | 83-86% | 30-60 FPS | 21MB |
| Gradient Boosting | Severity Prediction | - | Fast | ~10MB |
| Gradient Boosting | Treatment Recommendation | - | Fast | ~10MB |

### Training Details

All models are trained on custom datasets:
- **Disease**: 491 cattle disease images (8 classes)
- **Behavior**: 78+ behavior images (9 classes)
- **Severity**: Clinical health records
- **Treatment**: Treatment outcome data
- **Market**: Historical milk market data

### Model Selection Logic

The system uses intelligent model selection:
1. Runs both DenseNet121 and YOLOv8x
2. Compares confidence scores
3. Selects highest confidence prediction
4. Returns winning model and result

---

## Mobile Application

### Features

| Screen | Functionality |
|--------|--------------|
| **Dashboard** | Overview of all farm operations |
| **Disease Detection** | Upload images for disease diagnosis |
| **Model Comparison** | Compare DenseNet vs YOLO results |
| **Complete Analysis** | Disease + Severity + Treatment |
| **Behavior Detection** | Analyze cattle behavior patterns |
| **Video Analysis** | Full video processing |
| **Feed Calculator** | Automated feed recommendations |
| **Nutrition Advisor** | AI-powered nutrition planning |
| **Birth Prediction** | Predict animal birth timing |
| **Egg Hatching** | Egg hatch probability |
| **Market Predictor** | Milk price forecasting |
| **Cow Identifier** | Individual cattle recognition |

### Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

### Screenshots

```
[Dashboard] [Disease Detection] [Video Analysis] [Market Prediction]
```

---

## Deployment

### Backend Deployment

#### Option 1: Cloud Platform (Render/Railway)

```bash
# Deploy using Docker
docker build -t smart-farm-backend .
docker run -p 5000:5000 smart-farm-backend
```

#### Option 2: Local Server

```bash
# Install as system service (Linux)
sudo cp smart-farm.service /etc/systemd/system/
sudo systemctl enable smart-farm
sudo systemctl start smart-farm
```

### Frontend Deployment

#### Android

```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS

```bash
flutter build ios --release
# Build in Xcode
```

#### Web

```bash
flutter build web --release
# Deploy build/web/ to hosting service
```

---

## Performance Metrics

### API Response Times

| Endpoint | Average Response Time |
|----------|----------------------|
| Disease Detection | 150ms |
| Video Analysis | 10-30s (depends on video length) |
| Behavior Detection | 30ms |
| Feed Calculation | 50ms |
| Market Prediction | 100ms |

### Model Inference Times

| Model | Inference Time |
|-------|----------------|
| DenseNet121 | 100-200ms |
| YOLOv8x | 50-100ms |
| YOLOv8s | 30-50ms |

---

## Troubleshooting

### Common Issues

#### Backend won't start
```bash
# Check Python version
python --version  # Should be >= 3.9

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Check port availability
netstat -ano | findstr :5000  # Windows
lsof -i :5000  # Linux/Mac
```

#### Models not loading
```bash
# Verify model files exist
ls -la backend/cattle_disease_detection/models/

# Check TensorFlow installation
python -c "import tensorflow as tf; print(tf.__version__)"

# Check PyTorch installation
python -c "import torch; print(torch.__version__)"
```

#### Flutter build fails
```bash
# Clean build
flutter clean
flutter pub get

# Update Flutter
flutter upgrade

# Fix Android licenses
flutter doctor --android-licenses
```

### API Connection Issues

```dart
// Update baseUrl in api_service.dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:5000';

// For physical device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.100:5000';
```

---

## Contributing

This is a Final Year Research Project. Contributions are welcome for improvements and bug fixes.

### Development Workflow

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Create Pull Request

### Code Style

- **Python**: Follow PEP 8
- **Dart**: Follow Effective Dart guidelines
- **Comments**: Document complex logic
- **Commits**: Use conventional commits

---

## Future Enhancements

- [ ] Real-time notification system
- [ ] Cloud storage for cattle records
- [ ] Multi-language support
- [ ] Offline mode improvements
- [ ] Advanced analytics dashboard
- [ ] Integration with IoT sensors
- [ ] Automated report generation
- [ ] Farm management planning tools

---

## License

This project is developed as part of a Final Year Research Project. All rights reserved.

---

## Acknowledgments

- **TensorFlow & Keras** for deep learning framework
- **Ultralytics** for YOLOv8 models
- **Flutter** team for cross-platform framework
- **OpenCV** for computer vision tools
- **Scikit-learn** for machine learning algorithms
- Agricultural domain experts for guidance
- Open source community for amazing tools

---

## Contact

For queries regarding this project, please open an issue in the repository.

**Repository:** [Converting Traditional Farm to AI/ML Powered Smart Farm](https://github.com/PramudithaB/converting-traditional-farm-to-ai-ml-powered-smart-farm-)

---

**© 2025-2026 | AI-Powered Smart Farm Management System**
