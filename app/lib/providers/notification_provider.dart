import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🔥 ALWAYS use devtunnel URL (app + web)
  static String get _baseUrl =>
      "https://bcl96b99-8001.inc1.devtunnels.ms";

  Future<void> fetchNotifications({
    required String userId,
    String? token,
  }) async {
    if (token == null || token.isEmpty) {
      _error = 'You are not logged in.';
      _notifications.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("$_baseUrl/api/notifications/farmer/$userId");
      debugPrint('Fetching notifications from: $uri');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Notifications response: ${res.statusCode}');

      if (res.statusCode != 200) {
        _error = 'Unable to load notifications. Please try again.';
        _notifications.clear();
        return;
      }

      final body = json.decode(res.body);

      if (body is! List) {
        _error = 'Unexpected response from server.';
        _notifications.clear();
        return;
      }

      _notifications
        ..clear()
        ..addAll(
          body
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
    } on http.ClientException catch (e, st) {
      debugPrint('ClientException while fetching notifications: $e\n$st');
      _error =
          'Could not reach the server. Please check your internet or try again.';
      _notifications.clear();
    } catch (e, st) {
      debugPrint('Unknown error while fetching notifications: $e\n$st');
      _error = 'Something went wrong while loading notifications.';
      _notifications.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead({
    required String notifId,
    String? token,
  }) async {
    if (token == null || token.isEmpty) {
      debugPrint('markAsRead called without token, skipping');
      return;
    }

    try {
      final uri = Uri.parse("$_baseUrl/api/notifications/$notifId/read");

      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final idx = _notifications.indexWhere((n) => n.id == notifId);
        if (idx != -1) {
          final old = _notifications[idx];
          _notifications[idx] = AppNotification(
            id: old.id,
            title: old.title,
            message: old.message,
            type: old.type,
            isRead: true,
            notificationDate: old.notificationDate,
            createdAt: old.createdAt,
          );
          notifyListeners();
        }
      } else {
        debugPrint(
          'Failed to mark as read: ${res.statusCode} ${res.body.toString()}',
        );
      }
    } catch (e, st) {
      debugPrint('Error in markAsRead: $e\n$st');
    }
  }
}
