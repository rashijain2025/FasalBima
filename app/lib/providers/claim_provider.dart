// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../models/claim_model.dart';

// class ClaimProvider with ChangeNotifier {
//   List<Claim> _claims = [];
//   bool _isLoading = false;
//   String? _error;

//   // Web vs Android emulator ke hisaab se baseUrl
//   static const String baseUrl =
//       kIsWeb ? 'https://bcl96b99-8001.inc1.devtunnels.ms' : 'https://bcl96b99-8001.inc1.devtunnels.ms';

//   List<Claim> get claims => _claims;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   // ===================== LOAD CLAIMS (GET APIs) ======================
//   Future<void> loadClaims() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//       final userId = prefs.getString('user_id');

//       if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
//         _error = 'Not authenticated';
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       // 1) GET /api/plots/me
//       final plotsUrl = '$baseUrl/api/plots/me';
//       print("🔥 [GET] $plotsUrl");
//       final plotsRes = await http.get(
//         Uri.parse(plotsUrl),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//       print(
//         "📩 [RESP /api/plots/me] status=${plotsRes.statusCode}, body=${plotsRes.body}",
//       );

//       if (plotsRes.statusCode != 200) {
//         _error = 'Failed to load plots for claims';
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       final plots = (json.decode(plotsRes.body) as List<dynamic>)
//           .map((e) => e as Map<String, dynamic>)
//           .toList();

//       final List<Claim> allClaims = [];

//       // 2) har plot ke liye GET /api/claim/plot/{plot_id}
//       for (final p in plots) {
//         final plotId = (p['id'] ?? '').toString();
//         if (plotId.isEmpty) continue;

//         final url = '$baseUrl/api/claim/plot/$plotId';
//         print("🔥 [GET] $url");

//         final claimsRes = await http.get(
//           Uri.parse(url),
//           headers: {'Authorization': 'Bearer $token'},
//         );

//         print(
//           "📩 [RESP /api/claim/plot/$plotId] status=${claimsRes.statusCode}, body=${claimsRes.body}",
//         );

//         if (claimsRes.statusCode == 200) {
//           final list = json.decode(claimsRes.body) as List<dynamic>;
//           for (final item in list) {
//             final m = item as Map<String, dynamic>;
//             allClaims.add(_fromBackend(m, userId));
//           }
//         }
//       }

//       print("✅ [LOAD_CLAIMS] totalClaimsLoaded=${allClaims.length}");

//       _claims = allClaims;
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       print("❌ [ERROR loadClaims] $e");
//       _error = 'Failed to load claims: $e';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ===================== STEP 1: ADD CLAIM (TEXT ONLY) ======================

//   /// Sirf text info se claim create karega (no evidence here)
//   /// Backend: POST /api/claim/
//   Future<bool> addClaim(Claim claim) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//       final userId = prefs.getString('user_id');
//       if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
//         _error = 'Not authenticated';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }

//       final body = {
//         'claim_reason': _disasterToReason(claim.disasterType),
//         'estimated_loss_amount': claim.estimatedValue,
//         'description': claim.description,
//         'crop_cycle_id': claim.cropId,
//         // image_urls nahi bhej rahe, evidence alag API me jayega
//         'image_urls': [],
//       };

//       final url = '$baseUrl/api/claim/';
//       print("🔥 [POST] $url body=$body");

//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(body),
//       );

//       print(
//         "📩 [RESP POST /api/claim/] status=${res.statusCode}, body=${res.body}",
//       );

//       if (res.statusCode == 201 || res.statusCode == 200) {
//         final m = json.decode(res.body) as Map<String, dynamic>;
//         print("✅ [CREATE_CLAIM] responseMap=$m");

//         final createdClaim = _fromBackend(m, userId).copyWith(
//           disasterType: claim.disasterType,
//           estimatedLoss: claim.estimatedLoss,
//           disasterDate: claim.disasterDate,
//         );

//         print("✅ [CREATE_CLAIM] createdClaimId=${createdClaim.id}");

//         _claims.add(createdClaim);
//         _error = null;
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         try {
//           final err = json.decode(res.body);
//           _error = err['detail']?.toString() ?? 'Failed to submit claim';
//           print("❌ [CREATE_CLAIM] error=$_error");
//         } catch (_) {
//           _error = 'Failed to submit claim (${res.statusCode})';
//         }
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       print("❌ [ERROR addClaim] $e");
//       _error = 'Failed to submit claim: $e';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // ===================== STEP 2: UPLOAD EVIDENCE ======================

//   /// Existing claimId ke liye images upload karega
//   /// Backend: POST /api/claim/{claim_id}/upload-evidence
//   Future<bool> uploadEvidence(String claimId, List<XFile> files) async {
//     if (files.isEmpty) {
//       print("⚠️ [UPLOAD_EVIDENCE] no files provided");
//       return false;
//     }

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//       if (token == null || token.isEmpty) {
//         _error = 'Not authenticated';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }

//       print(
//         "🔥 [UPLOAD_EVIDENCE] claimId=$claimId, filesCount=${files.length}",
//       );

//       final List<String> uploadedUrls = [];

//       for (final f in files) {
//         final url = '$baseUrl/api/claim/$claimId/upload-evidence';
//         print("🔥 [POST] $url fileName=${f.name}");

//         final bytes = await f.readAsBytes();

//         final request = http.MultipartRequest(
//           'POST',
//           Uri.parse(url),
//         );
//         request.headers['Authorization'] = 'Bearer $token';
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file', // FastAPI param name
//             bytes,
//             filename: f.name,
//           ),
//         );

//         final resp = await request.send();
//         final bodyText = await resp.stream.bytesToString();
//         print(
//           "📩 [RESP upload-evidence] status=${resp.statusCode}, body=$bodyText",
//         );

//         if (resp.statusCode == 200 || resp.statusCode == 201) {
//           try {
//             final bj = json.decode(bodyText) as Map<String, dynamic>;
//             final evidence = bj['evidence'] as Map<String, dynamic>?;
//             final urlStr = evidence?['url']?.toString();
//             print("✅ [UPLOAD_EVIDENCE] parsedEvidence=$evidence");
//             if (urlStr != null && urlStr.isNotEmpty) {
//               uploadedUrls.add(urlStr);
//             }
//           } catch (e) {
//             print("⚠️ [WARN parse evidence] $e");
//           }
//         } else {
//           String msg = 'Failed to upload evidence';
//           try {
//             final parsed = json.decode(bodyText) as Map<String, dynamic>;
//             if (parsed['detail'] != null) {
//               msg = parsed['detail'].toString();
//             }
//           } catch (_) {}
//           print("❌ [UPLOAD_EVIDENCE] error=$msg");
//           _error = msg;
//           _isLoading = false;
//           notifyListeners();
//           return false;
//         }
//       }

//       print("✅ [UPLOAD_EVIDENCE] uploadedUrls=$uploadedUrls");

//       // local state me bhi urls update kar dete hain
//       if (uploadedUrls.isNotEmpty) {
//         final index = _claims.indexWhere((c) => c.id == claimId);
//         if (index != -1) {
//           final existing = _claims[index];
//           final newList = [...existing.imageUrls, ...uploadedUrls];
//           _claims[index] = existing.copyWith(imageUrls: newList);
//           print(
//             "✅ [UPLOAD_EVIDENCE] localClaimUpdated claimId=$claimId totalImages=${newList.length}",
//           );
//         } else {
//           print("⚠️ [UPLOAD_EVIDENCE] claimId=$claimId not found locally");
//         }
//       }

//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       print("❌ [ERROR uploadEvidence] $e");
//       _error = 'Failed to upload evidence: $e';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // optional helper: one-shot flow
//   Future<bool> addClaimWithFiles(Claim claim, {List<XFile>? files}) async {
//     final prevCount = _claims.length;
//     print("ℹ️ [ADD_CLAIM_WITH_FILES] starting, prevCount=$prevCount");
//     final ok = await addClaim(
//       claim.copyWith(imageUrls: const []),
//     );
//     if (!ok) return false;
//     if (_claims.length <= prevCount) return true;

//     final createdClaim = _claims.last;
//     print("✅ [ADD_CLAIM_WITH_FILES] createdClaimId=${createdClaim.id}");
//     if (files == null || files.isEmpty) return true;

//     return await uploadEvidence(createdClaim.id, files);
//   }

//   // ===================== LOCAL STATUS UPDATE (optional) ======================

//   Future<bool> updateClaimStatus(String claimId, ClaimStatus newStatus) async {
//     try {
//       final index = _claims.indexWhere((claim) => claim.id == claimId);
//       if (index != -1) {
//         _claims[index] = _claims[index].copyWith(
//           status: newStatus,
//           updatedAt: DateTime.now(),
//         );
//         notifyListeners();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       _error = 'Failed to update claim status: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   Claim? getClaimById(String id) {
//     try {
//       return _claims.firstWhere((claim) => claim.id == id);
//     } catch (_) {
//       return null;
//     }
//   }

//   List<Claim> getClaimsByStatus(ClaimStatus status) {
//     return _claims.where((claim) => claim.status == status).toList();
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // ===================== BACKEND → MODEL MAPPER ======================

//   Claim _fromBackend(Map<String, dynamic> m, String userId) {
//     final statusStr = (m['status'] ?? 'pending').toString();

//     List<String> imageList = (m['image_urls'] as List<dynamic>? ?? [])
//         .map((e) => e.toString())
//         .toList();

//     if (imageList.isEmpty) {
//       final ev = (m['evidences'] as List<dynamic>? ?? []);
//       imageList = ev
//           .map((e) => (e as Map<String, dynamic>)['url']?.toString() ?? '')
//           .where((s) => s.isNotEmpty)
//           .toList();
//     }

//     final estimated = (m['estimated_loss_amount'] is num)
//         ? (m['estimated_loss_amount'] as num).toDouble()
//         : 0.0;

//     final claim = Claim(
//       id: (m['id'] ?? '').toString(),
//       farmerId: (m['farmer_id'] ?? userId).toString(),
//       cropId: (m['crop_cycle_id'] ?? '').toString(),
//       disasterType: _reasonToDisaster((m['claim_reason'] ?? '').toString()),
//       description: (m['description'] ?? '').toString(),
//       estimatedLoss: estimated,
//       estimatedValue: estimated,
//       imageUrls: imageList,
//       status: _parseStatus(statusStr),
//       disasterDate: _parseDateTime(m['disaster_date']) ?? DateTime.now(),
//       createdAt: _parseDateTime(m['created_at']) ?? DateTime.now(),
//       updatedAt: _parseDateTime(m['updated_at']) ?? DateTime.now(),
//       remarks: (m['admin_notes'] as String?),
//       approvedAmount: m['approved_amount'] is num
//           ? (m['approved_amount'] as num).toDouble()
//           : null,
//       paymentDate: _parseDateTime(m['payment_date']),
//     );

//     print("ℹ️ [_fromBackend] mappedClaimId=${claim.id}");
//     return claim;
//   }

//   ClaimStatus _parseStatus(String s) {
//     switch (s.toLowerCase()) {
//       case 'pending':
//         return ClaimStatus.underReview;
//       case 'under_inspection':
//         return ClaimStatus.verified;
//       case 'approved':
//         return ClaimStatus.approved;
//       case 'paid':
//         return ClaimStatus.paid;
//       case 'rejected':
//         return ClaimStatus.rejected;
//       default:
//         return ClaimStatus.underReview;
//     }
//   }

//   DisasterType _reasonToDisaster(String r) {
//     switch (r.toLowerCase()) {
//       case 'flood':
//         return DisasterType.flood;
//       case 'drought':
//         return DisasterType.drought;
//       case 'pest attack':
//       case 'pest':
//         return DisasterType.pestAttack;
//       case 'disease':
//         return DisasterType.disease;
//       case 'hailstorm':
//         return DisasterType.hailstorm;
//       case 'cyclone':
//         return DisasterType.cyclone;
//       case 'fire':
//         return DisasterType.fire;
//       default:
//         return DisasterType.other;
//     }
//   }

//   String _disasterToReason(DisasterType d) {
//     switch (d) {
//       case DisasterType.flood:
//         return 'flood';
//       case DisasterType.drought:
//         return 'drought';
//       case DisasterType.pestAttack:
//         return 'pest attack';
//       case DisasterType.disease:
//         return 'disease';
//       case DisasterType.hailstorm:
//         return 'hailstorm';
//       case DisasterType.cyclone:
//         return 'cyclone';
//       case DisasterType.fire:
//         return 'fire';
//       case DisasterType.other:
//         return 'other';
//     }
//   }

//   DateTime? _parseDateTime(dynamic v) {
//     if (v == null) return null;
//     try {
//       return DateTime.parse(v.toString());
//     } catch (_) {
//       return null;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/claim_model.dart';

class ClaimProvider with ChangeNotifier {
  List<Claim> _claims = [];
  bool _isLoading = false;
  String? _error;

  // Web vs Android emulator ke hisaab se baseUrl
  static const String baseUrl =
      kIsWeb ? 'http://localhost:8000' : 'http://192.168.22.159:8000';

  List<Claim> get claims => _claims;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ===================== LOAD CLAIMS (GET APIs) ======================
  Future<void> loadClaims() async {
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
        return;
      }

      // 1) GET /api/plots/me
      final plotsUrl = '$baseUrl/api/plots/me';
      print("🔥 [GET] $plotsUrl");
      final plotsRes = await http.get(
        Uri.parse(plotsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      print(
        "📩 [RESP /api/plots/me] status=${plotsRes.statusCode}, body=${plotsRes.body}",
      );

      if (plotsRes.statusCode != 200) {
        _error = 'Failed to load plots for claims';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final plots = (json.decode(plotsRes.body) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final List<Claim> allClaims = [];

      // 2) har plot ke liye GET /api/claim/plot/{plot_id}
      for (final p in plots) {
        final plotId = (p['id'] ?? '').toString();
        if (plotId.isEmpty) continue;

        final url = '$baseUrl/api/claim/plot/$plotId';
        print("🔥 [GET] $url");

        final claimsRes = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        print(
          "📩 [RESP /api/claim/plot/$plotId] status=${claimsRes.statusCode}, body=${claimsRes.body}",
        );

        if (claimsRes.statusCode == 200) {
          final list = json.decode(claimsRes.body) as List<dynamic>;
          for (final item in list) {
            final m = item as Map<String, dynamic>;
            allClaims.add(_fromBackend(m, userId));
          }
        }
      }

      print("✅ [LOAD_CLAIMS] totalClaimsLoaded=${allClaims.length}");

      _claims = allClaims;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("❌ [ERROR loadClaims] $e");
      _error = 'Failed to load claims: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== STEP 1: ADD CLAIM (TEXT ONLY) ======================

  /// Sirf text info se claim create karega (no evidence here)
  /// Backend: POST /api/claim/
  Future<bool> addClaim(Claim claim) async {
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
        return false;
      }

      final body = {
        'claim_reason': _disasterToReason(claim.disasterType),
        'estimated_loss_amount': claim.estimatedValue,
        'description': claim.description,
        'crop_cycle_id': claim.cropId,
        // image_urls nahi bhej rahe, evidence alag API me jayega
        'image_urls': [],
      };

      final url = '$baseUrl/api/claim/';
      print("🔥 [POST] $url body=$body");

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print(
        "📩 [RESP POST /api/claim/] status=${res.statusCode}, body=${res.body}",
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final m = json.decode(res.body) as Map<String, dynamic>;
        print("✅ [CREATE_CLAIM] responseMap=$m");

        final createdClaim = _fromBackend(m, userId).copyWith(
          disasterType: claim.disasterType,
          estimatedLoss: claim.estimatedLoss,
          disasterDate: claim.disasterDate,
        );

        print("✅ [CREATE_CLAIM] createdClaimId=${createdClaim.id}");

        _claims.add(createdClaim);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Failed to submit claim';
          print("❌ [CREATE_CLAIM] error=$_error");
        } catch (_) {
          _error = 'Failed to submit claim (${res.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("❌ [ERROR addClaim] $e");
      _error = 'Failed to submit claim: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===================== STEP 2: UPLOAD EVIDENCE ======================

  /// Existing claimId ke liye images upload karega
  /// Backend: POST /api/claim/{claim_id}/upload-evidence
  Future<bool> uploadEvidence(String claimId, List<XFile> files) async {
    if (files.isEmpty) {
      print("⚠️ [UPLOAD_EVIDENCE] no files provided");
      return false;
    }

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

      print(
        "🔥 [UPLOAD_EVIDENCE] claimId=$claimId, filesCount=${files.length}",
      );

      final List<String> uploadedUrls = [];

      for (final f in files) {
        final url = '$baseUrl/api/claim/$claimId/upload-evidence';
        print("🔥 [POST] $url fileName=${f.name}");

        final bytes = await f.readAsBytes();

        final request = http.MultipartRequest(
          'POST',
          Uri.parse(url),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // FastAPI param name
            bytes,
            filename: f.name,
          ),
        );

        final resp = await request.send();
        final bodyText = await resp.stream.bytesToString();
        print(
          "📩 [RESP upload-evidence] status=${resp.statusCode}, body=$bodyText",
        );

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          try {
            final bj = json.decode(bodyText) as Map<String, dynamic>;
            final evidence = bj['evidence'] as Map<String, dynamic>?;
            final urlStr = evidence?['url']?.toString();
            print("✅ [UPLOAD_EVIDENCE] parsedEvidence=$evidence");
            if (urlStr != null && urlStr.isNotEmpty) {
              uploadedUrls.add(urlStr);
            }
          } catch (e) {
            print("⚠️ [WARN parse evidence] $e");
          }
        } else {
          String msg = 'Failed to upload evidence';
          try {
            final parsed = json.decode(bodyText) as Map<String, dynamic>;
            if (parsed['detail'] != null) {
              msg = parsed['detail'].toString();
            }
          } catch (_) {}
          print("❌ [UPLOAD_EVIDENCE] error=$msg");
          _error = msg;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      print("✅ [UPLOAD_EVIDENCE] uploadedUrls=$uploadedUrls");

      // local state me bhi urls update kar dete hain
      if (uploadedUrls.isNotEmpty) {
        final index = _claims.indexWhere((c) => c.id == claimId);
        if (index != -1) {
          final existing = _claims[index];
          final newList = [...existing.imageUrls, ...uploadedUrls];
          _claims[index] = existing.copyWith(imageUrls: newList);
          print(
            "✅ [UPLOAD_EVIDENCE] localClaimUpdated claimId=$claimId totalImages=${newList.length}",
          );
        } else {
          print("⚠️ [UPLOAD_EVIDENCE] claimId=$claimId not found locally");
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ [ERROR uploadEvidence] $e");
      _error = 'Failed to upload evidence: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // optional helper: one-shot flow
  Future<bool> addClaimWithFiles(Claim claim, {List<XFile>? files}) async {
    final prevCount = _claims.length;
    print("ℹ️ [ADD_CLAIM_WITH_FILES] starting, prevCount=$prevCount");
    final ok = await addClaim(
      claim.copyWith(imageUrls: const []),
    );
    if (!ok) return false;
    if (_claims.length <= prevCount) return true;

    final createdClaim = _claims.last;
    print("✅ [ADD_CLAIM_WITH_FILES] createdClaimId=${createdClaim.id}");
    if (files == null || files.isEmpty) return true;

    return await uploadEvidence(createdClaim.id, files);
  }

  // ===================== LOCAL STATUS UPDATE (optional) ======================

  Future<bool> updateClaimStatus(String claimId, ClaimStatus newStatus) async {
    try {
      final index = _claims.indexWhere((claim) => claim.id == claimId);
      if (index != -1) {
        _claims[index] = _claims[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update claim status: $e';
      notifyListeners();
      return false;
    }
  }

  Claim? getClaimById(String id) {
    try {
      return _claims.firstWhere((claim) => claim.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Claim> getClaimsByStatus(ClaimStatus status) {
    return _claims.where((claim) => claim.status == status).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ===================== BACKEND → MODEL MAPPER ======================

  Claim _fromBackend(Map<String, dynamic> m, String userId) {
    final statusStr = (m['status'] ?? 'pending').toString();

    List<String> imageList = (m['image_urls'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    if (imageList.isEmpty) {
      final ev = (m['evidences'] as List<dynamic>? ?? []);
      imageList = ev
          .map((e) => (e as Map<String, dynamic>)['url']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final estimated = (m['estimated_loss_amount'] is num)
        ? (m['estimated_loss_amount'] as num).toDouble()
        : 0.0;

    final claim = Claim(
      id: (m['id'] ?? '').toString(),
      farmerId: (m['farmer_id'] ?? userId).toString(),
      cropId: (m['crop_cycle_id'] ?? '').toString(),
      disasterType: _reasonToDisaster((m['claim_reason'] ?? '').toString()),
      description: (m['description'] ?? '').toString(),
      estimatedLoss: estimated,
      estimatedValue: estimated,
      imageUrls: imageList,
      status: _parseStatus(statusStr),
      disasterDate: _parseDateTime(m['disaster_date']) ?? DateTime.now(),
      createdAt: _parseDateTime(m['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(m['updated_at']) ?? DateTime.now(),
      remarks: (m['admin_notes'] as String?),
      approvedAmount: m['approved_amount'] is num
          ? (m['approved_amount'] as num).toDouble()
          : null,
      paymentDate: _parseDateTime(m['payment_date']),
    );

    print("ℹ️ [_fromBackend] mappedClaimId=${claim.id}");
    return claim;
  }

  ClaimStatus _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return ClaimStatus.underReview;
      case 'under_inspection':
        return ClaimStatus.verified;
      case 'approved':
        return ClaimStatus.approved;
      case 'paid':
        return ClaimStatus.paid;
      case 'rejected':
        return ClaimStatus.rejected;
      default:
        return ClaimStatus.underReview;
    }
  }

  DisasterType _reasonToDisaster(String r) {
    switch (r.toLowerCase()) {
      case 'flood':
        return DisasterType.flood;
      case 'drought':
        return DisasterType.drought;
      case 'pest attack':
      case 'pest':
        return DisasterType.pestAttack;
      case 'disease':
        return DisasterType.disease;
      case 'hailstorm':
        return DisasterType.hailstorm;
      case 'cyclone':
        return DisasterType.cyclone;
      case 'fire':
        return DisasterType.fire;
      default:
        return DisasterType.other;
    }
  }

  String _disasterToReason(DisasterType d) {
    switch (d) {
      case DisasterType.flood:
        return 'flood';
      case DisasterType.drought:
        return 'drought';
      case DisasterType.pestAttack:
        return 'pest attack';
      case DisasterType.disease:
        return 'disease';
      case DisasterType.hailstorm:
        return 'hailstorm';
      case DisasterType.cyclone:
        return 'cyclone';
      case DisasterType.fire:
        return 'fire';
      case DisasterType.other:
        return 'other';
    }
  }

  DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }
}