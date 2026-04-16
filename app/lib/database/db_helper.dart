import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/certificate_model.dart';
import '../models/photo_report_model.dart';

/// SQLite database helper for certificates
class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cenro_certificates.db');

    return openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE certificates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        controlNumber TEXT NOT NULL,
        certificateType TEXT NOT NULL,
        applicantName TEXT NOT NULL,
        applicantAddress TEXT NOT NULL,
        licenseType TEXT NOT NULL,
        natureOfBusiness TEXT NOT NULL,
        businessName TEXT NOT NULL,
        businessAddress TEXT NOT NULL,
        contactNumber TEXT NOT NULL,
        issuedDate TEXT NOT NULL,
        inspectorName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'Pending',
        motorizedData TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE photo_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        description TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        accuracyMeters REAL,
        createdAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'Pending'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE certificates ADD COLUMN syncStatus TEXT NOT NULL DEFAULT 'Pending'",
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE certificates ADD COLUMN motorizedData TEXT",
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE certificates ADD COLUMN certificateType TEXT NOT NULL DEFAULT 'marine_certification'",
      );
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE photo_reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          imagePath TEXT NOT NULL,
          description TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          syncStatus TEXT NOT NULL DEFAULT 'Pending'
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute("ALTER TABLE photo_reports ADD COLUMN latitude REAL");
      await db.execute("ALTER TABLE photo_reports ADD COLUMN longitude REAL");
      await db.execute("ALTER TABLE photo_reports ADD COLUMN accuracyMeters REAL");
    }
  }

  /// Insert a new certificate
  Future<int> insertCertificate(CertificateModel certificate) async {
    final db = await database;
    return db.insert('certificates', certificate.toMap());
  }

  /// Get all certificates
  Future<List<CertificateModel>> getAllCertificates() async {
    final db = await database;
    final maps = await db.query('certificates', orderBy: 'createdAt DESC');
    return maps.map((m) => CertificateModel.fromMap(m)).toList();
  }

  /// Search certificates by term
  Future<List<CertificateModel>> searchCertificates(String query) async {
    final db = await database;
    final maps = await db.query(
      'certificates',
      where:
          'controlNumber LIKE ? OR applicantName LIKE ? OR businessName LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => CertificateModel.fromMap(m)).toList();
  }

  /// Get certificates with syncStatus = Pending (for sync to server)
  Future<List<CertificateModel>> getPendingCertificates() async {
    final db = await database;
    final maps = await db.query(
      'certificates',
      where: 'syncStatus = ?',
      whereArgs: [CertificateModel.syncStatusPending],
      orderBy: 'id ASC',
    );
    return maps.map((m) => CertificateModel.fromMap(m)).toList();
  }

  /// Get certificates filtered by date
  Future<List<CertificateModel>> getCertificatesByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'certificates',
      where: 'issuedDate = ?',
      whereArgs: [date],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => CertificateModel.fromMap(m)).toList();
  }

  /// Get single certificate by ID
  Future<CertificateModel?> getCertificateById(int id) async {
    final db = await database;
    final maps =
        await db.query('certificates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CertificateModel.fromMap(maps.first);
  }

  /// Latest row for this control number and certificate type (for renewal lookup).
  Future<CertificateModel?> getLatestCertificateByControlNumberAndType(
    String controlNumber,
    String certificateType,
  ) async {
    final db = await database;
    final cn = controlNumber.trim();
    if (cn.isEmpty) return null;
    final maps = await db.query(
      'certificates',
      where: 'controlNumber = ? AND certificateType = ?',
      whereArgs: [cn, certificateType],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CertificateModel.fromMap(maps.first);
  }

  /// Update certificate
  Future<int> updateCertificate(CertificateModel certificate) async {
    final db = await database;
    return db.update(
      'certificates',
      certificate.toMap(),
      where: 'id = ?',
      whereArgs: [certificate.id],
    );
  }

  /// Delete certificate
  Future<int> deleteCertificate(int id) async {
    final db = await database;
    return db.delete('certificates', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPhotoReport(PhotoReportModel report) async {
    final db = await database;
    return db.insert('photo_reports', report.toMap());
  }

  Future<List<PhotoReportModel>> getPendingPhotoReports() async {
    final db = await database;
    final maps = await db.query(
      'photo_reports',
      where: 'syncStatus = ?',
      whereArgs: [PhotoReportModel.syncStatusPending],
      orderBy: 'id ASC',
    );
    return maps.map((m) => PhotoReportModel.fromMap(m)).toList();
  }

  Future<List<PhotoReportModel>> getAllPhotoReports() async {
    final db = await database;
    final maps = await db.query('photo_reports', orderBy: 'id DESC');
    return maps.map((m) => PhotoReportModel.fromMap(m)).toList();
  }

  Future<int> deletePhotoReport(int id) async {
    final db = await database;
    return db.delete('photo_reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePhotoReport(PhotoReportModel report) async {
    final db = await database;
    return db.update(
      'photo_reports',
      report.toMap(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }
}
