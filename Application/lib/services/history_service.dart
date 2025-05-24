import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../providers/server_config_provider.dart';
class HistoryService {
  String? baseUrl;
  Future<String> getBaseUrl() async {
    final url = await ServerConfigProvider.initialize();
    return baseUrl ?? url ?? (() => throw Exception('Server URL not configured'))();
  }

  static const String defaultUser = 'admin';

  static String _extractUsername(String email) {
    return email.split('@').first; // Get username part before @
  }

  Future<String> uploadResult(
      String username, Uint8List imageBytes, String predictedClass) async {
    final uri = Uri.parse('${await getBaseUrl()}/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['username'] = username
      ..fields['predicted_class'] = predictedClass
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'spectrogram.png',
        ),
      );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final data = jsonDecode(responseData);
      return data['filename'];
    }
    throw Exception('Upload failed: ${response.statusCode}');
  }

  static Future<List<Map<String, String>>> getRecords() async {
    try {
      final service = HistoryService();
      final response = await http.get(
        Uri.parse('${await service.getBaseUrl()}/records/$defaultUser'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((record) => {
                  'patientId': record['patientid'] as String,
                  'prediction': record['prediction'] as String,
                  'image': record['image'] as String,
                })
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching records: $e');
      return [];
    }
  }

  static Future<Uint8List?> getImage(String filename) async {
    try {
      final service = HistoryService();
      final response = await http.get(
        Uri.parse('${await service.getBaseUrl()}/images/$filename'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching image: $e');
      return null;
    }
  }
}
