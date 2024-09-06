import 'package:flutter/material.dart';
import 'city_api.dart';
import 'calendar_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showResults = false;
    });

    try {
      final results = await CityApi.searchCity(query);
      setState(() {
        _searchResults = results;
        _showResults = true;
        _isLoading = false;
      });

      if (results.isEmpty) {
        _showSnackBar('No cities found. Please try a different search term.');
      }
    } catch (e) {
      print('Error searching for city: $e');
      _showSnackBar('An error occurred while searching. Please try again.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getCountryFlag(String countryCode) {
    countryCode = countryCode.toUpperCase();
    const int flagOffset = 0x1F1E6;
    final int firstLetter = countryCode.codeUnitAt(0) - 65 + flagOffset;
    final int secondLetter = countryCode.codeUnitAt(1) - 65 + flagOffset;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  void _navigateToCalendarPage(Map<String, dynamic> city) {
    print('Latitude: ${city['latitude']}, Longitude: ${city['longitude']}');
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CalendarPage(city: city),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.ease));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        final countryFlag = _getCountryFlag(city['country_code']);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Text(
                countryFlag,
                style: TextStyle(fontSize: 24),
              ),
              title: Text(
                city['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${city['country']} - Population: ${city['population']}'),
              onTap: () => _navigateToCalendarPage(city),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned(
            left: -700,
            right: 0, // Compensate for the left shift to maintain image coverage
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/H2Caetano.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.only(
                    top: _showResults ? 40 : MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SearchBar(
                            backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(210, 255, 255, 255)),
                            controller: _searchController,
                            padding: MaterialStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            onSubmitted: (_) => _performSearch(),
                            leading: Icon(Icons.search),
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
                if (_isLoading)
                  Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_showResults)
                  Expanded(child: _buildSearchResults()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}