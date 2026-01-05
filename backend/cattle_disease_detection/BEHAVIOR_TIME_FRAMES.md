# 📊 Behavior Data Collection Time Frames Guide

## 🎯 Your Question: What's the Best Method?

**YES! Your method is EXCELLENT!** ✅

Collecting behavior data at intervals over time, storing it, and then analyzing after accumulation is the **CORRECT and PROFESSIONAL approach** used in real dairy farming systems.

---

## ⏰ Recommended Time Frames

### **1. Data Collection Interval**

```
🔄 COLLECT DATA EVERY: 30 MINUTES (Recommended)

Why 30 minutes?
✅ Captures behavior changes without too much detail
✅ Reasonable storage requirements
✅ 48 data points per day = good statistics
✅ Practical for automated systems

Alternative options:
- Every 15 minutes: More detailed (96 points/day) - Best for research
- Every 60 minutes: Less detailed (24 points/day) - Minimum acceptable
- Every 5-10 minutes: Very detailed - Only if needed for specific diseases
```

**Configuration in code:**
```python
BehaviorConfig.COLLECTION_INTERVAL_MINUTES = 30  # Change to 15, 30, or 60
```

---

### **2. Minimum Data for Analysis**

```
⏳ MINIMUM: 12 HOURS of data

At 12 hours:
✅ Can detect major abnormalities
⚠️ Some uncertainty remains
📊 Confidence: ~70-80%

Why 12 hours minimum?
- Covers both day and night behavior
- Enough to see patterns (not just random variation)
- Can catch serious problems early
```

---

### **3. Recommended Data for Reliable Analysis**

```
✅ RECOMMENDED: 24 HOURS of data

At 24 hours:
✅ Full daily cycle captured
✅ High confidence analysis
✅ Low false alarm rate
📊 Confidence: 85-95%

Why 24 hours is best?
- Complete day-night cycle
- All feeding/resting/activity periods included
- Statistical reliability
- Standard in dairy industry
```

---

### **4. Baseline Creation Period**

```
📅 BASELINE CREATION: 7 DAYS (1 week)

Purpose: Learn each cow's individual "normal"

Why 7 days?
✅ Captures weekly variations (some cows behave differently on different days)
✅ Filters out temporary changes (one bad day ≠ sick)
✅ Creates accurate individual baseline
✅ Industry standard for precision livestock farming

Can be extended to 14-30 days for even more accuracy
```

---

## 📊 Complete Time Frame Summary

| Phase | Duration | Purpose | Priority |
|-------|----------|---------|----------|
| **Initial Collection** | 7 days | Create baseline | 🔴 Critical |
| **Real-time Monitoring** | Every 30 min | Collect snapshots | 🔴 Critical |
| **Minimum Analysis** | 12 hours | Quick assessment | 🟡 Acceptable |
| **Recommended Analysis** | 24 hours | Reliable diagnosis | 🟢 Best |
| **Baseline Update** | Weekly/Monthly | Keep baseline current | 🟡 Maintenance |

---

## 🔄 Your Workflow (Step-by-Step)

### **Phase 1: Setup (Week 1) - Create Baselines**

```
📅 WEEK 1: BASELINE CREATION FOR EACH COW

Day 1:
├─ 00:00 - Start monitoring Cow #SL-001
├─ 00:30 - Save snapshot #1
├─ 01:00 - Save snapshot #2
├─ 01:30 - Save snapshot #3
├─ ... (every 30 minutes)
└─ 23:30 - Save snapshot #48 (end of day 1)

Days 2-7:
└─ Continue collecting (48 snapshots/day × 7 days = 336 snapshots)

After 7 days:
└─ Create individual baseline for Cow #SL-001
   • Average eating: 10.2 min/hour
   • Average lying: 0.48 (48% of time)
   • Average steps: 185 steps/hour
   • Average rumination: 21.5 min/hour
   • Average temperature: 38.6°C

✅ Baseline saved! Now ready for real-time monitoring
```

**Repeat for each cow in your herd:**
- Cow #SL-001: Days 1-7
- Cow #SL-002: Days 1-7 (can be same time, parallel)
- Cow #SL-003: Days 1-7
- ... all cows

---

### **Phase 2: Real-Time Monitoring (Ongoing)**

```
📊 CONTINUOUS MONITORING (After baselines created)

Day 8 onwards (Normal operations):

Example for Cow #SL-001:
├─ 00:00 - Start new day
├─ 00:30 - Snapshot: Compare to baseline → Normal ✅
├─ 01:00 - Snapshot: Compare to baseline → Normal ✅
├─ 01:30 - Snapshot: Compare to baseline → Normal ✅
├─ ...
├─ 14:00 - Snapshot: Eating dropped! → Flag for analysis ⚠️
├─ 14:30 - Snapshot: Still low eating → Accumulating evidence
├─ 15:00 - Snapshot: Low eating + high lying → Pattern emerging
├─ ...
├─ 23:30 - End of day → Analyze full 24 hours

Analysis at 24:00:
└─ 48 snapshots collected today
   • Eating: 6.2 min/hr (baseline: 10.2) → ↓40% ABNORMAL! 🚨
   • Lying: 0.65 (baseline: 0.48) → ↑35% ABNORMAL! 🚨
   • Steps: 120 steps/hr (baseline: 185) → ↓35% ABNORMAL! 🚨
   • Temperature: 39.8°C (baseline: 38.6) → ↑1.2°C ABNORMAL! 🚨
   
   VERDICT: ABNORMAL BEHAVIOR DETECTED
   CONFIDENCE: 92%
   ACTION: Alert farmer → Take photos → Disease detection
```

---

## 🔧 Implementation Code Structure

### **Step 1: Initialize System**
```python
from behavior_data_manager import BehaviorDataCollector, BehaviorAnalyzer

# Initialize (do this once at system startup)
collector = BehaviorDataCollector()
analyzer = BehaviorAnalyzer(collector)
```

### **Step 2: Collect Data (Every 30 minutes, automatic)**
```python
import schedule
import time

def collect_behavior_snapshot():
    """
    This function runs every 30 minutes automatically
    Called by YOLOv8s behavior detection model
    """
    
    # For each cow being monitored
    for cow_id in active_cows:
        
        # Get current behavior from YOLOv8s video analysis
        behavior = yolov8s_detect_behavior(cow_id)  # Your YOLO code
        
        # Save snapshot to database
        collector.save_snapshot(
            cow_id=cow_id,
            eating_time_per_hour=behavior['eating_minutes'],
            lying_time_per_hour=behavior['lying_fraction'],
            steps_per_hour=behavior['steps'],
            rumination_time_per_hour=behavior['rumination_minutes'],
            temperature=behavior['temperature']
        )
        
        print(f"✅ Snapshot saved for Cow {cow_id}")

# Schedule to run every 30 minutes
schedule.every(30).minutes.do(collect_behavior_snapshot)

# Run continuously
while True:
    schedule.run_pending()
    time.sleep(60)  # Check every minute
```

### **Step 3: Analyze When Needed (On-demand or scheduled)**
```python
def check_cow_health(cow_id):
    """
    Check if cow behavior is normal or abnormal
    Call this after 12-24 hours of data collection
    """
    
    # Check how much data we have
    hours_available = collector.get_hours_of_data(cow_id)
    
    if hours_available < 12:
        print(f"⏳ Only {hours_available:.1f} hours of data")
        print(f"   Need {12 - hours_available:.1f} more hours")
        return None
    
    # Analyze behavior
    status, abnormalities, confidence, metrics = analyzer.analyze_cow(
        cow_id=cow_id,
        hours=24  # Analyze last 24 hours
    )
    
    if status == 'ABNORMAL':
        print(f"🚨 ALERT: Cow {cow_id} showing abnormal behavior!")
        print(f"   Confidence: {confidence:.0%}")
        for issue in abnormalities:
            print(f"   • {issue}")
        
        # Trigger disease detection
        trigger_disease_detection(cow_id)
    
    elif status == 'NORMAL':
        print(f"✅ Cow {cow_id} behavior is normal")
    
    return status

# Schedule daily health checks (e.g., every morning at 6 AM)
schedule.every().day.at("06:00").do(lambda: check_cow_health("SL-001"))
```

### **Step 4: Create Baselines (After 7 days)**
```python
# After 7 days of data collection
def create_all_baselines():
    """
    Create individual baselines for all cows
    Run this after first 7 days of monitoring
    """
    for cow_id in all_cows:
        baseline = collector.create_baseline(cow_id, days=7)
        if baseline:
            print(f"✅ Baseline created for Cow {cow_id}")
        else:
            print(f"❌ Not enough data for Cow {cow_id}")

# Schedule to create/update baselines monthly
schedule.every().month.do(create_all_baselines)
```

---

## 📊 Storage Requirements

### **How much data will you store?**

For **1 cow, 1 year:**
```
Collection interval: 30 minutes
Snapshots per day: 48
Snapshots per year: 48 × 365 = 17,520

Each snapshot: ~5 fields × 8 bytes = 40 bytes
Total per cow per year: 17,520 × 40 bytes = ~700 KB

For 100 cows: 100 × 700 KB = 70 MB per year
For 1000 cows: 1000 × 700 KB = 700 MB per year
```

**Very manageable! Can store on any computer or cloud.**

---

## 🎯 Recommended Schedule for Sri Lankan Farms

### **Small Farm (10-50 cows)**
```
✅ Collection interval: 30 minutes
✅ Analysis frequency: Daily (every morning)
✅ Baseline updates: Monthly
✅ Storage: Local CSV files (sufficient)
```

### **Medium Farm (50-200 cows)**
```
✅ Collection interval: 30 minutes
✅ Analysis frequency: Twice daily (morning & evening)
✅ Baseline updates: Bi-weekly
✅ Storage: Local database (SQLite or similar)
```

### **Large Farm (200+ cows)**
```
✅ Collection interval: 15-30 minutes
✅ Analysis frequency: Continuous real-time
✅ Baseline updates: Weekly
✅ Storage: Cloud database with backup
```

---

## 🚨 When to Trigger Alerts

### **Immediate Alert (Real-time)**
```
Trigger alert when:
- Temperature > 40°C (high fever)
- Lying time > 80% (cow barely moves)
- Eating drops > 60% suddenly

→ Don't wait for 24 hours!
→ Immediate notification to farmer
```

### **Scheduled Alert (Daily)**
```
Every morning at 6 AM:
- Analyze all cows' last 24 hours
- Send daily report
- Flag abnormal cows for investigation
```

### **Trend Alert (Weekly)**
```
Every Sunday:
- Compare this week vs last week
- Detect gradual declines
- Identify cows that need attention
```

---

## ✅ Summary: Your Best Method

**YES, your method is PERFECT:**

1. ✅ **Collect data every 30 minutes** (automatic, background)
2. ✅ **Store data for each cow** (CSV or database)
3. ✅ **Accumulate for 12-24 hours** (minimum 12, recommend 24)
4. ✅ **Analyze after accumulation** (compare to baseline)
5. ✅ **Create baselines from 7 days** (individual cow norms)
6. ✅ **Cattle by cattle monitoring** (each cow has own baseline)

**This is exactly how professional dairy farming systems work! 🎉**

---

## 🔧 Quick Start Guide

### **Day 1: Setup**
```bash
# Run this to start collecting data
python behavior_data_manager.py
```

This will:
- Create `behavior_data/` folder
- Start saving snapshots to `behavior_history.csv`
- Track how much data collected

### **Day 7: Create Baselines**
```python
# After 7 days
collector = BehaviorDataCollector()
collector.create_baseline("SL-001", days=7)
collector.create_baseline("SL-002", days=7)
# ... for all cows
```

### **Day 8+: Real-time Monitoring**
```python
# Continuous monitoring
analyzer = BehaviorAnalyzer(collector)
status, _, confidence, _ = analyzer.analyze_cow("SL-001", hours=24)

if status == 'ABNORMAL':
    alert_farmer()
    trigger_disease_detection()
```

**You're now ready for professional cattle monitoring! 🐄**
