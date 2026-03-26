import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/certificate_model.dart';
import 'auth_service.dart';

/// Sends certificates to the admin backend.
class ApiService {
  static Future<bool> uploadCertificate(CertificateModel cert) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return false;

    final baseUrl = await AuthService.getBaseUrl();
    final url = Uri.parse('$baseUrl/api/certificates/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(cert.toApiJson()),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
