import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Outcome of [AuthService.login].
typedef AuthLoginOutcome = ({bool ok, String? error});

/// Handles inspector login and token storage for syncing to admin backend.
class AuthService {
  static const _tokenKey = 'auth_token';
  static const _baseUrlKey = 'api_base_url';

  /// Default for Android emulator: host PC at port 8000. On a real phone, set
  /// "Server URL" on the login screen to `http://<your-PC-LAN-IP>:8000` (same Wi‑Fi).
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';

  static String normalizeBaseUrl(String raw) {
    var u = raw.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (u.isEmpty) return u;
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'http://$u';
    }
    return u;
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, normalizeBaseUrl(url));
  }

  static Future<AuthLoginOutcome> login(
    String username,
    String password,
  ) async {
    final baseUrl = await getBaseUrl();
    if (baseUrl.isEmpty) {
      return (ok: false, error: 'Enter a server URL (e.g. http://192.168.1.5:8000).');
    }
    final url = Uri.parse('$baseUrl/api/auth/login/');
    try {
      final response = await http.post(
        url,
        body: {'username': username, 'password': password},
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          return (ok: true, error: null);
        }
      }
      return (ok: false, error: 'Invalid username or password.');
    } on SocketException {
      return (
        ok: false,
        error:
            'Cannot reach the server. Use your PC\'s Wi‑Fi IP (not localhost), same network, and check the port.',
      );
    } on FormatException {
      return (ok: false, error: 'Invalid server URL.');
    } catch (_) {
      return (
        ok: false,
        error:
            'Connection failed. Check Wi‑Fi, firewall, and that the admin API is running.',
      );
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> get isLoggedIn async => (await getToken()) != null;

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
