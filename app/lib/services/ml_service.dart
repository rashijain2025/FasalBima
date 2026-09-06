import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/crop_model.dart';

class MLService {
  // Update this with your backend URL
  static const String baseUrl = 'http://localhost:8000'; // Change to your backend URL
  
  /// Upload crop image and get ML prediction
  static Future<CropHealthPrediction> predictCropHealth(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict/'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        
        // Map backend response to CropHealthPrediction
        final isHealthy = data['health'] == 'Healthy';
        final confidence = (data['confidence'] as num).toDouble();
        final diseaseType = isHealthy ? null : data['disease'] as String?;
        
        // Generate recommendations based on disease
        final recommendations = _generateRecommendations(data);
        
        return CropHealthPrediction(
          isHealthy: isHealthy,
          confidence: confidence,
          diseaseType: diseaseType,
          recommendations: recommendations,
        );
      } else {
        throw Exception('Failed to get prediction: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock prediction if API fails (for development)
      return CropHealthPrediction(
        isHealthy: true,
        confidence: 0.85,
        diseaseType: null,
        recommendations: ['Continue regular monitoring', 'Maintain proper irrigation'],
      );
    }
  }
  
  /// Generate care recommendations based on ML prediction
  static List<String> _generateRecommendations(Map<String, dynamic> data) {
    final health = data['health'] as String;
    final disease = data['disease'] as String?;
    final severity = (data['severity'] as num?)?.toDouble() ?? 0.0;
    
    List<String> recommendations = [];
    
    if (health == 'Healthy') {
      recommendations.addAll([
        'Crop is healthy! Continue regular monitoring.',
        'Maintain proper irrigation schedule.',
        'Apply balanced fertilizers as needed.',
        'Monitor for pests regularly.',
      ]);
    } else {
      if (disease != null) {
        if (disease.toLowerCase().contains('blight')) {
          recommendations.addAll([
            'Remove and destroy infected leaves immediately.',
            'Apply fungicide containing copper or mancozeb.',
            'Improve air circulation around plants.',
            'Avoid overhead watering.',
            'Apply treatment every 7-10 days until symptoms clear.',
          ]);
        } else if (disease.toLowerCase().contains('spot')) {
          recommendations.addAll([
            'Remove affected leaves and dispose of them.',
            'Apply copper-based fungicide.',
            'Water plants at the base, not on leaves.',
            'Ensure proper spacing between plants.',
            'Apply treatment weekly for 2-3 weeks.',
          ]);
        } else if (disease.toLowerCase().contains('mold')) {
          recommendations.addAll([
            'Improve ventilation around plants.',
            'Reduce humidity levels.',
            'Apply fungicide containing chlorothalonil.',
            'Remove severely affected leaves.',
            'Water early in the day so leaves dry quickly.',
          ]);
        } else if (disease.toLowerCase().contains('mite')) {
          recommendations.addAll([
            'Apply insecticidal soap or neem oil.',
            'Increase humidity around plants.',
            'Remove heavily infested leaves.',
            'Apply treatment every 3-5 days for 2 weeks.',
            'Consider introducing beneficial insects.',
          ]);
        } else if (disease.toLowerCase().contains('virus')) {
          recommendations.addAll([
            'Remove and destroy infected plants immediately.',
            'Control insect vectors (aphids, whiteflies).',
            'Use virus-free seeds and transplants.',
            'Practice crop rotation.',
            'Disinfect tools after handling infected plants.',
          ]);
        } else {
          recommendations.addAll([
            'Identify the specific disease for targeted treatment.',
            'Remove affected plant parts.',
            'Apply appropriate fungicide or pesticide.',
            'Improve growing conditions.',
            'Consult with agricultural extension service.',
          ]);
        }
      }
      
      if (severity > 0.7) {
        recommendations.insert(0, '⚠️ High severity detected! Take immediate action.');
      }
    }
    
    return recommendations;
  }
}

