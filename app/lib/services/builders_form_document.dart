import '../models/certificate_model.dart';

/// Field accessors for [CertificateModel.certificateType] == builders_form (motorizedData JSON).
/// Matches the official "BUILDERS FORM" / Sertipiko ng Pagkagawa template structure.
class BuildersFormData {
  BuildersFormData(this.cert)
      : m = cert.motorizedData ?? const <String, dynamic>{};

  final CertificateModel cert;
  final Map<String, dynamic> m;

  String _s(String k) => (m[k] ?? '').toString().trim();

  String get controlNumber => cert.controlNumber.trim();

  String get builderName => _s('builderName');
  String get builderAddress => _s('builderAddress');
  String get builderBarangayBuilt => _s('builderBarangayBuilt');

  String get ownerName => _s('ownerName');
  String get ownerAddress => _s('ownerAddress');
  String get ownerSitioPurok => _s('ownerSitioPurok');
  String get ownerBarangay => _s('ownerBarangay');

  String get vesselName => _s('vesselName');
  String get vesselTypeClass => _s('vesselTypeClass');
  String get materialsUsed => _s('materialsUsed');
  String get lengthOverall => _s('lengthOverall');
  String get breadthMolded => _s('breadthMolded');
  String get depthMolded => _s('depthMolded');
  String get numberOfDecks => _s('numberOfDecks');
  String get numberOfMasts => _s('numberOfMasts');
  String get grossTonnageBuilder => _s('grossTonnageBuilder');
  String get netTonnageBuilder => _s('netTonnageBuilder');
  String get dateFinishedLaunched => _s('dateFinishedLaunched');
  String get lifeVests => _s('lifeVests');

  String get engineType => _s('engineType');
  String get horsepowerModel => _s('horsepowerModel');
  String get serialNumber => _s('serialNumber');
  String get dateManufactured => _s('dateManufactured');
  String get numberOfCylinders => _s('numberOfCylinders');
  String get boreStroke => _s('boreStroke');
  String get rpm => _s('rpm');

  String get numberOfEngines {
    final v = _s('numberOfEngines');
    if (v.isNotEmpty) return v;
    return _splitLegacyEnginesScrews().$1;
  }

  String get numberOfPropellers {
    final v = _s('numberOfPropellers');
    if (v.isNotEmpty) return v;
    return _splitLegacyEnginesScrews().$2;
  }

  (String, String) _splitLegacyEnginesScrews() {
    final old = _s('numberOfEnginesScrews');
    if (old.isEmpty) return ('', '');
    if (old.contains('/')) {
      final p = old.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (p.length >= 2) return (p[0], p[1]);
      if (p.length == 1) return ('', p[0]);
    }
    return ('', old);
  }

  String get datePlaceIssued => _s('datePlaceIssued');
  String get builderSignature => _s('builderSignature');
  String get preparedBy => _s('preparedBy');

  String get oathDay => _s('oathDay');
  String get oathMonth => _s('oathMonth');
  String get oathYear => _s('oathYear');
  String get oathDate => _s('oathDate');

  String get residenceCertBlg => _s('residenceCertBlg');
  String get residenceCertIssued => _s('residenceCertIssued');
  String get residenceCertPlace => _s('residenceCertPlace');
  String get residenceCertDetails => _s('residenceCertDetails');

  String get applicantName => cert.applicantName.trim();
  String get applicantAddress => cert.applicantAddress.trim();
  String get licenseType => cert.licenseType.trim();
  String get natureOfBusiness => cert.natureOfBusiness.trim();
  String get businessName => cert.businessName.trim();
  String get businessAddress => cert.businessAddress.trim();
  String get contactNumber => cert.contactNumber.trim();
  String get issuedDate => cert.issuedDate.trim();
  String get inspectorName => cert.inspectorName.trim();
}
