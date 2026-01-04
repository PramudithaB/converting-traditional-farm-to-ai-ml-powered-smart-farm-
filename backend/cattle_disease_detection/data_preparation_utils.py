"""
Data Preparation Utilities for Cattle Disease Detection
========================================================

This script helps organize your disease dataset for training:
1. Maps CSV severity labels to images
2. Organizes images by disease class
3. Creates severity-based folder structure
4. Splits data into train/val/test sets
5. Generates dataset statistics

Author: Cattle Disease Detection Team
Date: 2025-12-30
"""

import os
import shutil
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.model_selection import train_test_split
import json
from collections import defaultdict
import cv2
from tqdm import tqdm


class CattleDatasetOrganizer:
    """
    Organizes cattle disease images for model training
    """
    
    def __init__(self, csv_path, source_image_dir, output_dir):
        """
        Args:
            csv_path: Path to cattle_treatment_dataset.csv
            source_image_dir: Directory containing disease images
            output_dir: Base directory for organized dataset
        """
        self.csv_path = csv_path
        self.source_image_dir = Path(source_image_dir)
        self.output_dir = Path(output_dir)
        self.df = None
        
    def load_data(self):
        """Load CSV data"""
        self.df = pd.read_csv(self.csv_path)
        print(f"✅ Loaded {len(self.df)} records from CSV")
        print(f"\nDisease Distribution:")
        print(self.df['Disease'].value_counts())
        print(f"\nSeverity Distribution:")
        print(self.df['Severity'].value_counts())
        
    def organize_by_disease(self, copy_files=True):
        """
        Organize images by disease type
        
        Args:
            copy_files: If True, copy files. If False, create symlinks
        """
        disease_dir = self.output_dir / 'disease_by_class'
        disease_dir.mkdir(parents=True, exist_ok=True)
        
        # Get unique diseases (excluding healthy)
        diseases = self.df[self.df['Disease'] != 'Healthy']['Disease'].unique()
        
        # Create disease folders
        for disease in diseases:
            (disease_dir / disease).mkdir(exist_ok=True)
        
        # Add healthy folder
        (disease_dir / 'healthy').mkdir(exist_ok=True)
        
        print(f"\n✅ Created {len(diseases) + 1} disease class folders in {disease_dir}")
        print("\n⚠️  NOTE: You need to manually copy your disease images into these folders")
        print("   Each folder should contain images of that specific disease")
        
        return disease_dir
    
    def organize_by_severity(self, copy_files=True):
        """
        Organize disease images by severity level
        
        Args:
            copy_files: If True, copy files. If False, create symlinks
        """
        severity_dir = self.output_dir / 'disease_by_severity'
        severity_dir.mkdir(parents=True, exist_ok=True)
        
        # Create severity folders
        severity_map = {0: 'Mild', 1: 'Moderate', 2: 'Severe'}
        for severity_name in severity_map.values():
            (severity_dir / severity_name).mkdir(exist_ok=True)
        
        print(f"\n✅ Created severity folders in {severity_dir}")
        print("   - Mild (Severity 0)")
        print("   - Moderate (Severity 1)")
        print("   - Severe (Severity 2)")
        print("\n⚠️  NOTE: Organize your disease images by severity level")
        
        return severity_dir
    
    def split_dataset(self, source_dir, train_ratio=0.7, val_ratio=0.2, test_ratio=0.1, seed=42):
        """
        Split dataset into train/val/test sets
        
        Args:
            source_dir: Directory containing organized images
            train_ratio: Ratio for training set
            val_ratio: Ratio for validation set
            test_ratio: Ratio for test set
            seed: Random seed
        """
        source_path = Path(source_dir)
        
        # Get all class folders
        classes = [d for d in source_path.iterdir() if d.is_dir()]
        
        if not classes:
            print("❌ No class folders found!")
            return
        
        # Create split directories
        splits = ['train', 'val', 'test']
        split_dirs = {}
        
        for split in splits:
            split_dir = self.output_dir / f'{source_path.name}_split' / split
            split_dir.mkdir(parents=True, exist_ok=True)
            split_dirs[split] = split_dir
            
            # Create class folders in each split
            for class_folder in classes:
                (split_dir / class_folder.name).mkdir(exist_ok=True)
        
        # Split images for each class
        stats = defaultdict(lambda: defaultdict(int))
        
        for class_folder in tqdm(classes, desc="Splitting dataset"):
            class_name = class_folder.name
            images = list(class_folder.glob('*.[jp][pn][g]'))  # jpg, jpeg, png
            
            if not images:
                print(f"⚠️  No images found in {class_name}")
                continue
            
            # Split data
            train_imgs, temp_imgs = train_test_split(
                images, train_size=train_ratio, random_state=seed
            )
            val_imgs, test_imgs = train_test_split(
                temp_imgs, 
                train_size=val_ratio/(val_ratio + test_ratio),
                random_state=seed
            )
            
            # Copy/move images
            for img_path in train_imgs:
                dest = split_dirs['train'] / class_name / img_path.name
                shutil.copy2(img_path, dest)
                stats[class_name]['train'] += 1
            
            for img_path in val_imgs:
                dest = split_dirs['val'] / class_name / img_path.name
                shutil.copy2(img_path, dest)
                stats[class_name]['val'] += 1
            
            for img_path in test_imgs:
                dest = split_dirs['test'] / class_name / img_path.name
                shutil.copy2(img_path, dest)
                stats[class_name]['test'] += 1
        
        # Print statistics
        print(f"\n✅ Dataset split completed!")
        print(f"\nSplit Directory: {self.output_dir / f'{source_path.name}_split'}")
        print("\nClass Distribution:")
        print(f"{'Class':<20} {'Train':<10} {'Val':<10} {'Test':<10} {'Total':<10}")
        print("-" * 60)
        
        for class_name in sorted(stats.keys()):
            train_count = stats[class_name]['train']
            val_count = stats[class_name]['val']
            test_count = stats[class_name]['test']
            total = train_count + val_count + test_count
            print(f"{class_name:<20} {train_count:<10} {val_count:<10} {test_count:<10} {total:<10}")
        
        # Save split info
        split_info = {
            'train_ratio': train_ratio,
            'val_ratio': val_ratio,
            'test_ratio': test_ratio,
            'seed': seed,
            'classes': list(stats.keys()),
            'statistics': dict(stats)
        }
        
        with open(self.output_dir / 'split_info.json', 'w') as f:
            json.dump(split_info, f, indent=4)
        
        return split_dirs
    
    def generate_statistics(self, image_dir):
        """
        Generate dataset statistics
        
        Args:
            image_dir: Directory containing images
        """
        image_path = Path(image_dir)
        
        stats = {
            'total_images': 0,
            'classes': {},
            'image_sizes': [],
            'aspect_ratios': []
        }
        
        # Get all class folders
        classes = [d for d in image_path.iterdir() if d.is_dir()]
        
        for class_folder in tqdm(classes, desc="Analyzing images"):
            class_name = class_folder.name
            images = list(class_folder.glob('*.[jp][pn][g]'))
            
            stats['classes'][class_name] = len(images)
            stats['total_images'] += len(images)
            
            # Sample some images for size analysis
            for img_path in images[:50]:  # Sample first 50
                try:
                    img = cv2.imread(str(img_path))
                    if img is not None:
                        h, w = img.shape[:2]
                        stats['image_sizes'].append((w, h))
                        stats['aspect_ratios'].append(w / h)
                except:
                    continue
        
        # Calculate statistics
        if stats['image_sizes']:
            widths, heights = zip(*stats['image_sizes'])
            stats['avg_width'] = int(np.mean(widths))
            stats['avg_height'] = int(np.mean(heights))
            stats['avg_aspect_ratio'] = np.mean(stats['aspect_ratios'])
        
        # Print report
        print("\n" + "="*60)
        print("DATASET STATISTICS REPORT")
        print("="*60)
        print(f"\nTotal Images: {stats['total_images']}")
        print(f"Total Classes: {len(stats['classes'])}")
        print(f"\nClass Distribution:")
        for class_name, count in sorted(stats['classes'].items(), key=lambda x: -x[1]):
            percentage = (count / stats['total_images']) * 100
            print(f"  {class_name:<20}: {count:>5} ({percentage:>5.2f}%)")
        
        if stats['image_sizes']:
            print(f"\nAverage Image Size: {stats['avg_width']}x{stats['avg_height']}")
            print(f"Average Aspect Ratio: {stats['avg_aspect_ratio']:.2f}")
        
        # Save statistics
        stats['image_sizes'] = []  # Remove for JSON serialization
        stats['aspect_ratios'] = []
        
        with open(self.output_dir / 'dataset_statistics.json', 'w') as f:
            json.dump(stats, f, indent=4)
        
        print(f"\n✅ Statistics saved to {self.output_dir / 'dataset_statistics.json'}")
        
        return stats


def main():
    """
    Main execution function
    """
    print("="*60)
    print("CATTLE DISEASE DATASET PREPARATION")
    print("="*60)
    
    # Configuration
    CSV_PATH = './datasets/cattle_treatment_dataset.csv'
    SOURCE_IMAGE_DIR = './datasets/disease_images'  # Update with your path
    OUTPUT_DIR = './datasets/organized'
    
    # Initialize organizer
    organizer = CattleDatasetOrganizer(CSV_PATH, SOURCE_IMAGE_DIR, OUTPUT_DIR)
    
    # Load data
    organizer.load_data()
    
    # Create folder structures
    print("\n" + "="*60)
    print("STEP 1: Organizing by Disease Class")
    print("="*60)
    disease_dir = organizer.organize_by_disease()
    
    print("\n" + "="*60)
    print("STEP 2: Organizing by Severity")
    print("="*60)
    severity_dir = organizer.organize_by_severity()
    
    # Generate statistics (if images exist)
    if os.path.exists(SOURCE_IMAGE_DIR) and any(Path(SOURCE_IMAGE_DIR).iterdir()):
        print("\n" + "="*60)
        print("STEP 3: Generating Statistics")
        print("="*60)
        organizer.generate_statistics(SOURCE_IMAGE_DIR)
        
        print("\n" + "="*60)
        print("STEP 4: Splitting Dataset")
        print("="*60)
        
        # Ask user which organization to split
        print("\nWhich organization to split?")
        print("1. By Disease Class")
        print("2. By Severity")
        choice = input("Enter choice (1/2) or 'skip': ").strip()
        
        if choice == '1':
            organizer.split_dataset(disease_dir, train_ratio=0.7, val_ratio=0.2, test_ratio=0.1)
        elif choice == '2':
            organizer.split_dataset(severity_dir, train_ratio=0.7, val_ratio=0.2, test_ratio=0.1)
        else:
            print("Skipping dataset split...")
    
    print("\n" + "="*60)
    print("✅ DATASET PREPARATION COMPLETED!")
    print("="*60)
    print(f"\nOutput Directory: {OUTPUT_DIR}")
    print("\nNext Steps:")
    print("1. Copy your disease images into the organized folders")
    print("2. Run dataset split to create train/val/test sets")
    print("3. Update notebook paths to point to split datasets")
    print("4. Start training your models!")


if __name__ == "__main__":
    main()
