import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ServerConfigProvider extends ChangeNotifier {
  //–– keep an instance‐side copy if you like; but for your “static call”:
  static String? _globalServerUrl;
  static String? get serverUrl => _globalServerUrl;

  /// static initializer you can call from anywhere:
  static Future<String?> initialize() async {
    const endpoint = 'http://hello1234rty.atwebpages.com/';
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Accept': 'text/html',
          if (kIsWeb) 'Access-Control-Allow-Origin': '*',
        },
      );
      if (response.statusCode == 200) {
        final match = RegExp(r'href="(https://[^"]+)"').firstMatch(response.body);
        if (match != null) {
          _globalServerUrl = match.group(1);
          return _globalServerUrl;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching server URL: $e');
    }
    return null;
  }

  //–– you can still keep your instance API if you want:
  String? _serverUrl;
  String? get serverUrlInstance => _serverUrl;
  Future<void> initializeInstance() async {
    final url = await initialize();
    if (url != null) {
      _serverUrl = url;
      notifyListeners();
    }
  }
}
