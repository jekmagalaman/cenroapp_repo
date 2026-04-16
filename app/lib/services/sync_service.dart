import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/db_helper.dart';
import '../models/photo_report_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Result of [SyncService.syncPendingToServer].
class SyncOutcome {
  /// Not logged in (same as legacy -1).
  final bool notLoggedIn;

  /// No Wi‑Fi / mobile data.
  final bool noConnection;

  /// Rows that were Pending before upload attempts.
  final int pendingCount;

  /// Successfully uploaded and marked Synced.
  final int synced;

  /// Still Pending after a failed upload attempt.
  final int failed;

  const SyncOutcome({
    this.notLoggedIn = false,
    this.noConnection = false,
    this.pendingCount = 0,
    this.synced = 0,
    this.failed = 0,
  });
}

/// Syncs pending certificates from the app to the admin backend.
class SyncService {
  static Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  /// Uploads all Pending certificates to the API and marks them Synced on success.
  static Future<SyncOutcome> syncPendingToServer() async {
    if (!await hasConnection()) {
      return const SyncOutcome(noConnection: true);
    }
    if (await AuthService.getToken() == null) {
      return const SyncOutcome(notLoggedIn: true);
    }

    final db = DbHelper();
    final pending = await db.getPendingCertificates();
    final pendingReports = await db.getPendingPhotoReports();
    if (pending.isEmpty && pendingReports.isEmpty) return const SyncOutcome();

    var synced = 0;
    var failed = 0;

    for (final cert in pending) {
      final updated = await ApiService.uploadCertificate(cert);
      if (updated != null) {
        await db.updateCertificate(updated);
        synced++;
      } else {
        failed++;
      }
    }

    for (final r in pendingReports) {
      final ok = await ApiService.uploadPhotoReport(r);
      if (ok) {
        await db.updatePhotoReport(r.copyWith(syncStatus: PhotoReportModel.syncStatusSynced));
        synced++;
      } else {
        failed++;
      }
    }

    return SyncOutcome(
      pendingCount: pending.length + pendingReports.length,
      synced: synced,
      failed: failed,
    );
  }
}
