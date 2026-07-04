import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final double uvIndex;
  final double rainfall;
  final double soilMoisturePct;
  final int weatherCode;
  final String condition;
  final String cityName;
  final List<DailyForecast> forecast;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.rainfall,
    required this.soilMoisturePct,
    required this.weatherCode,
    required this.condition,
    required this.cityName,
    required this.forecast,
  });
}

class DailyForecast {
  final String day;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final double rainfall;
  final String condition;

  DailyForecast({
    required this.day,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.rainfall,
    required this.condition,
  });
}

class WeatherService extends ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherService() {
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Get location
      final position = await _determinePosition();

      // 2. Reverse geocode to get city name
      final cityName = await _getCityName(position.latitude, position.longitude);

      // 3. Fetch weather from Open-Meteo (free, no API key needed)
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&current=temperature_2m,apparent_temperature,relative_humidity_2m,'
        'wind_speed_10m,weather_code,precipitation,soil_moisture_0_to_7cm'
        '&hourly=uv_index'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
        'precipitation_sum'
        '&timezone=auto'
        '&forecast_days=6',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Weather fetch failed (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>;
      final hourly = data['hourly'] as Map<String, dynamic>;

      // Pick UV index for the closest hour from hourly data
      final String currentTime = current['time'] as String; // e.g. "2024-03-22T09:00"
      final List hourlyTimes = hourly['time'] as List;
      final List hourlyUv = hourly['uv_index'] as List;
      final DateTime? currentDt = DateTime.tryParse(currentTime);
      int uvHourIndex = 0;
      if (currentDt != null) {
        int minDiff = 999999;
        for (int i = 0; i < hourlyTimes.length; i++) {
          final DateTime? t = DateTime.tryParse(hourlyTimes[i] as String);
          if (t == null) continue;
          final int diff = (t.difference(currentDt).inMinutes).abs();
          if (diff < minDiff) {
            minDiff = diff;
            uvHourIndex = i;
          }
        }
      }
      final double uvIndex = (hourlyUv[uvHourIndex] as num).toDouble();

      // Parse daily forecasts (skip today = index 0)
      final List<DailyForecast> forecasts = [];
      final List times = daily['time'] as List;
      for (int i = 1; i < times.length && i <= 5; i++) {
        final code = (daily['weather_code'][i] as num).toInt();
        forecasts.add(DailyForecast(
          day: _formatDay(times[i] as String),
          weatherCode: code,
          maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
          minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
          rainfall: (daily['precipitation_sum'][i] as num).toDouble(),
          condition: codeToCondition(code),
        ));
      }

      final int currentCode = (current['weather_code'] as num).toInt();
      final double soilVWC = (current['soil_moisture_0_to_7cm'] as num?)?.toDouble() ?? 0.2;
      double soilPct = (soilVWC / 0.5) * 100;
      soilPct = soilPct.clamp(0, 100);
      
      _weatherData = WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        feelsLike: (current['apparent_temperature'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toDouble(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        uvIndex: uvIndex,
        rainfall: (current['precipitation'] as num).toDouble(),
        soilMoisturePct: soilPct,
        weatherCode: currentCode,
        condition: codeToCondition(currentCode),
        cityName: cityName,
        forecast: forecasts,
      );

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable it in Settings.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    ).timeout(const Duration(seconds: 10));
  }

  Future<String> _getCityName(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final response = await http.get(url, headers: {'User-Agent': 'SmartFarmApp/1.0'})
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        return (address['city'] ??
                address['town'] ??
                address['village'] ??
                address['county'] ??
                'My Farm')
            .toString();
      }
    } catch (_) {}
    return 'My Farm';
  }

  String _formatDay(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final diff = date.difference(DateTime.now()).inDays;
    if (diff <= 1) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  static String codeToCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static bool isDayTime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour <= 18;
  }

  static IconData codeToIcon(int code) {
    if (code == 0) return isDayTime() ? Icons.wb_sunny : Icons.nights_stay;
    if (code <= 3) return isDayTime() ? Icons.wb_cloudy : Icons.nights_stay; // or partial clouds

    if (code <= 48) return Icons.foggy;
    if (code <= 57) return Icons.grain;
    if (code <= 67) return Icons.umbrella;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.cloudy_snowing;
    if (code <= 86) return Icons.ac_unit;
    if (code <= 99) return Icons.thunderstorm_outlined;
    return Icons.cloud;
  }

  static Color iconColorForCode(int code) {
    if (code == 0) return const Color(0xFFFFD54F);       // sunny yellow
    if (code <= 3) return const Color(0xFF90A4AE);        // cloudy grey-blue
    if (code <= 48) return const Color(0xFFB0BEC5);       // fog grey
    if (code <= 67) return const Color(0xFF1565C0);       // rain blue
    if (code <= 77) return const Color(0xFF80DEEA);       // snow cyan
    if (code <= 82) return const Color(0xFF6A3B2A);       // showers brown
    if (code <= 99) return const Color(0xFF4A148C);       // thunder purple
    return const Color(0xFF90A4AE);
  }
}
