"""
🧪 API TEST CLIENT
==================
Test all API endpoints with sample data

Usage:
    python api_test_client.py

Requirements:
    - API server running on http://localhost:5000
    - Sample images in cattels_images_videos/images/
"""

import requests
import json
import os
import glob
from datetime import datetime

# API Base URL
BASE_URL = "http://localhost:5000/api"

# Test images
DISEASE_IMAGE = "cattels_images_videos/images/Disease_test_photo/mastitis/cattle_mastitis_012_jpg.rf.c5251eda8b68b716bc146d53bc692cd6.jpg"
BEHAVIOR_IMAGE = "cattels_images_videos/images/Behavior_test_photos/000000063_jpg.rf.68b9f47ba272312d69f7c6ec7bde4d22.jpg"

# Colors for output
GREEN = '\033[92m'
RED = '\033[91m'
BLUE = '\033[94m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_header(text):
    print(f"\n{BLUE}{'='*70}{RESET}")
    print(f"{BLUE}{text}{RESET}")
    print(f"{BLUE}{'='*70}{RESET}\n")

def print_success(text):
    print(f"{GREEN}✅ {text}{RESET}")

def print_error(text):
    print(f"{RED}❌ {text}{RESET}")

def print_info(text):
    print(f"{YELLOW}ℹ️  {text}{RESET}")

def test_health_check():
    """Test health check endpoint"""
    print_header("TEST 1: Health Check")
    
    try:
        response = requests.get(f"{BASE_URL}/health")
        data = response.json()
        
        if response.status_code == 200 and data.get('status') == 'healthy':
            print_success("Health check passed")
            print(f"   Status: {data.get('status')}")
            print(f"   Models Loaded: {data.get('models_loaded')}")
            print(f"   Version: {data.get('version')}")
            return True
        else:
            print_error("Health check failed")
            return False
    
    except Exception as e:
        print_error(f"Health check error: {str(e)}")
        return False

def test_models_status():
    """Test models status endpoint"""
    print_header("TEST 2: Models Status")
    
    try:
        response = requests.get(f"{BASE_URL}/models/status")
        data = response.json()
        
        if response.status_code == 200:
            print_success("Models status retrieved")
            for model, status in data.items():
                status_icon = "✅" if status else "❌"
                print(f"   {status_icon} {model}: {status}")
            return True
        else:
            print_error("Models status failed")
            return False
    
    except Exception as e:
        print_error(f"Models status error: {str(e)}")
        return False

def test_disease_detection():
    """Test disease detection endpoint"""
    print_header("TEST 3: Disease Detection (DenseNet121)")
    
    # Find a test image
    test_image = None
    if os.path.exists(DISEASE_IMAGE):
        test_image = DISEASE_IMAGE
    else:
        # Find any disease image
        images = glob.glob("cattels_images_videos/images/Disease_test_photo/**/*.jpg", recursive=True)
        if images:
            test_image = images[0]
    
    if not test_image:
        print_error("No test image found")
        return False
    
    print_info(f"Using image: {os.path.basename(test_image)}")
    
    try:
        with open(test_image, 'rb') as f:
            files = {'image': f}
            data = {'use_yolo': 'false'}
            response = requests.post(f"{BASE_URL}/disease/detect", files=files, data=data)
        
        result = response.json()
        
        if response.status_code == 200 and 'disease' in result:
            print_success("Disease detection successful")
            print(f"   Disease: {result.get('disease')}")
            print(f"   Confidence: {result.get('confidence'):.2%}")
            print(f"   Model: {result.get('recommended')}")
            
            if 'densenet' in result:
                print(f"\n   DenseNet121 Results:")
                print(f"   - Disease: {result['densenet']['disease']}")
                print(f"   - Confidence: {result['densenet']['confidence']:.2%}")
            
            return True
        else:
            print_error(f"Disease detection failed: {result.get('error', 'Unknown error')}")
            return False
    
    except Exception as e:
        print_error(f"Disease detection error: {str(e)}")
        return False

def test_complete_analysis():
    """Test complete analysis endpoint"""
    print_header("TEST 4: Complete Analysis (Disease + Severity + Treatment)")
    
    # Find a test image
    test_image = None
    if os.path.exists(DISEASE_IMAGE):
        test_image = DISEASE_IMAGE
    else:
        images = glob.glob("cattels_images_videos/images/Disease_test_photo/**/*.jpg", recursive=True)
        if images:
            test_image = images[0]
    
    if not test_image:
        print_error("No test image found")
        return False
    
    print_info(f"Using image: {os.path.basename(test_image)}")
    
    try:
        with open(test_image, 'rb') as f:
            files = {'image': f}
            data = {
                'weight': '450',
                'age': '40',
                'temperature': '39.5',
                'previous_disease': 'None'
            }
            response = requests.post(f"{BASE_URL}/disease/analyze", files=files, data=data)
        
        result = response.json()
        
        if response.status_code == 200 and 'disease' in result:
            print_success("Complete analysis successful")
            
            # Disease
            print(f"\n   🔍 DISEASE:")
            print(f"   - Name: {result['disease']['name']}")
            print(f"   - Confidence: {result['disease']['confidence']:.2%}")
            
            # Severity
            if 'severity' in result:
                print(f"\n   ⚠️  SEVERITY:")
                print(f"   - Level: {result['severity']['level']}")
                print(f"   - Confidence: {result['severity']['confidence']:.2%}")
                
                if 'probabilities' in result['severity']:
                    print(f"   - Probabilities:")
                    for level, prob in result['severity']['probabilities'].items():
                        print(f"     * {level}: {prob:.2%}")
            
            # Treatment
            if 'treatment' in result:
                print(f"\n   💊 TREATMENT:")
                print(f"   - Primary: {result['treatment']['primary']}")
                print(f"   - Confidence: {result['treatment']['confidence']:.2%}")
                
                if 'alternatives' in result['treatment']:
                    print(f"   - Top 3 Options:")
                    for i, alt in enumerate(result['treatment']['alternatives'][:3], 1):
                        print(f"     {i}. {alt['treatment']} ({alt['probability']:.2%})")
            
            # Clinical Data
            if 'clinical_data' in result:
                print(f"\n   📊 CLINICAL DATA:")
                cd = result['clinical_data']
                print(f"   - Weight: {cd['weight']} kg")
                print(f"   - Age: {cd['age']} months")
                print(f"   - Temperature: {cd['temperature']}°C")
            
            return True
        else:
            print_error(f"Complete analysis failed: {result.get('error', 'Unknown error')}")
            return False
    
    except Exception as e:
        print_error(f"Complete analysis error: {str(e)}")
        return False

def test_quick_diagnosis():
    """Test quick diagnosis (YOLO) endpoint"""
    print_header("TEST 5: Quick Diagnosis (YOLOv8x)")
    
    # Find a test image
    test_image = None
    if os.path.exists(DISEASE_IMAGE):
        test_image = DISEASE_IMAGE
    else:
        images = glob.glob("cattels_images_videos/images/Disease_test_photo/**/*.jpg", recursive=True)
        if images:
            test_image = images[0]
    
    if not test_image:
        print_error("No test image found")
        return False
    
    print_info(f"Using image: {os.path.basename(test_image)}")
    
    try:
        with open(test_image, 'rb') as f:
            files = {'image': f}
            response = requests.post(f"{BASE_URL}/quick-diagnosis", files=files)
        
        result = response.json()
        
        if response.status_code == 200 and 'disease' in result:
            print_success("Quick diagnosis successful")
            print(f"   Disease: {result.get('disease')}")
            print(f"   Confidence: {result.get('confidence'):.2%}")
            print(f"   Model: {result.get('model')}")
            
            if 'top3' in result:
                print(f"\n   Top 3 Predictions:")
                for i, pred in enumerate(result['top3'], 1):
                    print(f"   {i}. {pred['disease']} ({pred['confidence']:.2%})")
            
            return True
        else:
            print_error(f"Quick diagnosis failed: {result.get('error', 'Unknown error')}")
            return False
    
    except Exception as e:
        print_error(f"Quick diagnosis error: {str(e)}")
        return False

def test_behavior_snapshot():
    """Test save behavior snapshot endpoint"""
    print_header("TEST 6: Save Behavior Snapshot")
    
    try:
        data = {
            'cow_id': 'TEST-COW-001',
            'eating_time': 10.5,
            'lying_time': 0.55,
            'steps': 180,
            'rumination_time': 20.0,
            'temperature': 38.6
        }
        
        response = requests.post(
            f"{BASE_URL}/behavior/snapshot",
            headers={'Content-Type': 'application/json'},
            data=json.dumps(data)
        )
        
        result = response.json()
        
        if response.status_code == 200 and 'snapshot_id' in result:
            print_success("Behavior snapshot saved")
            print(f"   Snapshot ID: {result.get('snapshot_id')}")
            print(f"   Cow ID: {result.get('cow_id')}")
            print(f"   Hours of Data: {result.get('hours_of_data')}")
            return True
        else:
            print_error(f"Behavior snapshot failed: {result.get('error', 'Unknown error')}")
            return False
    
    except Exception as e:
        print_error(f"Behavior snapshot error: {str(e)}")
        return False

def test_behavior_analysis():
    """Test analyze behavior endpoint"""
    print_header("TEST 7: Analyze Behavior")
    
    try:
        cow_id = 'TEST-COW-001'
        response = requests.get(f"{BASE_URL}/behavior/analyze/{cow_id}?hours=24")
        
        result = response.json()
        
        if response.status_code == 200:
            print_success("Behavior analysis retrieved")
            print(f"   Cow ID: {result.get('cow_id')}")
            print(f"   Status: {result.get('status')}")
            print(f"   Confidence: {result.get('confidence', 0):.2%}")
            print(f"   Hours Analyzed: {result.get('hours_analyzed', 0)}")
            
            if 'current_metrics' in result:
                print(f"\n   Current Metrics:")
                metrics = result['current_metrics']
                for key, value in metrics.items():
                    print(f"   - {key}: {value}")
            
            return True
        else:
            print_error(f"Behavior analysis failed: {result.get('error', 'Unknown error')}")
            return False
    
    except Exception as e:
        print_error(f"Behavior analysis error: {str(e)}")
        return False

def test_behavior_detection():
    """Test behavior detection from video frame"""
    print_header("TEST 8: Behavior Detection from Video Frame")
    
    # Find a test image
    test_image = None
    if os.path.exists(BEHAVIOR_IMAGE):
        test_image = BEHAVIOR_IMAGE
    else:
        images = glob.glob("cattels_images_videos/images/Behavior_test_photos/*.jpg")
        if images:
            test_image = images[0]
    
    if not test_image:
        print_error("No behavior test image found")
        return False
    
    print_info(f"Using image: {os.path.basename(test_image)}")
    
    try:
        with open(test_image, 'rb') as f:
            files = {'image': f}
            response = requests.post(f"{BASE_URL}/behavior/detect-from-video", files=files)
        
        result = response.json()
        
        if response.status_code == 200 and 'behaviors' in result:
            print_success("Behavior detection successful")
            print(f"   Detected Behaviors: {result.get('count')}")
            
            if result['behaviors']:
                print(f"\n   Behaviors:")
                for behavior in result['behaviors']:
                    print(f"   - {behavior['behavior']}: {behavior['confidence']:.2%}")
            else:
                print(f"   No behaviors detected")
            
            return True
        else:
            print_error(f"Behavior detection failed: {result.get('error', 'Unknown error')}")
            return False
    
    except Exception as e:
        print_error(f"Behavior detection error: {str(e)}")
        return False

def run_all_tests():
    """Run all API tests"""
    print("\n" + "="*70)
    print("🧪 CATTLE DISEASE DETECTION API - TEST CLIENT")
    print("="*70)
    print(f"API Base URL: {BASE_URL}")
    print(f"Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70)
    
    results = []
    
    # Run tests
    results.append(("Health Check", test_health_check()))
    results.append(("Models Status", test_models_status()))
    results.append(("Disease Detection", test_disease_detection()))
    results.append(("Complete Analysis", test_complete_analysis()))
    results.append(("Quick Diagnosis", test_quick_diagnosis()))
    results.append(("Behavior Snapshot", test_behavior_snapshot()))
    results.append(("Behavior Analysis", test_behavior_analysis()))
    results.append(("Behavior Detection", test_behavior_detection()))
    
    # Summary
    print_header("TEST SUMMARY")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = f"{GREEN}✅ PASS{RESET}" if result else f"{RED}❌ FAIL{RESET}"
        print(f"   {test_name:.<50} {status}")
    
    print(f"\n{BLUE}{'='*70}{RESET}")
    print(f"{BLUE}Total: {passed}/{total} tests passed ({passed/total*100:.1f}%){RESET}")
    print(f"{BLUE}{'='*70}{RESET}\n")
    
    if passed == total:
        print_success("🎉 ALL TESTS PASSED! API is fully functional!")
    elif passed >= total * 0.8:
        print_info("⚠️  Most tests passed. Check failed tests.")
    else:
        print_error("❌ Many tests failed. Check API server and models.")

if __name__ == "__main__":
    print_info("Make sure API server is running on http://localhost:5000")
    print_info("Start server with: python api_server.py\n")
    
    input("Press Enter to start tests...")
    
    run_all_tests()
