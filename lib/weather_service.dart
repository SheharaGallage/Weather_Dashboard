import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_model.dart';

class WeatherService {
  static const String _cacheKey = 'cached_weather';
  static const String _cacheTimeKey = 'cached_time';
  static const String _cacheUrlKey = 'cached_url';

  // Fetch weather from Open-Meteo API
  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = 'https://api.open-meteo.com/v1/forecast?'
        'latitude=$lat&longitude=$lon&current_weather=true';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cache the successful response
        await _cacheWeatherData(data, url);

        return {
          'success': true,
          'data': data,
          'url': url,
          'cached': false,
        };
      } else {
        // If API fails, try to load cached data
        return await _loadCachedData();
      }
    } catch (e) {
      // Network error - try to load cached data
      return await _loadCachedData();
    }
  }

  // Cache weather data locally
  Future<void> _cacheWeatherData(Map<String, dynamic> data, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(data));
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    await prefs.setString(_cacheUrlKey, url);
  }

  // Load cached weather data
  Future<Map<String, dynamic>> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cachedUrl = prefs.getString(_cacheUrlKey);

    if (cachedData != null) {
      return {
        'success': true,
        'data': json.decode(cachedData),
        'url': cachedUrl ?? '',
        'cached': true,
      };
    } else {
      return {
        'success': false,
        'error': 'No internet connection and no cached data available',
        'cached': false,
      };
    }
  }

  // Get cached time for display
  Future<String?> getCachedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheTimeKey);
  }
}

