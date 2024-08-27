import 'package:flutter/material.dart';
import 'city_api.dart';
import 'calendar_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _showResults = false;

  void _performSearch() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final results = await CityApi.searchCity(query);
        setState(() {
          _searchResults = results;
          _showResults = true;
          _isLoading = false;
        });
        if (results.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No cities found. Please try a different search term.')),
          );
        }
      } catch (e) {
        print('Error searching for city: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while searching. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCountryFlag(String countryCode) {
    // Convert country code to uppercase to ensure it works
    countryCode = countryCode.toUpperCase();
    // Convert each letter to the corresponding regional indicator symbol
    const int flagOffset = 0x1F1E6;
    final int firstLetter = countryCode.codeUnitAt(0) - 65 + flagOffset;
    final int secondLetter = countryCode.codeUnitAt(1) - 65 + flagOffset;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  void _navigateToCalendarPage(Map<String, dynamic> city) {
    // Debug print
    print('Latitude: ${city['latitude']}, Longitude: ${city['longitude']}');

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CalendarPage(city: city),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.only(
              top: _showResults ? 20 : MediaQuery.of(context).size.height * 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      controller: _searchController,
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onSubmitted: (_) => _performSearch(),
                      leading: const Icon(Icons.search),
                      hintText: 'Search City',
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: Text('Search'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showResults)
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showResults ? 1.0 : 0.0,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final city = _searchResults[index];
                    final countryFlag = _getCountryFlag(city['country_code']);
                    return ListTile(
                      leading: Text(
                        countryFlag,
                        style: TextStyle(fontSize: 24),
                      ),
                      title: Text(city['name']),
                      subtitle: Text('${city['country']} - Population: ${city['population']}'),
                      onTap: () => _navigateToCalendarPage(city),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}