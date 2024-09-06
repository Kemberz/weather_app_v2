import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'datasheet_page.dart';
import 'branded_backgroud.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> forecast;
  final String cityName;

  ResultsPage({required this.forecast, required this.cityName});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> minTemps = [];
    List<FlSpot> maxTemps = [];
    List<FlSpot> avgTemps = [];
    double overallAvgTemp = 0;

    for (int i = 0; i < forecast['daily']['time'].length; i++) {
      double minTemp = forecast['daily']['temperature_2m_min'][i];
      double maxTemp = forecast['daily']['temperature_2m_max'][i];
      double avgTemp = (minTemp + maxTemp) / 2;

      minTemps.add(FlSpot(i.toDouble(), minTemp));
      maxTemps.add(FlSpot(i.toDouble(), maxTemp));
      avgTemps.add(FlSpot(i.toDouble(), avgTemp));
      overallAvgTemp += avgTemp;
    }

    overallAvgTemp /= forecast['daily']['time'].length;

    // Create overall average line data
    List<FlSpot> overallAvgLine = List.generate(
      forecast['daily']['time'].length,
      (index) => FlSpot(index.toDouble(), overallAvgTemp)
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast for $cityName', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      ),
      extendBodyBehindAppBar: true,
      body: BrandedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.white.withOpacity(0.8),
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
                                DateFormat('dd/MM').format(DateTime.parse(forecast['daily']['time'][value.toInt()])),
                                style: TextStyle(fontSize: 10, color: Colors.white),
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
                          return Text('${value.toInt()}°C', style: TextStyle(fontSize: 10, color: Colors.white));
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
                    LineChartBarData(
                      spots: avgTemps,
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: overallAvgLine,
                      isCurved: false,
                      color: Colors.purple,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5], // This creates the dotted line effect
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor:(touchedSpot) {
                        return const Color.fromARGB(255, 65, 107, 95);
                      },
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          if (flSpot.x >= 0 && flSpot.x < forecast['daily']['time'].length) {
                            final date = DateTime.parse(forecast['daily']['time'][flSpot.x.toInt()]);
                            return LineTooltipItem(
                              '${DateFormat('dd/MM').format(date)}: ${flSpot.y.toStringAsFixed(1)}°C',
                              const TextStyle(color: Colors.white),
                            );
                          }
                          return null;
                        }).toList();
                      },
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Overall Average Temperature: ${overallAvgTemp.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Min'),
                SizedBox(width: 10),
                _buildLegendItem(Colors.red, 'Max'),
                SizedBox(width: 10),
                _buildLegendItem(Colors.green, 'Daily Avg'),
                SizedBox(width: 10),
                _buildLegendItem(Colors.purple, 'Overall Avg', isDotted: true),
              ],
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
                foregroundColor: const Color.fromARGB(255, 28, 133, 201), backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),),))
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isDotted = false}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            border: isDotted ? Border.all(color: color, width: 1) : null,
            borderRadius: isDotted ? BorderRadius.circular(1) : null,
          ),
          child: isDotted
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (_) => SizedBox(
                          width: 2,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: color),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : null,
        ),
        SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }
}