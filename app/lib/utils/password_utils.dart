import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  // Generate a random salt
  static String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return base64.encode(utf8.encode(random));
  }

  // Hash password with salt
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '$salt:${digest.toString()}';
  }

  // Verify password against hash
  static bool verifyPassword(String password, String hash) {
    try {
      final parts = hash.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      final storedHash = parts[1];
      
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      
      return digest.toString() == storedHash;
    } catch (e) {
      return false;
    }
  }
}
