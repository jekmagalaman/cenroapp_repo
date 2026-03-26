import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/db_helper.dart';
import '../models/certificate_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Syncs pending certificates from the app to the admin backend.
class SyncService {
  static Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  /// Uploads all Pending certificates to the API and marks them Synced on success.
  /// Returns number of certificates successfully synced.
  static Future<int> syncPendingToServer() async {
    if (!await hasConnection()) return 0;
    if (await AuthService.getToken() == null) return -1; // -1 = not logged in

    final db = DbHelper();
    final pending = await db.getPendingCertificates();
    int count = 0;

    for (final cert in pending) {
      final ok = await ApiService.uploadCertificate(cert);
      if (ok) {
        await db.updateCertificate(
          cert.copyWith(syncStatus: CertificateModel.syncStatusSynced),
        );
        count++;
      }
    }
    return count;
  }
}
