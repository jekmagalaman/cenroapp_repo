import 'dart:convert';

/// Model for Certificate of Inspection data
class CertificateModel {
  static const String syncStatusPending = 'Pending';
  static const String syncStatusSynced = 'Synced';

  final int? id;
  final String controlNumber;
  final String certificateType;
  final String applicantName;
  final String applicantAddress;
  final String licenseType;
  final String natureOfBusiness;
  final String businessName;
  final String businessAddress;
  final String contactNumber;
  final String issuedDate;
  final String inspectorName;
  final String createdAt;
  final String syncStatus;
  final Map<String, dynamic>? motorizedData;

  CertificateModel({
    this.id,
    required this.controlNumber,
    required this.certificateType,
    required this.applicantName,
    required this.applicantAddress,
    required this.licenseType,
    required this.natureOfBusiness,
    required this.businessName,
    required this.businessAddress,
    required this.contactNumber,
    required this.issuedDate,
    required this.inspectorName,
    required this.createdAt,
    this.syncStatus = syncStatusPending,
    this.motorizedData,
  });

  /// Convert from database map
  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    return CertificateModel(
      id: map['id'] as int?,
      controlNumber: map['controlNumber'] as String,
      certificateType:
          (map['certificateType'] as String?) ?? 'marine_certification',
      applicantName: map['applicantName'] as String,
      applicantAddress: map['applicantAddress'] as String,
      licenseType: map['licenseType'] as String,
      natureOfBusiness: map['natureOfBusiness'] as String,
      businessName: map['businessName'] as String,
      businessAddress: map['businessAddress'] as String,
      contactNumber: map['contactNumber'] as String,
      issuedDate: map['issuedDate'] as String,
      inspectorName: map['inspectorName'] as String,
      createdAt: map['createdAt'] as String,
      syncStatus: (map['syncStatus'] as String?) ?? syncStatusPending,
      motorizedData: _decodeMotorizedData(map['motorizedData'] as String?),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'controlNumber': controlNumber,
      'certificateType': certificateType,
      'applicantName': applicantName,
      'applicantAddress': applicantAddress,
      'licenseType': licenseType,
      'natureOfBusiness': natureOfBusiness,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'contactNumber': contactNumber,
      'issuedDate': issuedDate,
      'inspectorName': inspectorName,
      'createdAt': createdAt,
      'syncStatus': syncStatus,
      'motorizedData': motorizedData == null ? null : jsonEncode(motorizedData),
    };
  }

  /// Payload for API (snake_case for Django REST)
  Map<String, dynamic> toApiJson() {
    return {
      'control_number': controlNumber,
      'certificate_type': certificateType,
      'applicant_name': applicantName,
      'applicant_address': applicantAddress,
      'license_type': licenseType,
      'nature_of_business': natureOfBusiness,
      'business_name': businessName,
      'business_address': businessAddress,
      'contact_number': contactNumber,
      'issued_date': issuedDate,
      'inspector_name': inspectorName,
    };
  }

  CertificateModel copyWith({
    int? id,
    String? controlNumber,
    String? certificateType,
    String? applicantName,
    String? applicantAddress,
    String? licenseType,
    String? natureOfBusiness,
    String? businessName,
    String? businessAddress,
    String? contactNumber,
    String? issuedDate,
    String? inspectorName,
    String? createdAt,
    String? syncStatus,
    Map<String, dynamic>? motorizedData,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      controlNumber: controlNumber ?? this.controlNumber,
      certificateType: certificateType ?? this.certificateType,
      applicantName: applicantName ?? this.applicantName,
      applicantAddress: applicantAddress ?? this.applicantAddress,
      licenseType: licenseType ?? this.licenseType,
      natureOfBusiness: natureOfBusiness ?? this.natureOfBusiness,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      issuedDate: issuedDate ?? this.issuedDate,
      inspectorName: inspectorName ?? this.inspectorName,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      motorizedData: motorizedData ?? this.motorizedData,
    );
  }

  static Map<String, dynamic>? _decodeMotorizedData(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}
