import 'dart:async';
import 'package:http/http.dart' as http;

const String url = 'http://sanders.atwebpages.com/'; // ← replace with your link

bool online = false;

Future<void> fetchHtml() async {
  try {
    final response = await http.get(Uri.parse(url));
    final body = response.body.trim().toLowerCase();

    // Update online status
    online = body.contains('ok');
    
    // Debug print
    print('Server response: $body');
    print('Server online: $online');
  } catch (e) {
    // On error, mark as offline
    online = false;
    print('Error fetching HTML: $e');
    print('Server online: $online');
  }
}

void main() {
  // initial fetch
  fetchHtml();

  // fetch every 20 seconds
  Timer.periodic(const Duration(seconds: 20), (_) {
    fetchHtml();
  });
}
