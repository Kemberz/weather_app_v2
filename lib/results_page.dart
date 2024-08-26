import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'datasheet_page.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> forecast;
  final String cityName;

  ResultsPage({required this.forecast, required this.cityName});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> minTemps = [];
    List<FlSpot> maxTemps = [];
    
    for (int i = 0; i < forecast['daily']['time'].length; i++) {
      minTemps.add(FlSpot(i.toDouble(), forecast['daily']['temperature_2m_min'][i]));
      maxTemps.add(FlSpot(i.toDouble(), forecast['daily']['temperature_2m_max'][i]));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast for $cityName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: forecast['daily']['time'].length.toDouble() - 1,
                  minY: minTemps.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 5,
                  maxY: maxTemps.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 3 == 0 && value < forecast['daily']['time'].length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MM/dd').format(DateTime.parse(forecast['daily']['time'][value.toInt()])),
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}°C', style: TextStyle(fontSize: 10));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: minTemps,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: maxTemps,
                      isCurved: true,
                      color: Colors.red,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DatasheetPage(
                      forecast: forecast,
                      cityName: cityName,
                      latitude: forecast['latitude'].toString(),
                      longitude: forecast['longitude'].toString(),
                    ),
                  ),
                );
              },
              child: Text('Show Data'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}