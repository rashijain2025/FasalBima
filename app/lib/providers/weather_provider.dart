import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  List<WeatherAlert> _alerts = [];
  List<FarmingTip> _farmingTips = [];
  List<HistoricalWeatherData> _historicalWeatherData = [];
  bool _isLoading = false;
  String? _error;

  // EMULATOR / DEVICE / WEB ke hisaab se baseUrl
  // Android emulator  -> http://10.0.2.2:8000
  // Flutter Web       -> http://localhost:8000
  // Agar real device same WiFi pe hai to:
  //   yaha apne laptop ka IP daalna hoga (ex: http://192.168.1.5:8000)
  static const String baseUrl = kIsWeb
      ? 'http://localhost:8000'
      : 'http://192.168.22.159:8000';

  WeatherData? get weatherData => _weatherData;
  List<WeatherAlert> get alerts => _alerts;
  List<FarmingTip> get farmingTips => _farmingTips;
  List<HistoricalWeatherData> get historicalWeatherData =>
      _historicalWeatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // lat/lon optional rakhe hain, taaki HomeScreen agar bina params call kare to crash na ho
  Future<void> loadWeatherData({
    double? lat,
    double? lon,
  }) async {
    // lat/lon hi nahi mile -> random coord nahi use karenge, bas return
    if (lat == null || lon == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri =
          Uri.parse('$baseUrl/api/weather/current').replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
      });

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = (body['data'] ?? {}) as Map<String, dynamic>;

        final location = (data['location'] ?? 'Unknown').toString();
        final temp = (data['temperature'] is num)
            ? (data['temperature'] as num).toDouble()
            : 0.0;
        final humidity = (data['humidity'] is num)
            ? (data['humidity'] as num).toDouble()
            : 0.0;
        final wind = (data['wind_speed'] is num)
            ? (data['wind_speed'] as num).toDouble()
            : 0.0;
        final desc = (data['weather'] ?? '').toString();

        _weatherData = WeatherData(
          location: location,
          temperature: temp,
          humidity: humidity,
          windSpeed: wind,
          condition: desc,
          description: desc,
          timestamp: DateTime.now(),
          alerts: const [],
        );

        _alerts = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        final err = json.decode(res.body);
        _error = err['detail']?.toString() ?? 'Failed to load weather';
      } catch (_) {
        _error = 'Failed to load weather (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('🌩 Weather error: $e');
      _error = 'Weather load error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadForecastData({
    required double lat,
    required double lon,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl/api/weather/forecast').replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
      });

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = (body['data'] ?? {}) as Map<String, dynamic>;
        final List<HistoricalWeatherData> list = [];
        final keys = data.keys.toList()..sort();
        for (final k in keys) {
          final v = data[k] as Map<String, dynamic>;
          final date = DateTime.tryParse(k) ?? DateTime.now();
          final minT = (v['min_temp'] is num)
              ? (v['min_temp'] as num).toDouble()
              : 0.0;
          final maxT = (v['max_temp'] is num)
              ? (v['max_temp'] as num).toDouble()
              : 0.0;
          final avgT = (minT + maxT) / 2.0;
          final hum = (v['humidity'] is num)
              ? (v['humidity'] as num).toDouble()
              : 0.0;
          list.add(
            HistoricalWeatherData(
              date: date,
              temperature: avgT,
              humidity: hum,
            ),
          );
        }
        _historicalWeatherData = list;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('🌧 Forecast error: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}