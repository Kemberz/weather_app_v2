import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ExtractCsv {
  static Future<Map<String, dynamic>> fetchHourlyData(String latitude, String longitude, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m&start_date=$formattedDate&end_date=$formattedDate';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      // Ensure the hourly data is properly typed
      decodedData['hourly']['time'] = (decodedData['hourly']['time'] as List).map((e) => e.toString()).toList();
      decodedData['hourly']['temperature_2m'] = (decodedData['hourly']['temperature_2m'] as List).map((e) => double.parse(e.toString())).toList();
      return decodedData;
    } else {
      throw Exception('Failed to load hourly data');
    }
  }

  static Future<void> shareAsCsv(String latitude, String longitude, DateTime date) async {
    final data = await fetchHourlyData(latitude, longitude, date);
    final times = data['hourly']['time'] as List<dynamic>;
    final temps = data['hourly']['temperature_2m'] as List<dynamic>;

    String csvContent = 'Time,Temperature (°C)\n';
    for (int i = 0; i < times.length; i++) {
      csvContent += '${times[i]},${temps[i]}\n';
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final fileName = 'hourly_data_$formattedDate.csv';

    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';

    // Write the CSV content to a file
    final file = File(filePath);
    await file.writeAsString(csvContent);

    // Share the file
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Hourly Weather Data for $formattedDate',
    );
  }
}