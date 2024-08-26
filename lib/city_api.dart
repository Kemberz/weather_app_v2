import 'dart:convert';
import 'package:http/http.dart' as http;

class CityApi {
  static Future<List<Map<String, dynamic>>> searchCity(String query) async {
    // Trim only trailing spaces, keeping internal spaces
    final trimmedQuery = query.trimRight();
    final encodedQuery = Uri.encodeComponent(trimmedQuery);
    final url = 'https://geocoding-api.open-meteo.com/v1/search?name=$encodedQuery&count=5&language=en&format=json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results == null || results.isEmpty) {
          print('No results found for query: $trimmedQuery');
          return [];
        }

        return results.map((city) => {
          'name': city['name'],
          'latitude': city['latitude'],
          'longitude': city['longitude'],
          'population': city['population'],
          'admin1': city['admin1'] ?? 'Unknown',
        }).toList();
      } else {
        print('API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load city data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in API call: $e');
      throw Exception('Failed to load city data: $e');
    }
  }
}