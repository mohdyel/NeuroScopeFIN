import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ServerMonitorService {
  static const String baseUrl = 'http://sanders.atwebpages.com/';
  static const Duration checkInterval = Duration(seconds: 20);
  static const Duration timeout = Duration(seconds: 60);

  final StreamController<bool> _serverStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get serverStatus => _serverStatusController.stream;
  Timer? _timer;

  void startMonitoring() {
    _timer?.cancel();
    _checkServer(); // Check immediately
    _timer = Timer.periodic(checkInterval, (_) {
      print('Timer triggered - checking server...'); // Debug log
      _checkServer();
    });
  }

  Future<void> _checkServer() async {
    print('Checking server at: ${DateTime.now()}'); // Debug timestamp
    bool isOnline;
    try {
      isOnline = await checkServerStatus();
    } catch (e) {
      print('Error checking server status: $e');
      isOnline = false;
    }

    print('Server status: ${isOnline ? 'ONLINE' : 'OFFLINE'}');
    _serverStatusController.add(isOnline);
  }

  static Future<bool> checkServerStatus() async {
    try {
      final uri = kIsWeb
          ? Uri.parse(
              'https://api.allorigins.win/raw?url=${Uri.encodeComponent(baseUrl)}')
          : Uri.parse(baseUrl);

      print('Making request to: $uri'); // Log the URL

      final response = await http.get(
        uri,
        headers: {'Accept': 'text/html, text/plain'},
      ).timeout(timeout);

      print('Response status code: ${response.statusCode}');

      // Log the exact response body
      print('Raw response body: "${response.body}"');

      if (response.statusCode != 200) {
        print('Server returned status code: ${response.statusCode}');
        return false;
      }

      final body = response.body.trim().toLowerCase();

      // More strict checking and detailed logging
      print('Trimmed and lowercase body: "$body"');

      // Check exact matches only
      final bool containsBodyTag = body == 'ok';
      final bool isExactOk = body == 'ok';

      print('Contains ok</body>: $containsBodyTag');
      print('Is exactly "ok": $isExactOk');

      if (containsBodyTag || isExactOk) {
        print('Found exact match for "ok"');
        return true;
      }

      print('No exact match found for "ok"');
      return false;
    } catch (e) {
      print('Exception during server check: $e');
      return false;
    }
  }

  void dispose() {
    print('Disposing ServerMonitorService');
    _timer?.cancel();
    _serverStatusController.close();
  }
}


