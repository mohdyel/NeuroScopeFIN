import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class LinkService {
  static String? _cachedLink;

  static Future<String> fetchLink() async {
    // Return cached link if available
    if (_cachedLink != null) {
      return _cachedLink!;
    }

    try {
      final response = await http.get(Uri.parse('http://checkokornot.atwebpages.com/'));
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var link = document.querySelector('a')?.attributes['href'];
        // Cache the link
        _cachedLink = link ?? '';
        return _cachedLink!;
      }
    } catch (e) {
      print('Error fetching link: $e');
    }
    return '';
  }

  // Getter for the cached link
  static String get currentLink => _cachedLink ?? '';
}


void go(){
  LinkService.fetchLink().then((link) {
    print('Fetched link: $link');
  });
}
// Usage example:
// String link = await LinkService.fetchLink();
// Or access cached link directly:
// String cachedLink = LinkService.currentLink;
