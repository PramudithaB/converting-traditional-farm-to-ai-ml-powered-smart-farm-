"""
Test Video Analysis API Endpoint

This script demonstrates how to analyze video files for behavior and disease detection.
"""

import requests
import json
import os
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:5000/api"

# Colors for terminal output
GREEN = '\033[92m'
RED = '\033[91m'
BLUE = '\033[94m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_result(test_name, success, message):
    """Print colored test result"""
    status = f"{GREEN}✓ PASS{RESET}" if success else f"{RED}✗ FAIL{RESET}"
    print(f"{status} - {test_name}")
    if message:
        print(f"   {message}")
    print()

def test_video_analysis():
    """Test video analysis endpoint"""
    print(f"\n{BLUE}Testing Video Analysis Endpoint{RESET}")
    print("="*60)
    
    # Check if video files exist
    video_folder = "cattels_images_videos/videos"
    
    if not os.path.exists(video_folder):
        print(f"{RED}⚠️  Video folder not found: {video_folder}{RESET}")
        print(f"{YELLOW}📝 Note: Place your video files in {video_folder}{RESET}")
        print(f"{YELLOW}   Supported formats: MP4, AVI, MOV, MKV, WEBM{RESET}")
        return
    
    # Find first video file
    video_files = [f for f in os.listdir(video_folder) 
                   if f.lower().endswith(('.mp4', '.avi', '.mov', '.mkv', '.webm'))]
    
    if not video_files:
        print(f"{YELLOW}⚠️  No video files found in {video_folder}{RESET}")
        print(f"{YELLOW}📝 To test this endpoint:{RESET}")
        print(f"{YELLOW}   1. Place a video file (MP4, AVI, MOV) in {video_folder}{RESET}")
        print(f"{YELLOW}   2. Or record a video of cattle using your phone{RESET}")
        print(f"{YELLOW}   3. Run this test again{RESET}")
        print()
        
        # Show how to use with custom video
        print(f"{BLUE}Example Usage with Custom Video:{RESET}")
        print(f"""
import requests

# Upload your video
with open('path/to/your/video.mp4', 'rb') as video_file:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={{'video': video_file}},
        data={{
            'frame_interval': 30,  # Extract 1 frame every 30 frames (~1 fps)
            'detect_disease': 'true',
            'detect_behavior': 'true'
        }}
    )
    
    result = response.json()
    print(f"Duration: {{result['video_info']['duration']}} seconds")
    print(f"Analyzed frames: {{result['video_info']['analyzed_frames']}}")
    print(f"Behaviors detected: {{list(result['summary']['behaviors'].keys())}}")
    print(f"Diseases detected: {{list(result['summary']['diseases'].keys())}}")
        """)
        return
    
    video_path = os.path.join(video_folder, video_files[0])
    print(f"{GREEN}✓ Found video: {video_files[0]}{RESET}")
    print(f"{BLUE}ℹ️  Processing video (this may take 10-30 seconds)...{RESET}\n")
    
    try:
        # Test with video file
        with open(video_path, 'rb') as video_file:
            files = {'video': video_file}
            data = {
                'frame_interval': '30',  # 1 frame per second at 30fps
                'detect_disease': 'true',
                'detect_behavior': 'true'
            }
            
            response = requests.post(f"{BASE_URL}/video/analyze", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            
            # Display video info
            video_info = result['video_info']
            print(f"{GREEN}✓ Video processed successfully!{RESET}")
            print(f"\n{BLUE}📹 Video Information:{RESET}")
            print(f"   Duration: {video_info['duration']} seconds")
            print(f"   FPS: {video_info['fps']}")
            print(f"   Total Frames: {video_info['total_frames']}")
            print(f"   Analyzed Frames: {video_info['analyzed_frames']}")
            print(f"   Frame Interval: {video_info['frame_interval']}")
            
            # Display behavior summary
            if result.get('summary', {}).get('behaviors'):
                print(f"\n{BLUE}🐄 Detected Behaviors:{RESET}")
                for behavior, stats in result['summary']['behaviors'].items():
                    print(f"   • {behavior}:")
                    print(f"     - Detected {stats['count']} times")
                    print(f"     - Avg Confidence: {stats['avg_confidence']:.2%}")
            else:
                print(f"\n{YELLOW}⚠️  No behaviors detected{RESET}")
            
            # Display disease summary
            if result.get('summary', {}).get('diseases'):
                print(f"\n{BLUE}🏥 Detected Diseases:{RESET}")
                for disease, stats in result['summary']['diseases'].items():
                    print(f"   • {disease}:")
                    print(f"     - Detected {stats['count']} times")
                    print(f"     - Avg Confidence: {stats['avg_confidence']:.2%}")
                    print(f"     - First seen: {stats['first_seen']}s")
                    print(f"     - Last seen: {stats['last_seen']}s")
            else:
                print(f"\n{YELLOW}⚠️  No diseases detected{RESET}")
            
            # Display timeline (first 5 entries)
            if result.get('behavior_timeline'):
                print(f"\n{BLUE}📊 Behavior Timeline (first 5 frames):{RESET}")
                for entry in result['behavior_timeline'][:5]:
                    print(f"   [{entry['timestamp']:.1f}s] Frame {entry['frame']}:")
                    for behavior in entry['behaviors']:
                        print(f"      - {behavior['behavior']}: {behavior['confidence']:.2%}")
            
            print(f"\n{GREEN}✓ Video analysis completed successfully!{RESET}")
            
        else:
            print(f"{RED}✗ Error: {response.status_code}{RESET}")
            print(f"   {response.json().get('error', 'Unknown error')}")
    
    except Exception as e:
        print(f"{RED}✗ Error: {str(e)}{RESET}")

def show_usage_examples():
    """Show usage examples"""
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}VIDEO ANALYSIS API - USAGE EXAMPLES{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")
    
    print(f"{GREEN}1. Python Example:{RESET}")
    print("""
import requests

# Analyze video with both behavior and disease detection
with open('video.mp4', 'rb') as video:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={'video': video},
        data={
            'frame_interval': 30,      # 1 frame per second
            'detect_disease': 'true',
            'detect_behavior': 'true'
        }
    )
    result = response.json()
    print(f"Duration: {result['video_info']['duration']}s")
    print(f"Behaviors: {list(result['summary']['behaviors'].keys())}")
    """)
    
    print(f"\n{GREEN}2. cURL Example:{RESET}")
    print("""
curl -X POST http://localhost:5000/api/video/analyze \\
  -F "video=@cattle_video.mp4" \\
  -F "frame_interval=30" \\
  -F "detect_disease=true" \\
  -F "detect_behavior=true"
    """)
    
    print(f"\n{GREEN}3. Fast Processing (only behavior):{RESET}")
    print("""
# Detect only behavior, skip disease detection for speed
with open('video.mp4', 'rb') as video:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={'video': video},
        data={
            'frame_interval': 60,       # Faster: 1 frame every 2 seconds
            'detect_disease': 'false',  # Skip disease detection
            'detect_behavior': 'true'
        }
    )
    """)
    
    print(f"\n{GREEN}4. Accurate Analysis (more frames):{RESET}")
    print("""
# Process more frames for better accuracy
with open('video.mp4', 'rb') as video:
    response = requests.post(
        'http://localhost:5000/api/video/analyze',
        files={'video': video},
        data={
            'frame_interval': 15,       # 2 frames per second (slower but more accurate)
            'detect_disease': 'true',
            'detect_behavior': 'true'
        }
    )
    """)
    
    print(f"\n{YELLOW}⚙️  Frame Interval Guide:{RESET}")
    print(f"   • frame_interval=60  → Fast (0.5 fps) - Quick overview")
    print(f"   • frame_interval=30  → Balanced (1 fps) - Recommended")
    print(f"   • frame_interval=15  → Accurate (2 fps) - Best results")
    print(f"   • frame_interval=10  → Very accurate (3 fps) - Slower")

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🎥 CATTLE VIDEO ANALYSIS API - TEST SUITE")
    print("="*60)
    
    # Test video endpoint
    test_video_analysis()
    
    # Show usage examples
    show_usage_examples()
    
    print(f"\n{GREEN}{'='*60}{RESET}")
    print(f"{GREEN}Testing Complete!{RESET}")
    print(f"{GREEN}{'='*60}{RESET}\n")
