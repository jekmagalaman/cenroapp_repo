/// Model for Certificate of Inspection data
class CertificateModel {
  final int? id;
  final String controlNumber;
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

  CertificateModel({
    this.id,
    required this.controlNumber,
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
  });

  /// Convert from database map
  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    return CertificateModel(
      id: map['id'] as int?,
      controlNumber: map['controlNumber'] as String,
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
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'controlNumber': controlNumber,
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
    };
  }

  CertificateModel copyWith({
    int? id,
    String? controlNumber,
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
  }) {
    return CertificateModel(
      id: id ?? this.id,
      controlNumber: controlNumber ?? this.controlNumber,
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
    );
  }
}
