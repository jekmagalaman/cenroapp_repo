import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/certificate_model.dart';
import '../models/photo_report_model.dart';
import 'auth_service.dart';

/// Sends certificates to the admin backend.
class ApiService {
  /// Uploads one certificate. On success returns the model merged with the
  /// server response (including the assigned [controlNumber] for new certs).
  /// Returns null if the request failed.
  static Future<CertificateModel?> uploadCertificate(CertificateModel cert) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return null;

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
      final code = response.statusCode;
      if (code != 201 && code != 200) return null;

      final needsAssignedNumber =
          cert.usesLocalControlPlaceholder || cert.controlNumber.trim().isEmpty;

      try {
        final map =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final merged = CertificateModel.fromApiResponse(map, cert);
        if (needsAssignedNumber &&
            merged.controlNumber.trim().isNotEmpty &&
            !merged.usesLocalControlPlaceholder) {
          return merged.copyWith(syncStatus: CertificateModel.syncStatusSynced);
        }
        if (!needsAssignedNumber) {
          return merged.copyWith(syncStatus: CertificateModel.syncStatusSynced);
        }
        return null;
      } catch (_) {
        if (!needsAssignedNumber) {
          return cert.copyWith(syncStatus: CertificateModel.syncStatusSynced);
        }
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<bool> uploadPhotoReport(PhotoReportModel report) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return false;

    final baseUrl = await AuthService.getBaseUrl();
    final url = Uri.parse('$baseUrl/api/photo-reports/');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Token $token';
      request.fields['description'] = report.description;
      if (report.latitude != null) request.fields['latitude'] = report.latitude!.toString();
      if (report.longitude != null) request.fields['longitude'] = report.longitude!.toString();
      if (report.accuracyMeters != null) request.fields['accuracy_meters'] = report.accuracyMeters!.toString();

      final file = File(report.imagePath);
      if (!await file.exists()) return false;
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
