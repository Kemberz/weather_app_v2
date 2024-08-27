import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherApi {
  static Future<Map<String, dynamic>> getWeatherForecast(String latitude, String longitude, DateTime startDate, DateTime endDate) async {
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final url = 'https://archive-api.open-meteo.com/v1/archive?latitude=$latitude&longitude=$longitude&start_date=$formattedStartDate&end_date=$formattedEndDate&daily=temperature_2m_max,temperature_2m_min';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        // Add latitude and longitude to the returned data
        decodedData['latitude'] = latitude;
        decodedData['longitude'] = longitude;
        return decodedData;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }
}