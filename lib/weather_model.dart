class WeatherModel {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String time;

  WeatherModel({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  // Create WeatherModel from JSON response
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentWeather = json['current_weather'];
    return WeatherModel(
      temperature: currentWeather['temperature'].toDouble(),
      windSpeed: currentWeather['windspeed'].toDouble(),
      weatherCode: currentWeather['weathercode'],
      time: currentWeather['time'],
    );
  }

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'current_weather': {
        'temperature': temperature,
        'windspeed': windSpeed,
        'weathercode': weatherCode,
        'time': time,
      }
    };
  }
}

