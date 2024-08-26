import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'extract_csv.dart';

class DatasheetPage extends StatefulWidget {
  final Map<String, dynamic> forecast;
  final String cityName;
  final String latitude;
  final String longitude;

  DatasheetPage({
    required this.forecast,
    required this.cityName,
    required this.latitude,
    required this.longitude,
  });

  @override
  _DatasheetPageState createState() => _DatasheetPageState();
}

class _DatasheetPageState extends State<DatasheetPage> {
  List<WeatherData> _data = [];
  List<WeatherData> _filteredData = [];
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    List<String> dates = (widget.forecast['daily']['time'] as List<dynamic>).cast<String>();
    List<double> maxTemps = (widget.forecast['daily']['temperature_2m_max'] as List<dynamic>).cast<double>();
    List<double> minTemps = (widget.forecast['daily']['temperature_2m_min'] as List<dynamic>).cast<double>();

    for (int i = 0; i < dates.length; i++) {
      _data.add(WeatherData(
        date: DateTime.parse(dates[i]),
        maxTemp: maxTemps[i],
        minTemp: minTemps[i],
        avgTemp: (maxTemps[i] + minTemps[i]) / 2,
      ));
    }

    _filteredData = List.from(_data);
  }

  void _showHourlyDataPopup(BuildContext context, DateTime date) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hourly Data for ${DateFormat('yyyy-MM-dd').format(date)}'),
          content: FutureBuilder<Map<String, dynamic>>(
            future: ExtractCsv.fetchHourlyData(widget.latitude, widget.longitude, date),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No data available');
              } else {
                List<dynamic> times = snapshot.data!['hourly']['time'];
                List<dynamic> temps = snapshot.data!['hourly']['temperature_2m'];
                return SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      times.length,
                      (index) => ListTile(
                        title: Text('${DateFormat('HH:mm').format(DateTime.parse(times[index].toString()))}'),
                        trailing: Text('${temps[index].toStringAsFixed(1)}°C'),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Share CSV'),
              onPressed: () async {
                Navigator.of(context).pop();
                await ExtractCsv.shareAsCsv(widget.latitude, widget.longitude, date);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    DateTime? startDate;
    DateTime? endDate;
    double? minMaxTemp, maxMaxTemp;
    double? minMinTemp, maxMinTemp;
    double? minAvgTemp, maxAvgTemp;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Data'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('Start Date'),
                      subtitle: Text(startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : 'Not set'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => startDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      title: Text('End Date'),
                      subtitle: Text(endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'Not set'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                    ),
                    _buildRangeInputs('Max', (min) => minMaxTemp = min, (max) => maxMaxTemp = max),
                    _buildRangeInputs('Min', (min) => minMinTemp = min, (max) => maxMinTemp = max),
                    _buildRangeInputs('Avg', (min) => minAvgTemp = min, (max) => maxAvgTemp = max),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Clear Filters'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _filteredData = List.from(_data);
                      _isFiltering = false;
                    });
                  },
                ),
                TextButton(
                  child: Text('Apply'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters(
                      startDate, endDate,
                      minMaxTemp, maxMaxTemp,
                      minMinTemp, maxMinTemp,
                      minAvgTemp, maxAvgTemp,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRangeInputs(String label, Function(double?) onMinChanged, Function(double?) onMaxChanged) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(labelText: '$label Low'),
            keyboardType: TextInputType.number,
            onChanged: (value) => onMinChanged(double.tryParse(value)),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(labelText: '$label High'),
            keyboardType: TextInputType.number,
            onChanged: (value) => onMaxChanged(double.tryParse(value)),
          ),
        ),
      ],
    );
  }

  void _applyFilters(
    DateTime? startDate, DateTime? endDate,
    double? minMaxTemp, double? maxMaxTemp,
    double? minMinTemp, double? maxMinTemp,
    double? minAvgTemp, double? maxAvgTemp,
  ) {
    setState(() {
      _filteredData = _data.where((item) {
        bool dateFilter = true;
        bool maxTempFilter = true;
        bool minTempFilter = true;
        bool avgTempFilter = true;

        if (startDate != null) {
          dateFilter = dateFilter && item.date.isAfter(startDate.subtract(Duration(days: 1)));
        }
        if (endDate != null) {
          dateFilter = dateFilter && item.date.isBefore(endDate.add(Duration(days: 1)));
        }
        
        if (minMaxTemp != null) maxTempFilter = maxTempFilter && item.maxTemp >= minMaxTemp;
        if (maxMaxTemp != null) maxTempFilter = maxTempFilter && item.maxTemp <= maxMaxTemp;
        
        if (minMinTemp != null) minTempFilter = minTempFilter && item.minTemp >= minMinTemp;
        if (maxMinTemp != null) minTempFilter = minTempFilter && item.minTemp <= maxMinTemp;
        
        if (minAvgTemp != null) avgTempFilter = avgTempFilter && item.avgTemp >= minAvgTemp;
        if (maxAvgTemp != null) avgTempFilter = avgTempFilter && item.avgTemp <= maxAvgTemp;

        return dateFilter && maxTempFilter && minTempFilter && avgTempFilter;
      }).toList();

      _isFiltering = startDate != null || endDate != null ||
                     minMaxTemp != null || maxMaxTemp != null ||
                     minMinTemp != null || maxMinTemp != null ||
                     minAvgTemp != null || maxAvgTemp != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data for ${widget.cityName}'),
        actions: [
          IconButton(
            icon: Icon(_isFiltering ? Icons.filter_list_off : Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: DataTable2(
        columnSpacing: 10,
        horizontalMargin: 20,
        minWidth: 10,
        columns: [
          DataColumn2(label: Text('Date'), size: ColumnSize.L),
          DataColumn2(label: Text('Max'), size: ColumnSize.S, numeric: true),
          DataColumn2(label: Text('Min'), size: ColumnSize.S, numeric: true),
          DataColumn2(label: Text('Avg'), size: ColumnSize.S, numeric: true),
        ],
        rows: _filteredData.map((item) => DataRow2(
          cells: [
            DataCell(Text(DateFormat('yyyy-MM-dd').format(item.date))),
            DataCell(Text(item.maxTemp.toStringAsFixed(1))),
            DataCell(Text(item.minTemp.toStringAsFixed(1))),
            DataCell(Text(item.avgTemp.toStringAsFixed(1))),
          ],
          onTap: () => _showHourlyDataPopup(context, item.date),
        )).toList(),
      ),
    );
  }
}

class WeatherData {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double avgTemp;

  WeatherData({required this.date, required this.maxTemp, required this.minTemp, required this.avgTemp});
}