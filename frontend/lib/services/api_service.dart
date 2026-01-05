import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL - Use 10.0.2.2 for Android Emulator to access host machine
  // For physical device or web, use your actual IP address
  static const String baseUrl = 'http://10.0.2.2:5000';
  
  // Timeouts
  static const Duration timeout = Duration(seconds: 30);

  // ==================== Health Check ====================
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check health: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Health check failed: $e');
    }
  }

  // ==================== Animal Birth Prediction ====================
  static Future<Map<String, dynamic>> predictAnimalBirth({
    required List<double> features,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/animal-birth/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'features': features}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Animal birth prediction failed: $e');
    }
  }

  // ==================== Cow Identification ====================
  static Future<Map<String, dynamic>> identifyCow(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/cow-identify/detect'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Identification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cow identification failed: $e');
    }
  }

  // ==================== Cow Daily Feed ====================
  static Future<Map<String, dynamic>> predictCowFeedManual({
    required String breed,
    required int age,
    required double weight,
    required double milkYield,
    required String activity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cow-feed/predict-manual'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'breed': breed,
          'age': age,
          'weight': weight,
          'milk_yield': milkYield,
          'activity': activity,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cow feed prediction failed: $e');
    }
  }

  static Future<Map<String, dynamic>> predictCowFeedFromImage(
    File imageFile, {
    required String breed,
    required int age,
    required double milkYield,
    required String activity,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/cow-feed/predict-from-image'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      request.fields.addAll({
        'breed': breed,
        'age': age.toString(),
        'milk_yield': milkYield.toString(),
        'activity': activity,
      });

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cow feed image prediction failed: $e');
    }
  }

  // ==================== Egg Hatch Prediction ====================
  static Future<Map<String, dynamic>> predictEggHatch({
    required double temperature,
    required double humidity,
    required double eggWeight,
    required int turningFrequency,
    required int incubationDuration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/egg-hatch/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Temperature': temperature,
          'Humidity': humidity,
          'Egg_Weight': eggWeight,
          'Egg_Turning_Frequency': turningFrequency,
          'Incubation_Duration': incubationDuration,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Egg hatch prediction failed: $e');
    }
  }

  // ==================== Milk Market Prediction ====================
  static Future<Map<String, dynamic>> predictMilkMarket({
    required double currentPrice,
    required double monthlyMilkLitres,
    required double fatPercentage,
    required double snfPercentage,
    required int diseaseStage,
    required int feedQuality,
    required int lactationMonth,
    required int month,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/milk-market/predict-income'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_price': currentPrice,
          'monthly_milk_litres': monthlyMilkLitres,
          'fat_percentage': fatPercentage,
          'snf_percentage': snfPercentage,
          'disease_stage': diseaseStage,
          'feed_quality': feedQuality,
          'lactation_month': lactationMonth,
          'month': month,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Milk market prediction failed: $e');
    }
  }

  // ==================== Nutrition Recommendation ====================
  static Future<Map<String, dynamic>> recommendNutrition({
    required int ageMonths,
    required double weightKg,
    required String breed,
    required double milkYield,
    required String activityLevel,
    required String healthStatus,
    required String disease,
    required double bodyConditionScore,
    required String location,
    required double energyMJ,
    required double crudeProtein,
    required String feedType,
  }) async {
    try {
      final requestBody = {
        'Age_Months': ageMonths,
        'Weight_kg': weightKg,
        'Breed': breed,
        'Milk_Yield_L_per_day': milkYield,
        'Health_Status': healthStatus,
        'Disease': disease,
        'Body_Condition_Score': bodyConditionScore,
        'Location': location,
        'Energy_MJ_per_day': energyMJ,
        'Crude_Protein_g_per_day': crudeProtein,
        'Recommended_Feed_Type': feedType,
      };
      print('Nutrition Request Body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Recommendation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Nutrition recommendation failed: $e');
    }
  }

  // ==================== Cattle Disease Detection ====================
  static Future<Map<String, dynamic>> detectCattleDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/disease/detect'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Detection failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cattle disease detection failed: $e');
    }
  }

  static Future<Map<String, dynamic>> analyzeCattleDisease({
    required File imageFile,
    required String diseaseType,
    required Map<String, dynamic> symptoms,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/disease/analyze'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      request.fields['disease_type'] = diseaseType;
      request.fields['symptoms'] = json.encode(symptoms);

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Analysis failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cattle disease analysis failed: $e');
    }
  }

  static Future<Map<String, dynamic>> quickDiagnosis({
    required Map<String, dynamic> symptoms,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/quick-diagnosis'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'symptoms': symptoms}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Diagnosis failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Quick diagnosis failed: $e');
    }
  }

  // ==================== Cattle Behavior Analysis ====================
  static Future<Map<String, dynamic>> analyzeBehaviorSnapshot(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/behavior/snapshot'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Analysis failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Behavior snapshot analysis failed: $e');
    }
  }

  static Future<Map<String, dynamic>> analyzeBehaviorHistory(String cowId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/behavior/analyze/$cowId'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Analysis failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Behavior history analysis failed: $e');
    }
  }

  static Future<Map<String, dynamic>> detectBehaviorFromVideo(File videoFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/behavior/detect-from-video'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );

      var streamedResponse = await request.send().timeout(Duration(minutes: 5));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Detection failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Behavior video detection failed: $e');
    }
  }

  // ==================== Model Status ====================
  static Future<Map<String, dynamic>> getModelStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/models/status'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get model status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Model status check failed: $e');
    }
  }
}
