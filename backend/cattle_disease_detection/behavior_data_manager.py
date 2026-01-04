"""
🐄 BEHAVIOR DATA COLLECTION & ANALYSIS MANAGER
================================================
Handles time-series behavior data collection for cattle monitoring

Key Features:
- Save behavior snapshots at regular intervals
- Accumulate data over time (24+ hours)
- Analyze trends when sufficient data collected
- Detect Normal/Abnormal patterns
- Support per-cow baseline creation

Author: Automated System
Date: December 31, 2025
Version: 1.0
"""

import pandas as pd
import numpy as np
import json
import os
from datetime import datetime, timedelta
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# CONFIGURATION
# ============================================================================

class BehaviorConfig:
    """Configuration for behavior data collection"""
    
    # Data collection intervals
    COLLECTION_INTERVAL_MINUTES = 30  # Collect data every 30 minutes (48 points per day)
    
    # Minimum data requirements
    MIN_HOURS_FOR_ANALYSIS = 12      # Minimum 12 hours before analysis
    RECOMMENDED_HOURS = 24           # Recommended 24 hours for reliable analysis
    BASELINE_CREATION_DAYS = 7       # Need 7 days to create individual baseline
    
    # Storage
    BEHAVIOR_DATA_DIR = 'behavior_data'
    BEHAVIOR_HISTORY_FILE = 'behavior_history.csv'
    COW_BASELINES_FILE = 'cow_baselines.json'
    
    # Normal ranges (population averages)
    NORMAL_RANGES = {
        'eating_time_per_hour': (7, 15),      # 7-15 minutes per hour = 180-300 min/day
        'lying_time_per_hour': (0.4, 0.6),    # 40-60% of hour lying = 10-14 hrs/day
        'steps_per_hour': (125, 250),          # 125-250 steps/hour = 3000-6000/day
        'rumination_time_per_hour': (16, 25), # 16-25 min/hour = 400-600 min/day
        'temperature': (37.5, 39.5)            # Normal body temperature
    }
    
    # Abnormality thresholds
    DEVIATION_THRESHOLDS = {
        'eating': 0.30,      # 30% deviation from baseline = abnormal
        'lying': 0.25,       # 25% deviation
        'steps': 0.35,       # 35% deviation
        'rumination': 0.30,  # 30% deviation
        'temperature': 0.5   # 0.5°C deviation
    }

# ============================================================================
# BEHAVIOR DATA COLLECTION
# ============================================================================

class BehaviorDataCollector:
    """Collect and store behavior data over time"""
    
    def __init__(self, data_dir=None):
        self.data_dir = data_dir or BehaviorConfig.BEHAVIOR_DATA_DIR
        os.makedirs(self.data_dir, exist_ok=True)
        self.history_file = os.path.join(self.data_dir, BehaviorConfig.BEHAVIOR_HISTORY_FILE)
        self.baselines_file = os.path.join(self.data_dir, BehaviorConfig.COW_BASELINES_FILE)
        
        # Load existing data
        self.history_df = self._load_history()
        self.baselines = self._load_baselines()
    
    def _load_history(self):
        """Load historical behavior data"""
        if os.path.exists(self.history_file):
            return pd.read_csv(self.history_file, parse_dates=['timestamp'])
        else:
            return pd.DataFrame(columns=[
                'cow_id', 'timestamp', 'eating_time_per_hour', 'lying_time_per_hour',
                'steps_per_hour', 'rumination_time_per_hour', 'temperature'
            ])
    
    def _load_baselines(self):
        """Load individual cow baselines"""
        if os.path.exists(self.baselines_file):
            with open(self.baselines_file, 'r') as f:
                return json.load(f)
        else:
            return {}
    
    def save_snapshot(self, cow_id, eating_time_per_hour, lying_time_per_hour,
                     steps_per_hour, rumination_time_per_hour, temperature,
                     timestamp=None):
        """
        Save a single behavior snapshot (called every 30 minutes)
        
        Parameters:
        - cow_id: Unique cow identifier
        - eating_time_per_hour: Minutes spent eating in last hour
        - lying_time_per_hour: Fraction of hour spent lying (0-1)
        - steps_per_hour: Steps taken in last hour
        - rumination_time_per_hour: Minutes ruminating in last hour
        - temperature: Current body temperature
        - timestamp: When snapshot was taken (default: now)
        
        Returns:
        - snapshot_id: Unique identifier for this snapshot
        """
        
        if timestamp is None:
            timestamp = datetime.now()
        
        # Create snapshot record
        snapshot = {
            'cow_id': cow_id,
            'timestamp': timestamp,
            'eating_time_per_hour': eating_time_per_hour,
            'lying_time_per_hour': lying_time_per_hour,
            'steps_per_hour': steps_per_hour,
            'rumination_time_per_hour': rumination_time_per_hour,
            'temperature': temperature
        }
        
        # Add to history
        self.history_df = pd.concat([
            self.history_df,
            pd.DataFrame([snapshot])
        ], ignore_index=True)
        
        # Save to disk (append mode for efficiency)
        if len(self.history_df) == 1:
            # First record - create file with headers
            self.history_df.to_csv(self.history_file, index=False)
        else:
            # Append without headers
            pd.DataFrame([snapshot]).to_csv(self.history_file, mode='a', header=False, index=False)
        
        print(f"✅ Snapshot saved: Cow {cow_id} at {timestamp.strftime('%Y-%m-%d %H:%M')}")
        
        # Check if enough data for analysis
        hours_collected = self.get_hours_of_data(cow_id)
        print(f"   Total data collected: {hours_collected:.1f} hours")
        
        if hours_collected >= BehaviorConfig.MIN_HOURS_FOR_ANALYSIS:
            print(f"   ✅ Sufficient data for analysis!")
        else:
            hours_needed = BehaviorConfig.MIN_HOURS_FOR_ANALYSIS - hours_collected
            print(f"   ⏳ Need {hours_needed:.1f} more hours for reliable analysis")
        
        return len(self.history_df) - 1  # Return snapshot ID
    
    def get_cow_data(self, cow_id, hours=24):
        """
        Get recent behavior data for a specific cow
        
        Parameters:
        - cow_id: Cow identifier
        - hours: How many hours of data to retrieve
        
        Returns:
        - DataFrame with recent behavior snapshots
        """
        cow_data = self.history_df[self.history_df['cow_id'] == cow_id].copy()
        
        if len(cow_data) == 0:
            return pd.DataFrame()
        
        # Get data from last N hours
        cutoff_time = datetime.now() - timedelta(hours=hours)
        recent_data = cow_data[cow_data['timestamp'] >= cutoff_time]
        
        return recent_data.sort_values('timestamp')
    
    def get_hours_of_data(self, cow_id):
        """Calculate how many hours of data we have for a cow"""
        cow_data = self.history_df[self.history_df['cow_id'] == cow_id]
        
        if len(cow_data) == 0:
            return 0.0
        
        # Time span from first to last record
        time_span = (cow_data['timestamp'].max() - cow_data['timestamp'].min())
        return time_span.total_seconds() / 3600
    
    def create_baseline(self, cow_id, days=7):
        """
        Create individual baseline from historical data
        
        Requires at least 7 days of healthy behavior data
        
        Parameters:
        - cow_id: Cow identifier
        - days: Days of data to use (default: 7)
        
        Returns:
        - baseline: Dictionary with normal values for this cow
        """
        
        print(f"\n📊 Creating baseline for Cow {cow_id}...")
        
        # Get data from last N days
        cow_data = self.get_cow_data(cow_id, hours=days*24)
        
        if len(cow_data) < days * 24 / (BehaviorConfig.COLLECTION_INTERVAL_MINUTES / 60):
            print(f"❌ Insufficient data: Need {days} days of data")
            return None
        
        # Calculate averages (remove outliers first)
        baseline = {
            'cow_id': cow_id,
            'created_date': datetime.now().isoformat(),
            'data_points': len(cow_data),
            'eating_time_per_hour': float(cow_data['eating_time_per_hour'].median()),
            'lying_time_per_hour': float(cow_data['lying_time_per_hour'].median()),
            'steps_per_hour': float(cow_data['steps_per_hour'].median()),
            'rumination_time_per_hour': float(cow_data['rumination_time_per_hour'].median()),
            'temperature': float(cow_data['temperature'].median()),
            # Also store standard deviations for anomaly detection
            'eating_std': float(cow_data['eating_time_per_hour'].std()),
            'lying_std': float(cow_data['lying_time_per_hour'].std()),
            'steps_std': float(cow_data['steps_per_hour'].std()),
            'rumination_std': float(cow_data['rumination_time_per_hour'].std()),
            'temperature_std': float(cow_data['temperature'].std())
        }
        
        # Save to baselines
        self.baselines[cow_id] = baseline
        
        with open(self.baselines_file, 'w') as f:
            json.dump(self.baselines, f, indent=2)
        
        print(f"✅ Baseline created successfully!")
        print(f"   Eating: {baseline['eating_time_per_hour']:.1f} min/hour")
        print(f"   Lying: {baseline['lying_time_per_hour']:.2f} fraction/hour")
        print(f"   Steps: {baseline['steps_per_hour']:.0f} steps/hour")
        print(f"   Rumination: {baseline['rumination_time_per_hour']:.1f} min/hour")
        print(f"   Temperature: {baseline['temperature']:.1f}°C")
        
        return baseline
    
    def get_baseline(self, cow_id):
        """Get baseline for a cow (if exists)"""
        return self.baselines.get(cow_id, None)

# ============================================================================
# BEHAVIOR ANALYSIS
# ============================================================================

class BehaviorAnalyzer:
    """Analyze accumulated behavior data to detect abnormalities"""
    
    def __init__(self, collector):
        self.collector = collector
    
    def analyze_cow(self, cow_id, hours=24):
        """
        Analyze accumulated behavior data for a cow
        
        Parameters:
        - cow_id: Cow identifier
        - hours: How many hours of data to analyze
        
        Returns:
        - status: 'NORMAL', 'ABNORMAL', or 'INSUFFICIENT_DATA'
        - abnormalities: List of detected issues
        - confidence: 0-1 (confidence in assessment)
        - metrics: Detailed metrics
        """
        
        print(f"\n🔍 Analyzing behavior for Cow {cow_id}")
        print("=" * 60)
        
        # Get recent data
        cow_data = self.collector.get_cow_data(cow_id, hours=hours)
        
        if len(cow_data) == 0:
            print("❌ No data available for this cow")
            return 'INSUFFICIENT_DATA', [], 0.0, {}
        
        # Check if enough data
        hours_available = self.collector.get_hours_of_data(cow_id)
        
        if hours_available < BehaviorConfig.MIN_HOURS_FOR_ANALYSIS:
            print(f"⚠️ Insufficient data: {hours_available:.1f} hours")
            print(f"   Minimum required: {BehaviorConfig.MIN_HOURS_FOR_ANALYSIS} hours")
            return 'INSUFFICIENT_DATA', [], hours_available / BehaviorConfig.MIN_HOURS_FOR_ANALYSIS, {}
        
        # Calculate current averages from recent data
        current_metrics = {
            'eating_time_per_hour': cow_data['eating_time_per_hour'].mean(),
            'lying_time_per_hour': cow_data['lying_time_per_hour'].mean(),
            'steps_per_hour': cow_data['steps_per_hour'].mean(),
            'rumination_time_per_hour': cow_data['rumination_time_per_hour'].mean(),
            'temperature': cow_data['temperature'].mean(),
            'data_points': len(cow_data),
            'time_span_hours': hours_available
        }
        
        # Get baseline (individual or population)
        baseline = self.collector.get_baseline(cow_id)
        using_individual_baseline = baseline is not None
        
        if baseline:
            print(f"✅ Using INDIVIDUAL baseline for Cow {cow_id}")
        else:
            print(f"📊 Using POPULATION norms (no individual baseline)")
            baseline = {
                'eating_time_per_hour': 10,    # Population average
                'lying_time_per_hour': 0.5,
                'steps_per_hour': 180,
                'rumination_time_per_hour': 20,
                'temperature': 38.5
            }
        
        # Detect abnormalities
        abnormalities = []
        deviation_scores = []
        
        # Check eating
        eating_deviation = abs(current_metrics['eating_time_per_hour'] - baseline['eating_time_per_hour']) / baseline['eating_time_per_hour']
        if eating_deviation > BehaviorConfig.DEVIATION_THRESHOLDS['eating']:
            direction = "↓" if current_metrics['eating_time_per_hour'] < baseline['eating_time_per_hour'] else "↑"
            abnormalities.append(f"Eating time {direction}{eating_deviation*100:.0f}% from baseline")
            deviation_scores.append(eating_deviation)
        
        # Check lying
        lying_deviation = abs(current_metrics['lying_time_per_hour'] - baseline['lying_time_per_hour']) / baseline['lying_time_per_hour']
        if lying_deviation > BehaviorConfig.DEVIATION_THRESHOLDS['lying']:
            direction = "↑" if current_metrics['lying_time_per_hour'] > baseline['lying_time_per_hour'] else "↓"
            abnormalities.append(f"Lying time {direction}{lying_deviation*100:.0f}% from baseline")
            deviation_scores.append(lying_deviation)
        
        # Check steps
        steps_deviation = abs(current_metrics['steps_per_hour'] - baseline['steps_per_hour']) / baseline['steps_per_hour']
        if steps_deviation > BehaviorConfig.DEVIATION_THRESHOLDS['steps']:
            direction = "↓" if current_metrics['steps_per_hour'] < baseline['steps_per_hour'] else "↑"
            abnormalities.append(f"Activity level {direction}{steps_deviation*100:.0f}% from baseline")
            deviation_scores.append(steps_deviation)
        
        # Check rumination
        rumination_deviation = abs(current_metrics['rumination_time_per_hour'] - baseline['rumination_time_per_hour']) / baseline['rumination_time_per_hour']
        if rumination_deviation > BehaviorConfig.DEVIATION_THRESHOLDS['rumination']:
            direction = "↓" if current_metrics['rumination_time_per_hour'] < baseline['rumination_time_per_hour'] else "↑"
            abnormalities.append(f"Rumination {direction}{rumination_deviation*100:.0f}% from baseline")
            deviation_scores.append(rumination_deviation)
        
        # Check temperature
        temp_deviation = abs(current_metrics['temperature'] - baseline['temperature'])
        if temp_deviation > BehaviorConfig.DEVIATION_THRESHOLDS['temperature']:
            direction = "↑" if current_metrics['temperature'] > baseline['temperature'] else "↓"
            abnormalities.append(f"Temperature {direction}{temp_deviation:.1f}°C from normal")
            deviation_scores.append(temp_deviation / 2.0)  # Normalize to 0-1 scale
        
        # Calculate overall confidence
        data_quality = min(hours_available / BehaviorConfig.RECOMMENDED_HOURS, 1.0)
        baseline_quality = 1.0 if using_individual_baseline else 0.7
        
        if len(deviation_scores) > 0:
            avg_deviation = np.mean(deviation_scores)
            confidence = avg_deviation * data_quality * baseline_quality
        else:
            confidence = 0.9 * data_quality * baseline_quality
        
        # Determine status
        if len(abnormalities) >= 2:
            status = 'ABNORMAL'
            print(f"🚨 Status: ABNORMAL")
        elif len(abnormalities) == 1 and deviation_scores[0] > 0.5:
            status = 'ABNORMAL'
            print(f"⚠️ Status: ABNORMAL (major deviation)")
        else:
            status = 'NORMAL'
            print(f"✅ Status: NORMAL")
        
        print(f"\nData Quality:")
        print(f"  Time span: {hours_available:.1f} hours")
        print(f"  Data points: {len(cow_data)}")
        print(f"  Baseline type: {'Individual' if using_individual_baseline else 'Population'}")
        print(f"  Confidence: {confidence:.2%}")
        
        print(f"\nCurrent Metrics (vs Baseline):")
        print(f"  Eating: {current_metrics['eating_time_per_hour']:.1f} min/hr (baseline: {baseline['eating_time_per_hour']:.1f})")
        print(f"  Lying: {current_metrics['lying_time_per_hour']:.2f} (baseline: {baseline['lying_time_per_hour']:.2f})")
        print(f"  Steps: {current_metrics['steps_per_hour']:.0f} steps/hr (baseline: {baseline['steps_per_hour']:.0f})")
        print(f"  Rumination: {current_metrics['rumination_time_per_hour']:.1f} min/hr (baseline: {baseline['rumination_time_per_hour']:.1f})")
        print(f"  Temperature: {current_metrics['temperature']:.1f}°C (baseline: {baseline['temperature']:.1f}°C)")
        
        if abnormalities:
            print(f"\n⚠️ Detected Abnormalities:")
            for issue in abnormalities:
                print(f"  • {issue}")
        
        return status, abnormalities, confidence, current_metrics

# ============================================================================
# USAGE EXAMPLE
# ============================================================================

if __name__ == "__main__":
    
    print("\n" + "="*70)
    print("🧪 TESTING BEHAVIOR DATA COLLECTION & ANALYSIS")
    print("="*70 + "\n")
    
    # Initialize
    collector = BehaviorDataCollector()
    analyzer = BehaviorAnalyzer(collector)
    
    # ========================================================================
    # SCENARIO: Collect data over 24 hours for Cow SL-001
    # ========================================================================
    
    print("📊 SCENARIO: 24-Hour Monitoring of Cow SL-001")
    print("-" * 70)
    
    cow_id = "SL-001"
    start_time = datetime.now() - timedelta(hours=24)  # Simulate 24 hours ago
    
    print(f"\nSimulating data collection every {BehaviorConfig.COLLECTION_INTERVAL_MINUTES} minutes...")
    print(f"(In production, this would happen automatically)")
    
    # Simulate collecting data every 30 minutes for 24 hours
    hours_to_simulate = 24
    intervals_per_hour = 60 / BehaviorConfig.COLLECTION_INTERVAL_MINUTES
    total_snapshots = int(hours_to_simulate * intervals_per_hour)
    
    print(f"\nCollecting {total_snapshots} snapshots over {hours_to_simulate} hours...\n")
    
    # Day 1-20: Healthy baseline data
    print("📅 Days 1-6: Collecting healthy baseline data (for individual baseline creation)...")
    for day in range(7):
        for hour in range(24):
            for interval in range(int(intervals_per_hour)):
                timestamp = start_time - timedelta(days=(6-day), hours=(23-hour), minutes=(30*interval))
                
                # Normal healthy behavior with small variations
                collector.save_snapshot(
                    cow_id=cow_id,
                    eating_time_per_hour=np.random.normal(10, 1.5),  # Avg 10 min/hr, small variance
                    lying_time_per_hour=np.random.normal(0.5, 0.05),  # 50% lying
                    steps_per_hour=np.random.normal(180, 20),          # 180 steps/hr
                    rumination_time_per_hour=np.random.normal(20, 2),  # 20 min/hr
                    temperature=np.random.normal(38.5, 0.2),           # Normal temp
                    timestamp=timestamp
                )
    
    print(f"\n✅ Baseline data collected: 7 days")
    
    # Create individual baseline
    baseline = collector.create_baseline(cow_id, days=7)
    
    print("\n" + "-" * 70)
    print("\n📅 Day 8: Today - Monitoring for abnormal behavior...")
    
    # Today: First 12 hours normal, then cow gets sick
    for hour in range(24):
        for interval in range(int(intervals_per_hour)):
            timestamp = start_time + timedelta(hours=hour, minutes=(30*interval))
            
            if hour < 12:
                # Morning: Still normal
                eating = np.random.normal(10, 1.5)
                lying = np.random.normal(0.5, 0.05)
                steps = np.random.normal(180, 20)
                rumination = np.random.normal(20, 2)
                temperature = np.random.normal(38.5, 0.2)
            else:
                # Afternoon: Cow getting sick (gradual decline)
                decline_factor = (hour - 12) / 12  # Gradually worse
                eating = np.random.normal(10 * (1 - 0.5 * decline_factor), 1)  # Eating drops
                lying = np.random.normal(0.5 * (1 + 0.4 * decline_factor), 0.05)  # Lying increases
                steps = np.random.normal(180 * (1 - 0.4 * decline_factor), 15)  # Activity drops
                rumination = np.random.normal(20 * (1 - 0.4 * decline_factor), 1.5)  # Rumination drops
                temperature = np.random.normal(38.5 + 1.5 * decline_factor, 0.2)  # Fever develops
            
            snapshot_id = collector.save_snapshot(
                cow_id=cow_id,
                eating_time_per_hour=max(0, eating),
                lying_time_per_hour=min(1, max(0, lying)),
                steps_per_hour=max(0, steps),
                rumination_time_per_hour=max(0, rumination),
                temperature=temperature,
                timestamp=timestamp
            )
    
    # ========================================================================
    # ANALYZE AT DIFFERENT TIME POINTS
    # ========================================================================
    
    print("\n" + "="*70)
    print("📊 ANALYSIS AT DIFFERENT TIME POINTS")
    print("="*70)
    
    # Analysis after 6 hours (morning - still normal)
    print("\n⏰ TIME POINT 1: After 6 hours (Morning)")
    print("-" * 70)
    # This would need to filter data, but for simulation we just show the concept
    
    # Analysis after 12 hours (noon - transition point)
    print("\n⏰ TIME POINT 2: After 12 hours (Noon)")
    print("-" * 70)
    
    # Analysis after 24 hours (end of day - clearly abnormal)
    print("\n⏰ TIME POINT 3: After 24 hours (End of Day)")
    print("-" * 70)
    status, abnormalities, confidence, metrics = analyzer.analyze_cow(cow_id, hours=24)
    
    print("\n" + "="*70)
    print("📋 FINAL ANALYSIS RESULT")
    print("="*70)
    print(f"Status: {status}")
    print(f"Confidence: {confidence:.2%}")
    print(f"Abnormalities: {len(abnormalities)}")
    
    if status == 'ABNORMAL':
        print("\n🚨 ALERT: Abnormal behavior detected!")
        print("📸 Recommended: Take photos for disease detection")
        print("👁️ Recommended: Monitor closely and prepare for veterinary visit")
    
    print("\n" + "="*70)
    print("✅ TEST COMPLETED")
    print("="*70)
