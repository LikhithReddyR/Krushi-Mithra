import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/services/api_config.dart';

class AiScannerService {
  late final GenerativeModel _model;

  AiScannerService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiConfig.geminiApiKey,
    );
  }

  Future<String> analyzeLeaf(File imageFile) async {
    if (ApiConfig.geminiApiKey.isEmpty) {
      return 'AI API key is missing. Please add your API key in api_config.dart.';
    }

    try {
      final bytes = await imageFile.readAsBytes();
      
      // Get the language instruction (e.g., 'Please respond in Hindi.')
      final langInstruction = TranslationService.translate('ai_language_instruction');
      
      final prompt = TextPart(
        'Analyze this image of a plant leaf and explain whether it is healthy or has a disease/pest/nutrient issue. '
        'If there is an issue, name the likely cause and suggest simple treatment steps in clearly readable format. '
        'DO NOT use any markdown formatting like ** or ###. '
        '$langInstruction',
      );

      final response = await _model.generateContent([
        Content.multi([
          prompt,
          DataPart('image/jpeg', bytes),
        ]),
      ]).timeout(const Duration(seconds: 45));

      if (response.text == null || response.text!.trim().isEmpty) {
        return 'AI returned no analysis. Please check your API key and network connectivity.';
      }
      return response.text!;
    } catch (e) {
      debugPrint('Error analyzing leaf: $e');
      return 'AI analyzer error: ${e.toString()}';
    }
  }

  Future<String> analyzeSoil(File imageFile, double temp, double humidity, double rain, String moistureLabel) async {
    if (ApiConfig.geminiApiKey.isEmpty) {
      return 'AI API key is missing. Please add your API key in api_config.dart.';
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final langInstruction = TranslationService.translate('ai_language_instruction');
      
      final prompt = TextPart(
        'You are an expert agronomist. Analyze this image of farm soil. '
        'I have also pulled live satellite weather for this exact location: Temperature is ${temp}°C, Humidity is ${humidity}%, Rainfall is ${rain}mm. '
        'The live satellite volumetric water content model predicts the soil moisture is currently: $moistureLabel. '
        'Combining the satellite data and what you see in the photo (soil texture, color, cracking, organic matter visible), '
        'provide a short, highly personalized verdict and farming recommendation in 2 to 3 concise sentences. '
        'DO NOT use any markdown formatting like ** or ###. '
        '$langInstruction'
      );

      final response = await _model.generateContent([
        Content.multi([
          prompt,
          DataPart('image/jpeg', bytes),
        ]),
      ]).timeout(const Duration(seconds: 45));

      if (response.text == null || response.text!.trim().isEmpty) {
        return 'AI returned no analysis.';
      }
      return response.text!;
    } catch (e) {
      debugPrint('Error analyzing soil: $e');
      return 'AI analyzer error: ${e.toString()}';
    }
  }
}
