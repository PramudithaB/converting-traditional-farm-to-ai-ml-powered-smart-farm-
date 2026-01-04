"""
🐄 CATTLE DISEASE DETECTION API SERVER
======================================
Complete Flask API Backend for Multimodal Disease Diagnosis System

Endpoints:
1. POST /api/disease/detect - Disease detection from image
2. POST /api/disease/analyze - Complete analysis (disease + severity + treatment)
3. POST /api/behavior/snapshot - Save behavior data
4. GET /api/behavior/analyze/<cow_id> - Analyze behavior patterns
5. POST /api/quick-diagnosis - Fast YOLO-based diagnosis
6. GET /api/health - Health check
7. GET /api/models/status - Check all models status

Author: Production API System
Date: January 2, 2026
Version: 1.0
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import backend as K
import numpy as np
import pandas as pd
import joblib
import os
import cv2
from datetime import datetime
import json
import warnings
warnings.filterwarnings('ignore')

# Import behavior system
try:
    from behavior_data_manager import BehaviorDataCollector, BehaviorAnalyzer
    BEHAVIOR_AVAILABLE = True
except ImportError:
    BEHAVIOR_AVAILABLE = False

# Import YOLO
try:
    from ultralytics import YOLO
    YOLO_AVAILABLE = True
except ImportError:
    YOLO_AVAILABLE = False

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend access

# ============================================================================
# CONFIGURATION
# ============================================================================

class APIConfig:
    """API Configuration"""
    
    # Model paths
    DENSENET_MODEL = "models/DenseNet121_Disease/best_model.h5"
    YOLO_DISEASE_MODEL = "models/All_Cattle_Disease/best.pt"
    YOLO_BEHAVIOR_MODEL = "models/All_Behaviore/best.pt"
    
    SEVERITY_MODEL = "models/Treatment_Severity/best_model_gradient_boosting.pkl"
    SEVERITY_SCALER = "models/Treatment_Severity/scaler.pkl"
    SEVERITY_ENCODERS = "models/Treatment_Severity/label_encoders.pkl"
    
    TREATMENT_MODEL = "models/Treatment_Recommendation/best_model_gradient_boosting.pkl"
    TREATMENT_SCALER = "models/Treatment_Recommendation/scaler.pkl"
    TREATMENT_ENCODERS = "models/Treatment_Recommendation/label_encoders.pkl"
    
    # Image settings
    IMG_SIZE = (224, 224)
    UPLOAD_FOLDER = "uploads"
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
    ALLOWED_VIDEO_EXTENSIONS = {'mp4', 'avi', 'mov', 'mkv', 'webm'}
    
    # Disease categories
    DISEASE_CLASSES = [
        'Contagious', 'Dermatophilosis', 'FMD', 'Healthy',
        'Lumpy Skin', 'Mastitis', 'Pediculosis', 'Ringworm'
    ]
    
    SEVERITY_CLASSES = ['Mild', 'Moderate', 'Severe']

# Create upload folder
os.makedirs(APIConfig.UPLOAD_FOLDER, exist_ok=True)

# ============================================================================
# MODEL LOADER
# ============================================================================

class ModelLoader:
    """Load and manage all models"""
    
    def __init__(self):
        self.densenet_model = None
        self.yolo_disease_model = None
        self.yolo_behavior_model = None
        self.severity_model = None
        self.severity_scaler = None
        self.severity_encoders = None
        self.treatment_model = None
        self.treatment_scaler = None
        self.treatment_encoders = None
        self.behavior_collector = None
        self.behavior_analyzer = None
        
        self.models_loaded = False
    
    def load_all_models(self):
        """Load all models at startup"""
        print("\n🔄 Loading models...")
        
        try:
            # Load DenseNet121
            if os.path.exists(APIConfig.DENSENET_MODEL):
                self.densenet_model = keras.models.load_model(APIConfig.DENSENET_MODEL)
                print("✅ DenseNet121 loaded")
            else:
                print("⚠️ DenseNet121 not found")
            
            # Load YOLO models
            if YOLO_AVAILABLE:
                if os.path.exists(APIConfig.YOLO_DISEASE_MODEL):
                    self.yolo_disease_model = YOLO(APIConfig.YOLO_DISEASE_MODEL)
                    print("✅ YOLOv8x Disease model loaded")
                else:
                    print("⚠️ YOLO Disease model not found")
                
                if os.path.exists(APIConfig.YOLO_BEHAVIOR_MODEL):
                    self.yolo_behavior_model = YOLO(APIConfig.YOLO_BEHAVIOR_MODEL)
                    print("✅ YOLOv8s Behavior model loaded")
                else:
                    print("⚠️ YOLO Behavior model not found")
            else:
                print("⚠️ Ultralytics not installed")
            
            # Load Severity model
            if os.path.exists(APIConfig.SEVERITY_MODEL):
                self.severity_model = joblib.load(APIConfig.SEVERITY_MODEL)
                self.severity_scaler = joblib.load(APIConfig.SEVERITY_SCALER)
                self.severity_encoders = joblib.load(APIConfig.SEVERITY_ENCODERS)
                print("✅ Severity model loaded")
            else:
                print("⚠️ Severity model not found")
            
            # Load Treatment model
            if os.path.exists(APIConfig.TREATMENT_MODEL):
                self.treatment_model = joblib.load(APIConfig.TREATMENT_MODEL)
                self.treatment_scaler = joblib.load(APIConfig.TREATMENT_SCALER)
                self.treatment_encoders = joblib.load(APIConfig.TREATMENT_ENCODERS)
                print("✅ Treatment model loaded")
            else:
                print("⚠️ Treatment model not found")
            
            # Load Behavior system
            if BEHAVIOR_AVAILABLE:
                self.behavior_collector = BehaviorDataCollector()
                self.behavior_analyzer = BehaviorAnalyzer(self.behavior_collector)
                print("✅ Behavior system loaded")
            else:
                print("⚠️ Behavior system not available")
            
            self.models_loaded = True
            print("✅ All available models loaded successfully!\n")
            
        except Exception as e:
            print(f"❌ Error loading models: {str(e)}")
            self.models_loaded = False

# Initialize model loader
model_loader = ModelLoader()

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in APIConfig.ALLOWED_EXTENSIONS

def allowed_video_file(filename):
    """Check if video file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in APIConfig.ALLOWED_VIDEO_EXTENSIONS

def process_image_for_densenet(img_path):
    """Process image for DenseNet121"""
    img = cv2.imread(img_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, APIConfig.IMG_SIZE)
    img_array = np.expand_dims(img, axis=0)
    img_array = img_array / 255.0
    return img_array

def save_uploaded_file(file):
    """Save uploaded file and return path"""
    if file and allowed_file(file.filename):
        filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
        filepath = os.path.join(APIConfig.UPLOAD_FOLDER, filename)
        file.save(filepath)
        return filepath
    return None

def save_uploaded_video(file):
    """Save uploaded video file and return path"""
    if file and allowed_video_file(file.filename):
        filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
        filepath = os.path.join(APIConfig.UPLOAD_FOLDER, filename)
        file.save(filepath)
        return filepath
    return None

def process_video_frames(video_path, frame_interval=30):
    """
    Extract frames from video at specified interval
    
    Args:
        video_path: Path to video file
        frame_interval: Extract 1 frame every N frames (default: 30 = ~1 per second at 30fps)
    
    Returns:
        List of frame arrays (RGB format)
    """
    frames = []
    cap = cv2.VideoCapture(video_path)
    
    if not cap.isOpened():
        return None
    
    frame_count = 0
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Extract frame at interval
        if frame_count % frame_interval == 0:
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frames.append(frame_rgb)
        
        frame_count += 1
    
    cap.release()
    
    return {
        'frames': frames,
        'total_frames': total_frames,
        'fps': fps,
        'duration': total_frames / fps if fps > 0 else 0,
        'extracted_frames': len(frames)
    }

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'models_loaded': model_loader.models_loaded,
        'version': '1.0'
    })

@app.route('/api/models/status', methods=['GET'])
def models_status():
    """Check status of all models"""
    return jsonify({
        'densenet121': model_loader.densenet_model is not None,
        'yolo_disease': model_loader.yolo_disease_model is not None,
        'yolo_behavior': model_loader.yolo_behavior_model is not None,
        'severity_model': model_loader.severity_model is not None,
        'treatment_model': model_loader.treatment_model is not None,
        'behavior_system': BEHAVIOR_AVAILABLE,
        'ultralytics': YOLO_AVAILABLE
    })

@app.route('/api/disease/detect', methods=['POST'])
def detect_disease():
    """
    Detect disease from uploaded image using DenseNet121
    
    Request:
        - image: Image file
        - use_yolo: Optional, use YOLO for fast detection
    
    Response:
        - disease: Detected disease name
        - confidence: Confidence score
        - all_predictions: All class probabilities
    """
    try:
        # Check if image uploaded
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        use_yolo = request.form.get('use_yolo', 'false').lower() == 'true'
        
        # Save file
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        result = {}
        
        # YOLO Detection (fast)
        if use_yolo and model_loader.yolo_disease_model:
            yolo_results = model_loader.yolo_disease_model(filepath, verbose=False)[0]
            
            if hasattr(yolo_results, 'probs') and yolo_results.probs is not None:
                top_class_id = int(yolo_results.probs.top1)
                top_confidence = float(yolo_results.probs.top1conf)
                predicted_class = model_loader.yolo_disease_model.names[top_class_id]
                
                result['yolo'] = {
                    'disease': predicted_class,
                    'confidence': round(top_confidence, 4)
                }
        
        # DenseNet121 Detection (accurate)
        if model_loader.densenet_model:
            img_array = process_image_for_densenet(filepath)
            predictions = model_loader.densenet_model.predict(img_array, verbose=0)[0]
            
            top_class_id = int(np.argmax(predictions))
            top_confidence = float(predictions[top_class_id])
            predicted_disease = APIConfig.DISEASE_CLASSES[top_class_id]
            
            # Get all predictions
            all_predictions = {
                APIConfig.DISEASE_CLASSES[i]: round(float(predictions[i]), 4)
                for i in range(len(predictions))
            }
            
            result['densenet'] = {
                'disease': predicted_disease,
                'confidence': round(top_confidence, 4),
                'all_predictions': all_predictions
            }
        
        # Clean up
        os.remove(filepath)
        
        # Determine final result
        if 'densenet' in result:
            result['recommended'] = 'densenet'
            result['disease'] = result['densenet']['disease']
            result['confidence'] = result['densenet']['confidence']
        elif 'yolo' in result:
            result['recommended'] = 'yolo'
            result['disease'] = result['yolo']['disease']
            result['confidence'] = result['yolo']['confidence']
        else:
            return jsonify({'error': 'No models available'}), 500
        
        result['timestamp'] = datetime.now().isoformat()
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/disease/analyze', methods=['POST'])
def analyze_complete():
    """
    Complete disease analysis: Detection + Severity + Treatment
    
    Request:
        - image: Image file
        - weight: Cow weight (kg)
        - age: Cow age (months)
        - temperature: Body temperature (°C)
        - previous_disease: Optional previous disease
    
    Response:
        - disease: Detected disease
        - severity: Severity level (Mild/Moderate/Severe)
        - treatment: Recommended treatment
        - confidence: Confidence scores
    """
    try:
        # Check if image uploaded
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        
        # Get clinical data
        weight = float(request.form.get('weight', 450))
        age = float(request.form.get('age', 40))
        temperature = float(request.form.get('temperature', 38.5))
        previous_disease = request.form.get('previous_disease', None)
        
        # Save file
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        result = {}
        
        # Step 1: Disease Detection
        img_array = process_image_for_densenet(filepath)
        predictions = model_loader.densenet_model.predict(img_array, verbose=0)[0]
        
        top_class_id = int(np.argmax(predictions))
        disease_confidence = float(predictions[top_class_id])
        detected_disease = APIConfig.DISEASE_CLASSES[top_class_id]
        
        result['disease'] = {
            'name': detected_disease,
            'confidence': round(disease_confidence, 4)
        }
        
        # If healthy, no need for severity/treatment
        if detected_disease.lower() == 'healthy':
            result['severity'] = {'level': 'None', 'confidence': 1.0}
            result['treatment'] = {'recommendation': 'No treatment needed', 'confidence': 1.0}
            result['message'] = 'Cow is healthy!'
            os.remove(filepath)
            return jsonify(result)
        
        # Step 2: Severity Assessment
        if model_loader.severity_model:
            # Encode disease
            disease_encoded = model_loader.severity_encoders['Disease'].transform([detected_disease])[0]
            
            # Encode previous disease
            if previous_disease and previous_disease != 'None':
                try:
                    prev_disease_encoded = model_loader.severity_encoders['Previous_Disease'].transform([previous_disease])[0]
                except:
                    prev_disease_encoded = 0
            else:
                prev_disease_encoded = 0
            
            # Calculate features
            temp_deviation = temperature - 38.5
            weight_age_ratio = weight / (age + 1)
            has_history = 1 if prev_disease_encoded > 0 else 0
            
            # Prepare features
            severity_features = np.array([[
                disease_encoded,
                weight,
                age,
                temperature,
                prev_disease_encoded,
                temp_deviation,
                weight_age_ratio,
                has_history
            ]])
            
            # Predict severity
            severity_features_scaled = model_loader.severity_scaler.transform(severity_features)
            severity_level = model_loader.severity_model.predict(severity_features_scaled)[0]
            severity_proba = model_loader.severity_model.predict_proba(severity_features_scaled)[0]
            severity_confidence = severity_proba[severity_level]
            
            severity_name = APIConfig.SEVERITY_CLASSES[severity_level]
            
            result['severity'] = {
                'level': severity_name,
                'confidence': round(float(severity_confidence), 4),
                'probabilities': {
                    'Mild': round(float(severity_proba[0]), 4),
                    'Moderate': round(float(severity_proba[1]), 4),
                    'Severe': round(float(severity_proba[2]), 4)
                }
            }
            
            # Step 3: Treatment Recommendation
            if model_loader.treatment_model:
                # Encode for treatment model
                disease_encoded_treat = model_loader.treatment_encoders['Disease'].transform([detected_disease])[0]
                
                if previous_disease and previous_disease != 'None':
                    try:
                        prev_disease_encoded_treat = model_loader.treatment_encoders['Previous_Disease'].transform([previous_disease])[0]
                    except:
                        prev_disease_encoded_treat = 0
                else:
                    prev_disease_encoded_treat = 0
                
                severity_temp_interaction = severity_level * temp_deviation
                
                treatment_features = np.array([[
                    disease_encoded_treat,
                    severity_level,
                    weight,
                    age,
                    temperature,
                    prev_disease_encoded_treat,
                    temp_deviation,
                    weight_age_ratio,
                    has_history,
                    severity_temp_interaction
                ]])
                
                # Predict treatment
                treatment_features_scaled = model_loader.treatment_scaler.transform(treatment_features)
                treatment_idx = model_loader.treatment_model.predict(treatment_features_scaled)[0]
                treatment_proba = model_loader.treatment_model.predict_proba(treatment_features_scaled)[0]
                
                treatment_name = model_loader.treatment_encoders['Treatment'].classes_[treatment_idx]
                treatment_confidence = treatment_proba[treatment_idx]
                
                # Get top 3 treatments
                top3_indices = np.argsort(treatment_proba)[-3:][::-1]
                top3_treatments = [
                    {
                        'treatment': model_loader.treatment_encoders['Treatment'].classes_[idx],
                        'probability': round(float(treatment_proba[idx]), 4)
                    }
                    for idx in top3_indices
                ]
                
                result['treatment'] = {
                    'primary': treatment_name,
                    'confidence': round(float(treatment_confidence), 4),
                    'alternatives': top3_treatments
                }
        
        # Clean up
        os.remove(filepath)
        
        result['timestamp'] = datetime.now().isoformat()
        result['clinical_data'] = {
            'weight': weight,
            'age': age,
            'temperature': temperature,
            'previous_disease': previous_disease
        }
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/quick-diagnosis', methods=['POST'])
def quick_diagnosis():
    """
    Fast diagnosis using YOLO only
    
    Request:
        - image: Image file
    
    Response:
        - disease: Detected disease
        - confidence: Confidence score
        - top3: Top 3 predictions
    """
    try:
        if not YOLO_AVAILABLE or not model_loader.yolo_disease_model:
            return jsonify({'error': 'YOLO model not available'}), 500
        
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        # YOLO prediction
        results = model_loader.yolo_disease_model(filepath, verbose=False)[0]
        
        if hasattr(results, 'probs') and results.probs is not None:
            top_class_id = int(results.probs.top1)
            top_confidence = float(results.probs.top1conf)
            predicted_class = model_loader.yolo_disease_model.names[top_class_id]
            
            # Get top 3
            top5_indices = results.probs.top5
            top5_conf = results.probs.top5conf
            
            top3 = []
            for i in range(min(3, len(top5_indices))):
                cls_name = model_loader.yolo_disease_model.names[top5_indices[i]]
                conf = float(top5_conf[i])
                top3.append({'disease': cls_name, 'confidence': round(conf, 4)})
            
            result = {
                'disease': predicted_class,
                'confidence': round(top_confidence, 4),
                'top3': top3,
                'model': 'YOLOv8x-Classifier',
                'timestamp': datetime.now().isoformat()
            }
            
            os.remove(filepath)
            return jsonify(result)
        else:
            os.remove(filepath)
            return jsonify({'error': 'No predictions from YOLO'}), 500
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/behavior/snapshot', methods=['POST'])
def save_behavior_snapshot():
    """
    Save behavior snapshot
    
    Request JSON:
        - cow_id: Cow identifier
        - eating_time: Eating time per hour (minutes)
        - lying_time: Lying time per hour (0-1)
        - steps: Steps per hour
        - rumination_time: Rumination time per hour (minutes)
        - temperature: Body temperature (°C)
    
    Response:
        - snapshot_id: ID of saved snapshot
        - message: Success message
    """
    try:
        if not BEHAVIOR_AVAILABLE or not model_loader.behavior_collector:
            return jsonify({'error': 'Behavior system not available'}), 500
        
        data = request.get_json()
        
        cow_id = data.get('cow_id')
        eating_time = float(data.get('eating_time', 0))
        lying_time = float(data.get('lying_time', 0))
        steps = int(data.get('steps', 0))
        rumination_time = float(data.get('rumination_time', 0))
        temperature = float(data.get('temperature', 38.5))
        
        snapshot_id = model_loader.behavior_collector.save_snapshot(
            cow_id=cow_id,
            eating_time_per_hour=eating_time,
            lying_time_per_hour=lying_time,
            steps_per_hour=steps,
            rumination_time_per_hour=rumination_time,
            temperature=temperature
        )
        
        # Get hours of data
        hours = model_loader.behavior_collector.get_hours_of_data(cow_id)
        
        return jsonify({
            'snapshot_id': snapshot_id,
            'cow_id': cow_id,
            'hours_of_data': round(hours, 2),
            'message': 'Snapshot saved successfully',
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/behavior/analyze/<cow_id>', methods=['GET'])
def analyze_behavior(cow_id):
    """
    Analyze behavior patterns for a cow
    
    Parameters:
        - cow_id: Cow identifier
    
    Query Parameters:
        - hours: Hours of data to analyze (default: 24)
    
    Response:
        - status: Normal/Abnormal/Insufficient_Data
        - confidence: Confidence score
        - metrics: Current behavior metrics
        - baseline: Baseline comparison
    """
    try:
        if not BEHAVIOR_AVAILABLE or not model_loader.behavior_analyzer:
            return jsonify({'error': 'Behavior system not available'}), 500
        
        hours = int(request.args.get('hours', 24))
        
        result = model_loader.behavior_analyzer.analyze_cow(cow_id, hours=hours)
        result['timestamp'] = datetime.now().isoformat()
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/behavior/detect-from-video', methods=['POST'])
def detect_behavior_from_video():
    """
    Detect behavior from uploaded image/video frame using YOLOv8s
    
    Request:
        - image: Image file (video frame)
    
    Response:
        - behaviors: List of detected behaviors
        - count: Number of detections
    """
    try:
        if not YOLO_AVAILABLE or not model_loader.yolo_behavior_model:
            return jsonify({'error': 'YOLO behavior model not available'}), 500
        
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400
        
        file = request.files['image']
        filepath = save_uploaded_file(file)
        if not filepath:
            return jsonify({'error': 'Invalid file format'}), 400
        
        # Run YOLO detection
        results = model_loader.yolo_behavior_model(filepath, verbose=False)[0]
        
        behaviors = []
        if hasattr(results, 'boxes') and results.boxes is not None:
            for box in results.boxes:
                cls_id = int(box.cls[0])
                confidence = float(box.conf[0])
                class_name = model_loader.yolo_behavior_model.names[cls_id]
                
                behaviors.append({
                    'behavior': class_name,
                    'confidence': round(confidence, 4)
                })
        
        os.remove(filepath)
        
        return jsonify({
            'behaviors': behaviors,
            'count': len(behaviors),
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/video/analyze', methods=['POST'])
def analyze_video():
    """
    Analyze video file for both behavior and disease detection
    
    Request:
        - video: Video file (mp4, avi, mov, mkv, webm)
        - frame_interval: Optional, extract 1 frame every N frames (default: 30, ~1fps)
        - detect_disease: Optional, also detect disease (default: true)
        - detect_behavior: Optional, also detect behavior (default: true)
    
    Response:
        - video_info: Duration, FPS, frames analyzed
        - behavior_timeline: Detected behaviors over time
        - disease_detections: Disease detections with timestamps
        - summary: Aggregated results
    """
    try:
        # Check if video uploaded
        if 'video' not in request.files:
            return jsonify({'error': 'No video file uploaded'}), 400
        
        file = request.files['video']
        frame_interval = int(request.form.get('frame_interval', 30))
        detect_disease_flag = request.form.get('detect_disease', 'true').lower() == 'true'
        detect_behavior_flag = request.form.get('detect_behavior', 'true').lower() == 'true'
        
        # Save video file
        video_path = save_uploaded_video(file)
        if not video_path:
            return jsonify({'error': 'Invalid video file format. Supported: mp4, avi, mov, mkv, webm'}), 400
        
        # Extract frames from video
        video_data = process_video_frames(video_path, frame_interval)
        if video_data is None:
            os.remove(video_path)
            return jsonify({'error': 'Failed to process video file'}), 400
        
        frames = video_data['frames']
        fps = video_data['fps']
        duration = video_data['duration']
        
        # Initialize results
        behavior_timeline = []
        disease_detections = []
        
        # Process each frame
        for idx, frame in enumerate(frames):
            timestamp = (idx * frame_interval) / fps if fps > 0 else idx
            
            # Detect behavior
            if detect_behavior_flag and model_loader.yolo_behavior_model:
                try:
                    # Convert RGB to BGR for YOLO
                    frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                    results = model_loader.yolo_behavior_model(frame_bgr, verbose=False)
                    
                    behaviors = []
                    for result in results:
                        # Check if it's a classification model (probs)
                        if hasattr(result, 'probs') and result.probs is not None:
                            top5_indices = result.probs.top5
                            top5_conf = result.probs.top5conf.cpu().numpy()
                            
                            for i, conf in zip(top5_indices, top5_conf):
                                if conf > 0.3:  # Confidence threshold
                                    behavior_name = result.names[int(i)]
                                    behaviors.append({
                                        'behavior': behavior_name,
                                        'confidence': float(conf)
                                    })
                        
                        # Check if it's a detection model (boxes)
                        elif hasattr(result, 'boxes') and result.boxes is not None and len(result.boxes) > 0:
                            for box in result.boxes:
                                conf = float(box.conf.cpu().numpy()[0])
                                if conf > 0.3:  # Confidence threshold
                                    cls_id = int(box.cls.cpu().numpy()[0])
                                    behavior_name = result.names[cls_id]
                                    behaviors.append({
                                        'behavior': behavior_name,
                                        'confidence': conf
                                    })
                    
                    if behaviors:
                        behavior_timeline.append({
                            'timestamp': round(timestamp, 2),
                            'frame': idx,
                            'behaviors': behaviors
                        })
                except Exception as e:
                    print(f"Behavior detection error at frame {idx}: {str(e)}")
            
            # Detect disease
            if detect_disease_flag and model_loader.yolo_disease_model:
                try:
                    # Convert RGB to BGR for YOLO
                    frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                    results = model_loader.yolo_disease_model(frame_bgr, verbose=False)
                    
                    for result in results:
                        if hasattr(result, 'probs') and result.probs is not None:
                            top1_idx = result.probs.top1
                            top1_conf = result.probs.top1conf.cpu().numpy()
                            
                            if top1_conf > 0.5:  # Confidence threshold
                                disease_name = result.names[int(top1_idx)]
                                
                                disease_detections.append({
                                    'timestamp': round(timestamp, 2),
                                    'frame': idx,
                                    'disease': disease_name,
                                    'confidence': float(top1_conf)
                                })
                except Exception as e:
                    print(f"Disease detection error at frame {idx}: {str(e)}")
        
        # Aggregate results
        behavior_summary = {}
        if behavior_timeline:
            for entry in behavior_timeline:
                for behavior in entry['behaviors']:
                    behavior_name = behavior['behavior']
                    if behavior_name not in behavior_summary:
                        behavior_summary[behavior_name] = {
                            'count': 0,
                            'avg_confidence': 0,
                            'total_confidence': 0
                        }
                    behavior_summary[behavior_name]['count'] += 1
                    behavior_summary[behavior_name]['total_confidence'] += behavior['confidence']
            
            for behavior_name in behavior_summary:
                count = behavior_summary[behavior_name]['count']
                behavior_summary[behavior_name]['avg_confidence'] = round(
                    behavior_summary[behavior_name]['total_confidence'] / count, 4
                )
                del behavior_summary[behavior_name]['total_confidence']
        
        disease_summary = {}
        if disease_detections:
            for detection in disease_detections:
                disease_name = detection['disease']
                if disease_name not in disease_summary:
                    disease_summary[disease_name] = {
                        'count': 0,
                        'avg_confidence': 0,
                        'total_confidence': 0,
                        'first_seen': detection['timestamp'],
                        'last_seen': detection['timestamp']
                    }
                disease_summary[disease_name]['count'] += 1
                disease_summary[disease_name]['total_confidence'] += detection['confidence']
                disease_summary[disease_name]['last_seen'] = detection['timestamp']
            
            for disease_name in disease_summary:
                count = disease_summary[disease_name]['count']
                disease_summary[disease_name]['avg_confidence'] = round(
                    disease_summary[disease_name]['total_confidence'] / count, 4
                )
                del disease_summary[disease_name]['total_confidence']
        
        # Cleanup
        os.remove(video_path)
        
        # Prepare response
        result = {
            'video_info': {
                'duration': round(duration, 2),
                'fps': round(fps, 2),
                'total_frames': video_data['total_frames'],
                'analyzed_frames': video_data['extracted_frames'],
                'frame_interval': frame_interval
            },
            'behavior_timeline': behavior_timeline if detect_behavior_flag else None,
            'disease_detections': disease_detections if detect_disease_flag else None,
            'summary': {
                'behaviors': behavior_summary if detect_behavior_flag else None,
                'diseases': disease_summary if detect_disease_flag else None
            },
            'timestamp': datetime.now().isoformat()
        }
        
        return jsonify(result)
    
    except Exception as e:
        # Cleanup on error
        if 'video_path' in locals() and os.path.exists(video_path):
            os.remove(video_path)
        return jsonify({'error': str(e)}), 500

# ============================================================================
# STARTUP
# ============================================================================

@app.before_request
def load_models_once():
    """Load models before first request"""
    if not model_loader.models_loaded:
        model_loader.load_all_models()

# ============================================================================
# RUN SERVER
# ============================================================================

if __name__ == '__main__':
    print("\n" + "="*70)
    print("🐄 CATTLE DISEASE DETECTION API SERVER")
    print("="*70)
    print("\n📋 Available Endpoints:")
    print("  GET  /api/health - Health check")
    print("  GET  /api/models/status - Models status")
    print("  POST /api/disease/detect - Disease detection")
    print("  POST /api/disease/analyze - Complete analysis")
    print("  POST /api/quick-diagnosis - Fast YOLO diagnosis")
    print("  POST /api/behavior/snapshot - Save behavior data")
    print("  GET  /api/behavior/analyze/<cow_id> - Analyze behavior")
    print("  POST /api/behavior/detect-from-video - Detect from video frame")
    print("  POST /api/video/analyze - Analyze video file (NEW!)")
    print("\n" + "="*70)
    print("🚀 Starting server on http://0.0.0.0:5000")
    print("="*70 + "\n")
    
    # Load models at startup
    model_loader.load_all_models()
    
    # Run server
    app.run(host='0.0.0.0', port=5000, debug=True)
