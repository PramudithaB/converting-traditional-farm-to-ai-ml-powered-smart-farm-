# Flutter App Quick Reference

## Project Structure
```
frontend/lib/
├── main.dart                      # App entry point
├── services/
│   └── api_service.dart          # Backend API integration
├── screens/
│   ├── login_screen.dart         # User authentication
│   ├── register_screen.dart      # User registration
│   ├── dashboard_screen.dart     # Main dashboard with 7 AI services
│   ├── add_cow_screen.dart       # Add cow to database
│   ├── animal_birth_screen.dart  # Animal birth prediction
│   ├── hatching.dart             # Egg hatch prediction
│   ├── market.dart               # Milk market analysis
│   ├── feed.dart                 # Cow feed calculator
│   ├── identico.dart             # Cow identification
│   ├── disease_detection_screen.dart  # Disease detection
│   └── nutrition_screen.dart     # Nutrition recommendations
├── models/
│   ├── cow.dart                  # Cow data model
│   └── user.dart                 # User data model
└── db/
    └── app_db.dart               # SQLite database

```

## Running the App

### Development Mode
```bash
cd frontend
flutter run
```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```
Output: `build/web/`

## Changing Backend URL

Edit `frontend/lib/services/api_service.dart`:
```dart
class ApiService {
  // Change this to your server address
  static const String baseUrl = 'http://YOUR_IP:5000';
  // ...
}
```

**For local testing:**
- Android Emulator: `http://10.0.2.2:5000`
- iOS Simulator: `http://localhost:5000`
- Physical device: `http://YOUR_COMPUTER_IP:5000`

## Key Dependencies

Already included in `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0              # API calls
  image_picker: ^1.1.1      # Camera/gallery
  google_fonts: ^6.2.0      # Typography
  sqflite: ^2.3.3+1         # Local database
  shared_preferences: ^2.2.2 # Local storage
```

## Common Commands

```bash
# Install dependencies
flutter pub get

# Clean build
flutter clean

# Check for issues
flutter doctor

# Run on specific device
flutter devices              # List devices
flutter run -d <device-id>   # Run on device

# Generate app icons
flutter pub run flutter_launcher_icons

# Analyze code
flutter analyze
```

## Troubleshooting

### "Connection refused" error
1. Check backend is running: `http://localhost:5000/health`
2. Update baseUrl in `api_service.dart`
3. Check firewall settings

### "Image picker not working"
**Android:** Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS:** Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for disease detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access</string>
```

### "Flutter SDK not found"
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify
flutter doctor
```

## Testing Individual Screens

Navigate directly to screens by editing `main.dart`:
```dart
home: const DiseaseDetectionScreen(), // Test specific screen
```

## API Service Usage Examples

### Animal Birth Prediction
```dart
final result = await ApiService.predictAnimalBirth(
  features: [101.5, 1200, 270, 5.0, 7.0],
);
print(result['Will Birth in Next 2 Days']);
```

### Disease Detection
```dart
File imageFile = File('path/to/image.jpg');
final result = await ApiService.detectCattleDisease(imageFile);
print(result['disease']);
```

### Milk Market
```dart
final result = await ApiService.predictMilkMarket(
  averagePrice: 1.5,
  productionQuantity: 1000,
  month: 6,
);
print(result['Predicted_Income']);
```

## Performance Tips

1. **Image Optimization:**
   ```dart
   final XFile? image = await _picker.pickImage(
     maxWidth: 1024,
     maxHeight: 1024,
     imageQuality: 85,
   );
   ```

2. **API Caching:** Store results in SharedPreferences for offline access

3. **Lazy Loading:** Load images only when needed

4. **Async Operations:** Use FutureBuilder for better UX

## App Navigation Flow

```
SplashScreen (auto)
    ↓
LoginScreen
    ↓
Dashboard (with 7 service cards)
    ├── Animal Birth Prediction
    ├── Egg Hatching Predictor
    ├── Milk Market Analyzer
    ├── Cow Feed Calculator
    ├── Cow Identifier
    ├── Disease Detection
    └── Nutrition Advisor
```

## Color Scheme

The app uses Material 3 with green theme:
- Primary: Green (#4CAF50)
- Accent: Secondary green shades
- Success: Green
- Warning: Orange
- Error: Red

Customize in `main.dart`:
```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(255, 76, 175, 80),
  brightness: Brightness.light,
);
```

## Database Schema

**Users Table:**
- id (INTEGER PRIMARY KEY)
- username (TEXT)
- passwordHash (TEXT)

**Cows Table:**
- id (INTEGER PRIMARY KEY)
- cowName (TEXT)
- breed (TEXT)
- birthDate (TEXT)
- lactationMonth (INTEGER)
- userId (INTEGER FOREIGN KEY)

## Debugging

Enable verbose logging:
```bash
flutter run -v
```

View logs:
```bash
flutter logs
```

Check widget inspector:
1. Press 'i' in terminal
2. Or use DevTools: `flutter pub global activate devtools`

## Ready to Deploy?

✅ Backend running on port 5000
✅ All models loaded successfully
✅ Flutter dependencies installed
✅ API baseUrl configured correctly
✅ Permissions added to manifests

**Run the app and test all 7 AI services!** 🚀
