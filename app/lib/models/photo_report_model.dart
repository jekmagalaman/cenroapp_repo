class PhotoReportModel {
  static const syncStatusPending = 'Pending';
  static const syncStatusSynced = 'Synced';

  final int? id;
  final String imagePath;
  final String description;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String createdAt;
  final String syncStatus;

  const PhotoReportModel({
    this.id,
    required this.imagePath,
    required this.description,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.createdAt,
    required this.syncStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'createdAt': createdAt,
      'syncStatus': syncStatus,
    };
  }

  static PhotoReportModel fromMap(Map<String, dynamic> m) {
    return PhotoReportModel(
      id: m['id'] as int?,
      imagePath: (m['imagePath'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      latitude: (m['latitude'] == null) ? null : (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] == null) ? null : (m['longitude'] as num).toDouble(),
      accuracyMeters: (m['accuracyMeters'] == null) ? null : (m['accuracyMeters'] as num).toDouble(),
      createdAt: (m['createdAt'] ?? '').toString(),
      syncStatus: (m['syncStatus'] ?? syncStatusPending).toString(),
    );
  }

  PhotoReportModel copyWith({
    int? id,
    String? imagePath,
    String? description,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? createdAt,
    String? syncStatus,
  }) {
    return PhotoReportModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

