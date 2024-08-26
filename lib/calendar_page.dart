import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      selectableDayPredicate: (DateTime date) {
        return date.isBefore(DateTime.now().add(Duration(days: 1)));
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate == null || _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate == null || _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _getWeatherForecast() {
    if (_startDate != null && _endDate != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load weather data. Please try again.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both start and end dates.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date Range'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Selected city: ${widget.city['name']}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
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
                    child: Text(_startDate == null 
                      ? 'Select Start Date' 
                      : 'Start: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(_endDate == null 
                      ? 'Select End Date' 
                      : 'End: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}