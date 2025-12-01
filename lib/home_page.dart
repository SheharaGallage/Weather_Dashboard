import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'weather_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _indexController = TextEditingController(text: '224182K');
  final WeatherService _weatherService = WeatherService();

  double? _latitude;
  double? _longitude;
  WeatherModel? _weatherData;
  String? _requestUrl;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCached = false;

  @override
  void initState() {
    super.initState();
    _calculateCoordinates();
  }

  // Calculate lat/lon from index number
  void _calculateCoordinates() {
    String index = _indexController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (index.length >= 4) {
      int firstTwo = int.parse(index.substring(0, 2));
      int nextTwo = int.parse(index.substring(2, 4));

      setState(() {
        _latitude = 5 + (firstTwo / 10.0);
        _longitude = 79 + (nextTwo / 10.0);
      });
    }
  }

  // Fetch weather data
  Future<void> _fetchWeather() async {
    _calculateCoordinates();

    if (_latitude == null || _longitude == null) {
      setState(() {
        _errorMessage = 'Invalid index number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _weatherService.fetchWeather(_latitude!, _longitude!);

      if (result['success']) {
        setState(() {
          _weatherData = WeatherModel.fromJson(result['data']);
          _requestUrl = result['url'];
          _isCached = result['cached'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade400, Colors.blue.shade200],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 20),
                const Text(
                  '🌤️ Weather Dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Index Input Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade700, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Student Index',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _indexController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade200, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            ),
                            hintText: 'Enter index (e.g., 224182K)',
                            prefixIcon: Icon(Icons.badge, color: Colors.blue.shade600),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (_) => _calculateCoordinates(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Coordinates Display
                if (_latitude != null && _longitude != null)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.blue.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Coordinates',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Latitude',
                                    style: TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_latitude!.toStringAsFixed(2)}°',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.white30,
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Longitude',
                                    style: TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_longitude!.toStringAsFixed(2)}°',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Fetch Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchWeather,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download, size: 24),
                  label: Text(_isLoading ? 'Loading...' : 'Fetch Weather Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Error Message
                if (_errorMessage != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.blue.shade900, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Weather Data Display
                if (_weatherData != null) ...[
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wb_sunny_rounded, color: Colors.blue.shade700, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Current Weather',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const Spacer(),
                              if (_isCached)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.storage, size: 14, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Cached',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Weather Info Rows
                          _buildWeatherRow(
                            icon: Icons.thermostat_rounded,
                            iconColor: Colors.orange,
                            label: 'Temperature',
                            value: '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                          ),
                          const Divider(height: 24),
                          _buildWeatherRow(
                            icon: Icons.air_rounded,
                            iconColor: Colors.lightBlue,
                            label: 'Wind Speed',
                            value: '${_weatherData!.windSpeed.toStringAsFixed(1)} km/h',
                          ),
                          const Divider(height: 24),
                          _buildWeatherRow(
                            icon: Icons.cloud_rounded,
                            iconColor: Colors.purple,
                            label: 'Weather Code',
                            value: '${_weatherData!.weatherCode}',
                          ),
                          const Divider(height: 24),
                          _buildWeatherRow(
                            icon: Icons.access_time_rounded,
                            iconColor: Colors.teal,
                            label: 'Last Updated',
                            value: _weatherData!.time,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Request URL Display
                  if (_requestUrl != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.link, size: 18, color: Colors.blue.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Request URL',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _requestUrl!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 32, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }
}

