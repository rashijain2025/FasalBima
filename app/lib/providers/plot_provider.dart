import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plot_model.dart';

class PlotProvider with ChangeNotifier {
  List<Plot> _plots = [];
  bool _isLoading = false;
  String? _error;

  // Web vs Android emulator ke hisaab se baseUrl
  static const String baseUrl =
      // kIsWeb ? 'http://localhost:8000' : 'http://10.110.250.159:8000';
      kIsWeb ? 'http://localhost:8000' : 'http://192.168.22.159:8000';

  List<Plot> get plots => _plots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // =====================================================
  // LOAD PLOTS (GET /api/plots/me)
  // =====================================================
  Future<void> loadPlots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      debugPrint('📥 [loadPlots] token=$token');

      if (token == null || token.isEmpty) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = '$baseUrl/api/plots/me';
      debugPrint('🔥 [loadPlots] GET $url');

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📩 [loadPlots] status=${res.statusCode}, body=${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;

        _plots = data.map((item) {
          final m = item as Map<String, dynamic>;

          final double areaInAcres = (m['area_hectares'] is num)
              ? (m['area_hectares'] as num).toDouble() / 0.404686
              : 0.0;

          return Plot(
            id: (m['id'] ?? '').toString(),
            farmerId: (m['farmer_id'] ?? '').toString(),
            name: (m['plot_name'] ?? '').toString(),
            area: areaInAcres,
            latitude: 0.0, // polygon/centroid se future me nikal sakte
            longitude: 0.0,
            address: (m['address'] ?? '').toString(),
            landDocumentUrls:
                (m['land_document_url'] != null && (m['land_document_url'] as String).isNotEmpty)
                    ? [(m['land_document_url'] as String)]
                    : <String>[],
            registeredDate:
                DateTime.tryParse((m['created_at'] ?? '').toString()) ??
                    DateTime.now(),
            createdAt:
                DateTime.tryParse((m['created_at'] ?? '').toString()) ??
                    DateTime.now(),
            updatedAt:
                DateTime.tryParse((m['updated_at'] ?? '').toString()) ??
                    DateTime.now(),
            additionalData: m,
          );
        }).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Failed to load plots';
        } catch (_) {
          _error = 'Failed to load plots (${res.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [loadPlots.error] $e');
      _error = 'Failed to load plots: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // STEP 1: CREATE PLOT (JSON ONLY) -> returns plotId
  //  - POST /api/plots/
  // =====================================================
  Future<String?> createPlotInfo(Plot plot) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint('🧱 [createPlotInfo] called with Plot:'
        '\n  name=${plot.name}'
        '\n  area(acres)=${plot.area}'
        '\n  address=${plot.address}'
        '\n  additionalData=${plot.additionalData}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      debugPrint('🔑 [createPlotInfo] token=$token, userId=$userId');

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final extra = plot.additionalData ?? {};

      // PlotCreate schema ke hisaab se body
      final body = {
        'plot_name': plot.name,
        'address': plot.address,
        'village': extra['village'],
        'district': extra['district'],
        'state': extra['state'],
        'country': extra['country'],
        'area_hectares': plot.area * 0.404686, // acres -> hectares
        'farmer_id': userId,
        'boundary_coordinates': extra['boundary_coordinates'] ?? [],
        'land_document_type': extra['land_document_type'],
        // land_document_url, polygon, centroid backend handle karega
      };

      final url = '$baseUrl/api/plots/';
      debugPrint('🔥 [createPlotInfo] POST $url');
      debugPrint('📦 [createPlotInfo] body=$body');

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      debugPrint(
          '📩 [createPlotInfo] status=${res.statusCode}, body=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final m = json.decode(res.body) as Map<String, dynamic>;
        final createdId = (m['id'] ?? '').toString();

        debugPrint('✅ [createPlotInfo] plot created with id=$createdId');

        // optional: local list me add
        try {
          final newPlot = _fromBackend(m);
          _plots.add(newPlot);
          debugPrint('📥 [createPlotInfo] local list me add kiya');
        } catch (e) {
          debugPrint('⚠️ [createPlotInfo] _fromBackend parsing error: $e');
        }

        _isLoading = false;
        notifyListeners();
        return createdId;
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Failed to register plot';
        } catch (_) {
          _error = 'Failed to register plot (${res.statusCode})';
        }
        debugPrint('❌ [createPlotInfo.server-error] $_error');
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      debugPrint('❌ [createPlotInfo.exception] $e');
      _error = 'Failed to register plot: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // =====================================================
  // HELPERS
  // =====================================================

  Plot _fromBackend(Map<String, dynamic> m) {
    final double areaInAcres = (m['area_hectares'] is num)
        ? (m['area_hectares'] as num).toDouble() / 0.404686
        : 0.0;

    return Plot(
      id: (m['id'] ?? '').toString(),
      farmerId: (m['farmer_id'] ?? '').toString(),
      name: (m['plot_name'] ?? '').toString(),
      area: areaInAcres,
      latitude: 0.0,
      longitude: 0.0,
      address: (m['address'] ?? '').toString(),
      landDocumentUrls:
          (m['land_document_url'] != null && (m['land_document_url'] as String).isNotEmpty)
              ? [(m['land_document_url'] as String)]
              : <String>[],
      registeredDate:
          DateTime.tryParse((m['created_at'] ?? '').toString()) ??
              DateTime.now(),
      createdAt:
          DateTime.tryParse((m['created_at'] ?? '').toString()) ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse((m['updated_at'] ?? '').toString()) ??
              DateTime.now(),
      additionalData: m,
    );
  }

  Plot? getPlotById(String id) {
    try {
      return _plots.firstWhere((plot) => plot.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Plot> getPlotsByFarmerId(String farmerId) {
    return _plots.where((plot) => plot.farmerId == farmerId).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
