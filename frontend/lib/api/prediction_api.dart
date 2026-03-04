import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API client that saves prediction results to the Laravel smartfarm database.
/// All endpoints: POST /api/predictions/{type} and GET /api/predictions/{type}
class PredictionApi {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Generic helpers ───

  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${response.statusCode} ${response.body}');
  }

  static Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data.cast<Map<String, dynamic>>();
    }
    throw Exception('GET $path failed: ${response.statusCode} ${response.body}');
  }

  // ─── Animal Birth Prediction ───

  static Future<Map<String, dynamic>> saveAnimalBirth({
    int? cowId,
    required List<double> features,
    required double estimatedDaysToBirth,
    required String willBirthIn2Days,
  }) {
    return _post('/predictions/animal-birth', {
      if (cowId != null) 'cow_id': cowId,
      'features': features,
      'estimated_days_to_birth': estimatedDaysToBirth,
      'will_birth_in_2_days': willBirthIn2Days,
    });
  }

  static Future<List<Map<String, dynamic>>> getAnimalBirthHistory() =>
      _getList('/predictions/animal-birth');

  // ─── Disease Detection ───

  static Future<Map<String, dynamic>> saveDiseaseDetection({
    int? cowId,
    String? imagePath,
    required String modelUsed,
    required String diseaseName,
    required double confidence,
    Map<String, dynamic>? allPredictions,
    Map<String, dynamic>? severity,
    Map<String, dynamic>? treatment,
  }) {
    return _post('/predictions/disease', {
      if (cowId != null) 'cow_id': cowId,
      if (imagePath != null) 'image_path': imagePath,
      'model_used': modelUsed,
      'disease_name': diseaseName,
      'confidence': confidence,
      if (allPredictions != null) 'all_predictions': allPredictions,
      if (severity != null) 'severity': severity,
      if (treatment != null) 'treatment': treatment,
    });
  }

  static Future<List<Map<String, dynamic>>> getDiseaseHistory() =>
      _getList('/predictions/disease');

  // ─── Behavior Detection ───

  static Future<Map<String, dynamic>> saveBehaviorDetection({
    int? cowId,
    required String detectionType,
    String? behavior,
    double? confidence,
    Map<String, dynamic>? details,
  }) {
    return _post('/predictions/behavior', {
      if (cowId != null) 'cow_id': cowId,
      'detection_type': detectionType,
      if (behavior != null) 'behavior': behavior,
      if (confidence != null) 'confidence': confidence,
      if (details != null) 'details': details,
    });
  }

  static Future<List<Map<String, dynamic>>> getBehaviorHistory() =>
      _getList('/predictions/behavior');

  // ─── Egg Hatch Prediction ───

  static Future<Map<String, dynamic>> saveEggHatch({
    required double temperature,
    required double humidity,
    required double eggWeight,
    required int eggTurningFrequency,
    required int incubationDuration,
    required double hatchProbability,
    required int predictedClass,
  }) {
    return _post('/predictions/egg-hatch', {
      'temperature': temperature,
      'humidity': humidity,
      'egg_weight': eggWeight,
      'egg_turning_frequency': eggTurningFrequency,
      'incubation_duration': incubationDuration,
      'hatch_probability': hatchProbability,
      'predicted_class': predictedClass,
    });
  }

  static Future<List<Map<String, dynamic>>> getEggHatchHistory() =>
      _getList('/predictions/egg-hatch');

  // ─── Milk Market Prediction ───

  static Future<Map<String, dynamic>> saveMilkMarket({
    required double currentPrice,
    required double monthlyMilkLitres,
    required double fatPercentage,
    required double snfPercentage,
    required int diseaseStage,
    required int feedQuality,
    required int lactationMonth,
    required int month,
    required double predictedPriceChange,
    required double predictedNextPrice,
    required double predictedNextIncome,
  }) {
    return _post('/predictions/milk-market', {
      'current_price': currentPrice,
      'monthly_milk_litres': monthlyMilkLitres,
      'fat_percentage': fatPercentage,
      'snf_percentage': snfPercentage,
      'disease_stage': diseaseStage,
      'feed_quality': feedQuality,
      'lactation_month': lactationMonth,
      'month': month,
      'predicted_price_change': predictedPriceChange,
      'predicted_next_price': predictedNextPrice,
      'predicted_next_income': predictedNextIncome,
    });
  }

  static Future<List<Map<String, dynamic>>> getMilkMarketHistory() =>
      _getList('/predictions/milk-market');

  // ─── Nutrition Recommendation ───

  static Future<Map<String, dynamic>> saveNutrition({
    int? cowId,
    required Map<String, dynamic> inputData,
    required double dryMatterIntakeKg,
    required double calciumGPerDay,
    required double phosphorusGPerDay,
  }) {
    return _post('/predictions/nutrition', {
      if (cowId != null) 'cow_id': cowId,
      'input_data': inputData,
      'dry_matter_intake_kg': dryMatterIntakeKg,
      'calcium_g_per_day': calciumGPerDay,
      'phosphorus_g_per_day': phosphorusGPerDay,
    });
  }

  static Future<List<Map<String, dynamic>>> getNutritionHistory() =>
      _getList('/predictions/nutrition');

  // ─── Cow Identification ───

  static Future<Map<String, dynamic>> saveCowIdentification({
    String? imagePath,
    int? matchedCowId,
    double? similarityScore,
    required bool matchFound,
    Map<String, dynamic>? allScores,
  }) {
    return _post('/predictions/cow-identification', {
      if (imagePath != null) 'image_path': imagePath,
      if (matchedCowId != null) 'matched_cow_id': matchedCowId,
      if (similarityScore != null) 'similarity_score': similarityScore,
      'match_found': matchFound,
      if (allScores != null) 'all_scores': allScores,
    });
  }

  static Future<List<Map<String, dynamic>>> getCowIdentificationHistory() =>
      _getList('/predictions/cow-identification');
}
