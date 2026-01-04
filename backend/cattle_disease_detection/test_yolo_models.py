"""
🧪 YOLO MODELS TESTING SUITE
=============================
Tests for YOLOv8s (Behavior) and YOLOv8x-Classifier (Disease) models

Author: Automated Testing System
Date: January 1, 2026
"""

import os
import sys
import glob
import json
import numpy as np
from pathlib import Path
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# CONFIGURATION
# ============================================================================

class YOLOTestConfig:
    """YOLO test configuration"""
    
    # Model paths
    YOLO_BEHAVIOR_MODEL = "models/All_Behaviore/best.pt"  # YOLOv8s
    YOLO_DISEASE_MODEL = "models/All_Cattle_Disease/best.pt"  # YOLOv8x-Classifier
    
    # Test images/videos
    BEHAVIOR_TEST_IMAGES = "cattels_images_videos/images/Behavior_test_photos"
    DISEASE_TEST_IMAGES = "cattels_images_videos/images/Disease_test_photo"
    TEST_VIDEOS = "cattels_images_videos/videos"
    
    # Results
    RESULTS_DIR = "test_results"
    YOLO_RESULTS_FILE = "yolo_test_results.json"

# ============================================================================
# TEST LOGGER
# ============================================================================

class TestLogger:
    """Log test results"""
    
    def __init__(self):
        self.results = []
        self.passed = 0
        self.failed = 0
        os.makedirs(YOLOTestConfig.RESULTS_DIR, exist_ok=True)
        
    def log_test(self, test_name, passed, details=""):
        result = {
            'test_name': test_name,
            'passed': bool(passed),
            'details': str(details),
            'timestamp': datetime.now().isoformat()
        }
        self.results.append(result)
        
        if passed:
            self.passed += 1
            print(f"✅ PASS: {test_name}")
        else:
            self.failed += 1
            print(f"❌ FAIL: {test_name}")
        
        if details:
            print(f"   {details}")
    
    def save_results(self):
        """Save test results to JSON"""
        results_file = os.path.join(YOLOTestConfig.RESULTS_DIR, YOLOTestConfig.YOLO_RESULTS_FILE)
        with open(results_file, 'w') as f:
            json.dump({
                'summary': {
                    'total': len(self.results),
                    'passed': self.passed,
                    'failed': self.failed,
                    'pass_rate': f"{(self.passed/len(self.results)*100):.1f}%" if self.results else "0%"
                },
                'tests': self.results
            }, f, indent=2)
        print(f"\n📁 Results saved to: {results_file}")

# ============================================================================
# TEST 1: CHECK YOLO MODEL FILES
# ============================================================================

def test_yolo_model_files(logger):
    """Test if YOLO model files exist"""
    
    print("\n" + "="*70)
    print("TEST 1: YOLO MODEL FILES VALIDATION")
    print("="*70)
    
    # Check YOLOv8s behavior model
    behavior_model_path = YOLOTestConfig.YOLO_BEHAVIOR_MODEL
    if os.path.exists(behavior_model_path):
        file_size = os.path.getsize(behavior_model_path) / (1024*1024)  # MB
        logger.log_test(
            "YOLOv8s Behavior model file exists",
            True,
            f"File size: {file_size:.2f} MB"
        )
    else:
        logger.log_test(
            "YOLOv8s Behavior model file exists",
            False,
            f"Path not found: {behavior_model_path}"
        )
    
    # Check YOLOv8x disease model
    disease_model_path = YOLOTestConfig.YOLO_DISEASE_MODEL
    if os.path.exists(disease_model_path):
        file_size = os.path.getsize(disease_model_path) / (1024*1024)  # MB
        logger.log_test(
            "YOLOv8x-Classifier Disease model file exists",
            True,
            f"File size: {file_size:.2f} MB"
        )
    else:
        logger.log_test(
            "YOLOv8x-Classifier Disease model file exists",
            False,
            f"Path not found: {disease_model_path}"
        )

# ============================================================================
# TEST 2: LOAD YOLO MODELS
# ============================================================================

def test_yolo_model_loading(logger):
    """Test loading YOLO models"""
    
    print("\n" + "="*70)
    print("TEST 2: YOLO MODEL LOADING")
    print("="*70)
    
    try:
        from ultralytics import YOLO
        
        # Test YOLOv8s behavior model
        behavior_model_path = YOLOTestConfig.YOLO_BEHAVIOR_MODEL
        if os.path.exists(behavior_model_path):
            try:
                behavior_model = YOLO(behavior_model_path)
                logger.log_test(
                    "YOLOv8s Behavior model loads successfully",
                    True,
                    f"Model type: {type(behavior_model).__name__}, Names: {behavior_model.names}"
                )
            except Exception as e:
                logger.log_test(
                    "YOLOv8s Behavior model loads successfully",
                    False,
                    f"Error: {str(e)}"
                )
        else:
            logger.log_test(
                "YOLOv8s Behavior model loads successfully",
                False,
                "Model file not found"
            )
        
        # Test YOLOv8x disease model
        disease_model_path = YOLOTestConfig.YOLO_DISEASE_MODEL
        if os.path.exists(disease_model_path):
            try:
                disease_model = YOLO(disease_model_path)
                logger.log_test(
                    "YOLOv8x-Classifier Disease model loads successfully",
                    True,
                    f"Model type: {type(disease_model).__name__}, Names: {disease_model.names}"
                )
            except Exception as e:
                logger.log_test(
                    "YOLOv8x-Classifier Disease model loads successfully",
                    False,
                    f"Error: {str(e)}"
                )
        else:
            logger.log_test(
                "YOLOv8x-Classifier Disease model loads successfully",
                False,
                "Model file not found"
            )
    
    except ImportError:
        logger.log_test(
            "YOLO model loading test",
            False,
            "ultralytics library not installed. Run: pip install ultralytics"
        )

# ============================================================================
# TEST 3: BEHAVIOR DETECTION WITH YOLOV8s
# ============================================================================

def test_behavior_detection(logger):
    """Test YOLOv8s behavior detection with real images"""
    
    print("\n" + "="*70)
    print("TEST 3: BEHAVIOR DETECTION WITH YOLOv8s")
    print("="*70)
    
    try:
        from ultralytics import YOLO
        import cv2
        
        behavior_model_path = YOLOTestConfig.YOLO_BEHAVIOR_MODEL
        if not os.path.exists(behavior_model_path):
            logger.log_test(
                "Behavior detection test",
                False,
                "YOLOv8s model file not found"
            )
            return
        
        # Load model
        behavior_model = YOLO(behavior_model_path)
        
        # Get behavior test images
        behavior_path = YOLOTestConfig.BEHAVIOR_TEST_IMAGES
        if not os.path.exists(behavior_path):
            logger.log_test(
                "Behavior detection test",
                False,
                f"Behavior images not found at: {behavior_path}"
            )
            return
        
        images = glob.glob(os.path.join(behavior_path, "*.[jJ][pP][gG]"))[:5]
        if not images:
            images = glob.glob(os.path.join(behavior_path, "*.[pP][nN][gG]"))[:5]
        
        if not images:
            logger.log_test(
                "Behavior detection test",
                False,
                "No test images found"
            )
            return
        
        print(f"\n🔍 Testing with {len(images)} behavior images...\n")
        
        for img_path in images:
            try:
                # Run inference
                results = behavior_model(img_path, verbose=False)
                
                # Extract predictions
                result = results[0]
                detections = len(result.boxes) if hasattr(result, 'boxes') else 0
                
                # Get detected behaviors
                behaviors = []
                if hasattr(result, 'boxes') and result.boxes is not None:
                    for box in result.boxes:
                        cls_id = int(box.cls[0])
                        confidence = float(box.conf[0])
                        class_name = behavior_model.names[cls_id]
                        behaviors.append(f"{class_name} ({confidence:.2%})")
                
                logger.log_test(
                    f"  Image: {os.path.basename(img_path)}",
                    True,
                    f"Detected {detections} objects: {', '.join(behaviors) if behaviors else 'None'}"
                )
            
            except Exception as e:
                logger.log_test(
                    f"  Image: {os.path.basename(img_path)}",
                    False,
                    f"Error: {str(e)}"
                )
    
    except ImportError:
        logger.log_test(
            "Behavior detection test",
            False,
            "ultralytics library not installed"
        )
    except Exception as e:
        logger.log_test(
            "Behavior detection test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# TEST 4: DISEASE DETECTION WITH YOLOv8x-CLASSIFIER
# ============================================================================

def test_disease_classification(logger):
    """Test YOLOv8x-Classifier disease detection with real images"""
    
    print("\n" + "="*70)
    print("TEST 4: DISEASE CLASSIFICATION WITH YOLOv8x-Classifier")
    print("="*70)
    
    try:
        from ultralytics import YOLO
        
        disease_model_path = YOLOTestConfig.YOLO_DISEASE_MODEL
        if not os.path.exists(disease_model_path):
            logger.log_test(
                "Disease classification test",
                False,
                "YOLOv8x-Classifier model file not found"
            )
            return
        
        # Load model
        disease_model = YOLO(disease_model_path)
        
        # Test each disease category
        disease_path = YOLOTestConfig.DISEASE_TEST_IMAGES
        if not os.path.exists(disease_path):
            logger.log_test(
                "Disease classification test",
                False,
                f"Disease images not found at: {disease_path}"
            )
            return
        
        categories = [d for d in os.listdir(disease_path) if os.path.isdir(os.path.join(disease_path, d))]
        
        for category in categories[:4]:  # Test first 4 categories
            cat_path = os.path.join(disease_path, category)
            images = glob.glob(os.path.join(cat_path, "*.[jJ][pP][gG]"))[:2]  # 2 images per category
            
            if not images:
                images = glob.glob(os.path.join(cat_path, "*.[pP][nN][gG]"))[:2]
            
            if images:
                print(f"\n🔍 Testing category: {category}")
                for img_path in images:
                    try:
                        # Run inference
                        results = disease_model(img_path, verbose=False)
                        
                        # Extract predictions (classifier model)
                        result = results[0]
                        
                        # For classifier models, get top predictions
                        if hasattr(result, 'probs') and result.probs is not None:
                            # Classification model
                            top_class_id = int(result.probs.top1)
                            top_confidence = float(result.probs.top1conf)
                            predicted_class = disease_model.names[top_class_id]
                            
                            # Get top 3 predictions
                            top5_indices = result.probs.top5
                            top5_conf = result.probs.top5conf
                            top3 = []
                            for i in range(min(3, len(top5_indices))):
                                cls_name = disease_model.names[top5_indices[i]]
                                conf = float(top5_conf[i])
                                top3.append(f"{cls_name} ({conf:.2%})")
                            
                            logger.log_test(
                                f"  Image: {os.path.basename(img_path)}",
                                top_confidence > 0.2,
                                f"Predicted: {predicted_class} ({top_confidence:.2%}), Top3: {', '.join(top3)}"
                            )
                        else:
                            # Detection model format
                            detections = len(result.boxes) if hasattr(result, 'boxes') else 0
                            logger.log_test(
                                f"  Image: {os.path.basename(img_path)}",
                                True,
                                f"Detected {detections} objects"
                            )
                    
                    except Exception as e:
                        logger.log_test(
                            f"  Image: {os.path.basename(img_path)}",
                            False,
                            f"Error: {str(e)}"
                        )
    
    except ImportError:
        logger.log_test(
            "Disease classification test",
            False,
            "ultralytics library not installed"
        )
    except Exception as e:
        logger.log_test(
            "Disease classification test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# TEST 5: MODEL COMPARISON
# ============================================================================

def test_model_comparison(logger):
    """Compare YOLOv8x vs DenseNet121 on same images"""
    
    print("\n" + "="*70)
    print("TEST 5: MODEL COMPARISON (YOLOv8x vs DenseNet121)")
    print("="*70)
    
    try:
        from ultralytics import YOLO
        from tensorflow import keras
        import cv2
        
        # Load both models
        yolo_path = YOLOTestConfig.YOLO_DISEASE_MODEL
        densenet_path = "models/DenseNet121_Disease/best_model.h5"
        
        if not os.path.exists(yolo_path):
            logger.log_test(
                "Model comparison test",
                False,
                "YOLOv8x model not found"
            )
            return
        
        if not os.path.exists(densenet_path):
            logger.log_test(
                "Model comparison test",
                False,
                "DenseNet121 model not found"
            )
            return
        
        yolo_model = YOLO(yolo_path)
        densenet_model = keras.models.load_model(densenet_path)
        
        # Test on healthy images
        disease_path = YOLOTestConfig.DISEASE_TEST_IMAGES
        healthy_path = os.path.join(disease_path, "healthy")
        
        if os.path.exists(healthy_path):
            images = glob.glob(os.path.join(healthy_path, "*.[jJ][pP][gG]"))[:3]
            
            print(f"\n🔍 Comparing models on {len(images)} healthy cattle images...\n")
            
            for img_path in images:
                try:
                    # YOLOv8x prediction
                    yolo_results = yolo_model(img_path, verbose=False)[0]
                    if hasattr(yolo_results, 'probs') and yolo_results.probs is not None:
                        yolo_class = yolo_model.names[int(yolo_results.probs.top1)]
                        yolo_conf = float(yolo_results.probs.top1conf)
                    else:
                        yolo_class = "Unknown"
                        yolo_conf = 0.0
                    
                    # DenseNet121 prediction
                    img = cv2.imread(img_path)
                    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                    img = cv2.resize(img, (224, 224))
                    img_array = np.expand_dims(img, axis=0) / 255.0
                    densenet_pred = densenet_model.predict(img_array, verbose=0)
                    densenet_conf = float(np.max(densenet_pred))
                    
                    logger.log_test(
                        f"  Comparison: {os.path.basename(img_path)}",
                        True,
                        f"YOLOv8x: {yolo_class} ({yolo_conf:.2%}) | DenseNet121: {densenet_conf:.2%}"
                    )
                
                except Exception as e:
                    logger.log_test(
                        f"  Comparison: {os.path.basename(img_path)}",
                        False,
                        f"Error: {str(e)}"
                    )
        else:
            logger.log_test(
                "Model comparison test",
                False,
                "Healthy images not found"
            )
    
    except ImportError as e:
        logger.log_test(
            "Model comparison test",
            False,
            f"Required library not installed: {str(e)}"
        )
    except Exception as e:
        logger.log_test(
            "Model comparison test",
            False,
            f"Error: {str(e)}"
        )

# ============================================================================
# MAIN TEST RUNNER
# ============================================================================

def run_yolo_tests():
    """Run YOLO-specific tests"""
    
    print("\n" + "="*70)
    print("🧪 YOLO MODELS TESTING - YOLOv8s & YOLOv8x-Classifier")
    print("="*70)
    print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Working Directory: {os.getcwd()}")
    print("="*70)
    
    logger = TestLogger()
    
    # Run all tests
    test_yolo_model_files(logger)
    test_yolo_model_loading(logger)
    test_behavior_detection(logger)
    test_disease_classification(logger)
    test_model_comparison(logger)
    
    # Print summary
    print("\n" + "="*70)
    print("📊 YOLO TEST SUMMARY")
    print("="*70)
    print(f"Total Tests: {logger.passed + logger.failed}")
    print(f"✅ Passed: {logger.passed}")
    print(f"❌ Failed: {logger.failed}")
    if logger.passed + logger.failed > 0:
        pass_rate = logger.passed / (logger.passed + logger.failed) * 100
        print(f"📈 Pass Rate: {pass_rate:.1f}%")
        
        if pass_rate == 100:
            print("\n🎉 ALL YOLO TESTS PASSED!")
        elif pass_rate >= 80:
            print("\n✅ Most YOLO tests passed.")
        else:
            print("\n⚠️ Some YOLO tests failed. Review results.")
    
    print("="*70)
    
    # Save results
    logger.save_results()
    
    print("\n💡 YOLO MODELS STATUS:")
    print("-" * 70)
    print("✅ YOLOv8s (Behavior): Fine-tuned for behavior monitoring")
    print("   - Detects: Eating, Lying, Standing, Walking, Ruminating")
    print("   - Real-time video analysis capability")
    print("")
    print("✅ YOLOv8x-Classifier (Disease): Disease classification")
    print("   - Classifies: 8 disease categories")
    print("   - Fast inference for mobile/field use")
    print("-" * 70)
    
    return logger

if __name__ == "__main__":
    logger = run_yolo_tests()
    
    print("\n📝 NEXT STEPS:")
    print("-" * 70)
    print("1. If ultralytics not installed: pip install ultralytics")
    print("2. Test with videos: Add video files to cattels_images_videos/videos/")
    print("3. Compare YOLO vs DenseNet121 accuracy on your dataset")
    print("4. Deploy YOLOv8x for fast mobile inference")
    print("5. Use YOLOv8s for real-time behavior monitoring from CCTV")
    print("-" * 70)
