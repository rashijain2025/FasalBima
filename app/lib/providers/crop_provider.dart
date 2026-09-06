import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/crop_model.dart';

class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  bool _isLoading = false;
  String? _error;

  static const String baseUrl =
      kIsWeb ? 'http://localhost:8000' : 'http://192.168.22.159:8000';
      // kIsWeb
      //     ? 'https://bcl96b99-8001.inc1.devtunnels.ms'
      //     : 'https://bcl96b99-8001.inc1.devtunnels.ms';

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCrops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final res = await http.get(
        Uri.parse('$baseUrl/api/crops/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List<dynamic>;

        // plots for area/address/lat-lng
        final plotsRes = await http.get(
          Uri.parse('$baseUrl/api/plots/me'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        Map<String, Map<String, dynamic>> plotsById = {};
        if (plotsRes.statusCode == 200) {
          final plotsList = json.decode(plotsRes.body) as List<dynamic>;
          for (final p in plotsList) {
            final pm = p as Map<String, dynamic>;
            plotsById[(pm['id'] ?? '').toString()] = pm;
          }
        }

        final prev = {for (final c in _crops) c.id: c};

        _crops = list.map((item) {
          final m = item as Map<String, dynamic>;
          final typeStr = (m['crop_type'] ?? '').toString();
          final stageStr = (m['current_stage'] ?? '').toString();
          final plotId = (m['plot_id'] ?? '').toString();
          final plot = plotsById[plotId];
          final acres = (plot != null && plot['area_hectares'] is num)
              ? ((plot['area_hectares'] as num).toDouble() / 0.404686)
              : 0.0;
          final address =
              (plot != null) ? (plot['address'] ?? '').toString() : '';
          final latLng = _centroidFromBoundary(plot?['boundary_coordinates']);
          final newCrop = Crop(
            id: (m['id'] ?? '').toString(),
            farmerId: userId ?? '',
            plotId: plotId,
            name: (m['variety'] ?? typeStr).toString(),
            type: _parseCropType(typeStr),
            sowingDate: _parseDate(m['sowing_date']) ?? DateTime.now(),
            area: acres,
            latitude: latLng.$1,
            longitude: latLng.$2,
            address: address,
            imageUrl: (m['latest_image_url'] as String?),
            currentStage: _parseStage(stageStr),
            weeklyImages: const [],
            createdAt: _parseDateTime(m['created_at']) ?? DateTime.now(),
            updatedAt: _parseDateTime(m['updated_at']) ?? DateTime.now(),
            additionalData: m,
          );

          final old = prev[newCrop.id];
          if (old != null) {
            return newCrop.copyWith(
              area: old.area > 0 ? old.area : newCrop.area,
              address:
                  (old.address).isNotEmpty ? old.address : newCrop.address,
              latitude: old.latitude != 0.0 ? old.latitude : newCrop.latitude,
              longitude:
                  old.longitude != 0.0 ? old.longitude : newCrop.longitude,
            );
          }
          return newCrop;
        }).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Failed to load crops';
        } catch (_) {
          _error = 'Failed to load crops (${res.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load crops: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ STEP-1 ONLY: TEXT CREATE (2-button flow ke liye)
  // ---------------------------------------------------------------------------
  Future<String?> createCropTextOnly(Crop crop) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');
      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final body = {
        'plot_id': crop.plotId,
        'crop_type': crop.typeDisplayName,
        'variety': crop.name,
        'sowing_date': _formatDateYMD(crop.sowingDate),
      };

      final res = await http.post(
        Uri.parse('$baseUrl/api/crops/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Failed to add crop';
        } catch (_) {
          _error = 'Failed to add crop (${res.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final m = json.decode(res.body) as Map<String, dynamic>;
      final createdId = (m['id'] ?? '').toString();

      final createdCrop = Crop(
        id: createdId,
        farmerId: userId,
        plotId: (m['plot_id'] ?? crop.plotId).toString(),
        name: crop.name,
        type: _parseCropType(
          (m['crop_type'] ?? crop.typeDisplayName).toString(),
        ),
        sowingDate: _parseDate(m['sowing_date']) ?? crop.sowingDate,
        area: crop.area,
        latitude: crop.latitude,
        longitude: crop.longitude,
        address: crop.address,
        imageUrl: (m['latest_image_url'] as String?) ?? crop.imageUrl,
        currentStage:
            _parseStage((m['current_stage'] ?? 'sowing').toString()),
        weeklyImages: const [],
        createdAt: _parseDateTime(m['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTime(m['updated_at']) ?? DateTime.now(),
        additionalData: m,
      );

      _crops.add(createdCrop);
      _isLoading = false;
      notifyListeners();
      return createdId;
    } catch (e) {
      _error = 'Failed to add crop: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ STEP-2: IMAGE UPLOAD (initial image) – /upload-image
  // ---------------------------------------------------------------------------
  Future<bool> uploadInitialImage({
    required String cropId,
    Uint8List? imageBytes,
    String? filePath,
    required double lat,
    required double lng,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final uploadResult = await _uploadImageForCrop(
        token: token,
        cropId: cropId,
        imageBytes: imageBytes,
        filePath: filePath,
        lat: lat,
        lng: lng,
      );

      _isLoading = false;

      if (uploadResult == null) {
        notifyListeners();
        return false;
      }

      final (imageUrl, newStage) = uploadResult;

      final index = _crops.indexWhere((c) => c.id == cropId);
      if (index != -1) {
        final current = _crops[index];
        _crops[index] = current.copyWith(
          imageUrl: imageUrl ?? current.imageUrl,
          currentStage: newStage ?? current.currentStage,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to upload image: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Backward compatible: old addCrop (STEP-1 + STEP-2 combo)
  // ---------------------------------------------------------------------------
  Future<bool> addCrop(Crop crop, {Uint8List? imageBytes}) async {
    final createdId = await createCropTextOnly(crop);
    if (createdId == null) return false;

    final hasInitialImage =
        (imageBytes != null && imageBytes.isNotEmpty) ||
            (crop.imageUrl != null && crop.imageUrl!.isNotEmpty);

    if (!hasInitialImage) return true;

    return await uploadInitialImage(
      cropId: createdId,
      imageBytes: imageBytes,
      filePath: crop.imageUrl,
      lat: crop.latitude,
      lng: crop.longitude,
    );
  }

  Future<bool> updateCropStage(String cropId, CropStage newStage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated';
        notifyListeners();
        return false;
      }

      final payload = {
        'current_stage': _stageToBackend(newStage),
      };

      final res = await http.put(
        Uri.parse('https://bcl96b99-8001.inc1.devtunnels.ms/api/crops/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (res.statusCode == 200) {
        final index = _crops.indexWhere((crop) => crop.id == cropId);
        if (index != -1) {
          _crops[index] = _crops[index].copyWith(
            currentStage: newStage,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Failed to update stage';
        } catch (_) {
          _error = 'Failed to update stage (${res.statusCode})';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update crop stage: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((crop) => crop.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Crop> getCropsByStage(CropStage stage) {
    return _crops.where((crop) => crop.currentStage == stage).toList();
  }

  /// Weekly / later images ke liye STEP 2 API
  Future<bool> addWeeklyImage(
    String cropId,
    CropImage cropImage, {
    Uint8List? imageBytes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated';
        notifyListeners();
        return false;
      }

      final index = _crops.indexWhere((c) => c.id == cropId);
      if (index == -1) return false;
      final cycle = _crops[index];

      final uploadResult = await _uploadImageForCrop(
        token: token,
        cropId: cropId,
        imageBytes: imageBytes,
        filePath: cropImage.imageUrl,
        lat: cycle.latitude,
        lng: cycle.longitude,
      );

      if (uploadResult == null) {
        return false;
      }

      final (imageUrl, newStage) = uploadResult;

      final updatedWeeklyImages =
          List<CropImage>.from(cycle.weeklyImages)..add(cropImage);

      _crops[index] = cycle.copyWith(
        weeklyImages: updatedWeeklyImages,
        updatedAt: DateTime.now(),
        currentStage: newStage ?? cycle.currentStage,
        imageUrl: imageUrl ?? cycle.imageUrl,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add weekly image: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// COMMON helper: step-2 upload-image API
  /// backend:
  /// async def upload_crop_image(
  ///   cycle_id: str,
  ///   file: UploadFile,
  ///   user_lat: float,
  ///   user_lng: float,
  ///   ...
  /// )
  Future<(String?, CropStage?)?> _uploadImageForCrop({
    required String token,
    required String cropId,
    Uint8List? imageBytes,
    String? filePath,
    required double lat,
    required double lng,
  }) async {
    try {
      final uri = Uri.parse('https://bcl96b99-8001.inc1.devtunnels.ms/api/crops/$cropId/upload-image');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      if (imageBytes != null && imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'crop.jpg',
          ),
        );
      } else if (filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('file', filePath),
        );
      } else {
        return null;
      }

      // backend ke param names:
      request.fields['user_lat'] = lat.toString();
      request.fields['user_lng'] = lng.toString();

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        try {
          final resp = json.decode(responseBody) as Map<String, dynamic>;
          final imageUrl = (resp['image_url'] ?? '') as String;
          final newStageStr = (resp['new_stage'] ?? '').toString();
          final newStage =
              newStageStr.isNotEmpty ? _parseStage(newStageStr) : null;
          return (imageUrl.isNotEmpty ? imageUrl : null, newStage);
        } catch (_) {
          return (null, null);
        }
      } else {
        _error = 'Failed to upload image (${streamed.statusCode})';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Failed to upload image: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  CropType _parseCropType(String v) {
    switch (v.toLowerCase()) {
      case 'rice':
        return CropType.rice;
      case 'wheat':
        return CropType.wheat;
      case 'maize':
        return CropType.maize;
      case 'cotton':
        return CropType.cotton;
      case 'sugarcane':
        return CropType.sugarcane;
      case 'potato':
        return CropType.potato;
      case 'tomato':
        return CropType.tomato;
      case 'onion':
        return CropType.onion;
      case 'chili':
        return CropType.chili;
      default:
        return CropType.other;
    }
  }

  CropStage _parseStage(String v) {
    switch (v.toLowerCase()) {
      case 'sowing':
        return CropStage.sowing;
      case 'vegetative':
        return CropStage.vegetative;
      case 'flowering':
        return CropStage.flowering;
      case 'maturity':
        return CropStage.fruiting;
      case 'harvesting':
        return CropStage.harvest;
      default:
        return CropStage.sowing;
    }
  }

  String _stageToBackend(CropStage s) {
    switch (s) {
      case CropStage.sowing:
        return 'sowing';
      case CropStage.vegetative:
        return 'vegetative';
      case CropStage.flowering:
        return 'flowering';
      case CropStage.fruiting:
        return 'maturity';
      case CropStage.harvest:
        return 'harvesting';
    }
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDateTime(dynamic v) {
    return _parseDate(v);
  }

  String _formatDateYMD(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  (double, double) _centroidFromBoundary(dynamic boundary) {
    try {
      final list = (boundary as List<dynamic>?)
          ?.map((e) =>
              (e as List<dynamic>).map((v) => (v as num).toDouble()).toList())
          .toList();
      if (list == null || list.isEmpty) return (0.0, 0.0);
      double latSum = 0.0, lngSum = 0.0;
      for (final pair in list) {
        if (pair.length >= 2) {
          latSum += pair[0];
          lngSum += pair[1];
        }
      }
      final n = list.length.toDouble();
      return (latSum / n, lngSum / n);
    } catch (_) {
      return (0.0, 0.0);
    }
  }
}
