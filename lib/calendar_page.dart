import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_v2/branded_backgroud.dart';
import 'weather_api.dart';
import 'results_page.dart';

class CalendarPage extends StatefulWidget {
  final Map<String, dynamic> city;

  CalendarPage({required this.city});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final ThemeData theme = Theme.of(context);
    final newTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: const Color.fromARGB(255, 28, 133, 201),
        onPrimary: Colors.white,
      ),
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now().subtract(Duration(days: 1)) : _endDate ?? DateTime.now().subtract(Duration(days: 1)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(Duration(days: 1)),
      initialDatePickerMode: DatePickerMode.day,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: newTheme,
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select Date';
  }

  void _getWeatherForecast() {
    if (_startDate == null || _endDate == null) {
      _showErrorDialog('Please select both start and end dates.');
      return;
    }

    if (_endDate!.difference(_startDate!).inDays < 1) {
      _showErrorDialog('Please select a date range bigger than 1 day.');
      return;
    }

    print('Latitude: ${widget.city['latitude']}');
    print('Longitude: ${widget.city['longitude']}');
    print('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}');
    print('End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}');

    WeatherApi.getWeatherForecast(
      widget.city['latitude'].toString(),
      widget.city['longitude'].toString(),
      _startDate!,
      _endDate!,
    ).then((forecast) {
      print('Forecast data: $forecast');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            forecast: forecast,
            cityName: widget.city['name'],
          ),
        ),
      );
    }).catchError((error) {
      print('Error fetching weather data: $error');
      _showErrorDialog('Failed to load weather data. Please try again.');
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date Range', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: BrandedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    '${widget.city['name']}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(_formatDate(_startDate)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 28, 133, 201),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(_formatDate(_endDate)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 28, 133, 201),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _getWeatherForecast,
                  child: Text('Get Weather Forecast'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    foregroundColor: const Color.fromARGB(255, 28, 133, 201),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}