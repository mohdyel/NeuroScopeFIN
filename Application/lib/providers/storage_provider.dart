import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class StorageProvider extends ChangeNotifier {
  final Map<String, Uint8List> _webImageCache = {};
  final Map<String, dynamic> _webDataCache = {};

  Future<void> saveImage(String key, Uint8List imageData) async {
    if (kIsWeb) {
      _webImageCache[key] = imageData;
      // Save metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${key}_metadata', DateTime.now().toIso8601String());
    }
    notifyListeners();
  }

  Future<Uint8List?> getImage(String key) async {
    if (kIsWeb) {
      return _webImageCache[key];
    }
    return null;
  }

  Future<List<String>> getStoredImageKeys() async {
    if (kIsWeb) {
      return _webImageCache.keys.toList();
    }
    return [];
  }

  Future<void> clearCache() async {
    if (kIsWeb) {
      _webImageCache.clear();
      _webDataCache.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
    notifyListeners();
  }
}
