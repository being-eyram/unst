import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final ImagenModel _model;

  GeminiService()
    : _model = FirebaseAI.googleAI().imagenModel(
        model: 'imagen-4.0-generate-001',
        generationConfig: ImagenGenerationConfig(numberOfImages: 2),
      );

  Future<List<Uint8List>> generateImages(String prompt) async {
    final response = await _model.generateImages(prompt);

    if (response.filteredReason != null) {
      print('Filtered reason: ${response.filteredReason}');
    }

    if (response.images.isNotEmpty) {
      return response.images.map((img) => img.bytesBase64Encoded).toList();
    } else {
      print('Error: No images were generated.');
      return [];
    }
  }
}
