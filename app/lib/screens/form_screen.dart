import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/certificate_model.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';
import '../services/word_service.dart';
import '../services/file_storage_service.dart';

/// Form screen for creating/editing Certificate of Inspection
class FormScreen extends StatefulWidget {
  final CertificateModel? certificate;
  final String certificateType;

  /// When set from the issuance flow, hides New/Renew toggle: `'New'` or `'Renew'`.
  final String? licenseTypeLock;

  const FormScreen({
    super.key,
    this.certificate,
    this.certificateType = 'marine_certification',
    this.licenseTypeLock,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DbHelper();

  // Form controllers
  late TextEditingController _controlNumberController;
  late TextEditingController _applicantNameController;
  late TextEditingController _applicantAddressController;
  late TextEditingController _natureOfBusinessController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessAddressController;
  late TextEditingController _contactNumberController;
  late TextEditingController _inspectorNameController;
  late TextEditingController _motorizedBarangayController;
  late TextEditingController _fishingDeviceUseController;
  late TextEditingController _motorBancaNameController;
  late TextEditingController _grossTonnageController;
  late TextEditingController _registeredNumberController;
  late TextEditingController _greenStripeController;
  late TextEditingController _colorCodingController;
  late TextEditingController _dateOfConstructionController;
  late TextEditingController _carpenterNameController;
  late TextEditingController _placeBuiltController;
  late TextEditingController _engineTypeNoController;
  late TextEditingController _conformedSignatureController;
  late TextEditingController _lengthController;
  late TextEditingController _breadthController;
  late TextEditingController _depthController;
  late TextEditingController _netTonnageController;
  late TextEditingController _approvalSignatureController;
  late TextEditingController _receivedDateTimeController;
  late TextEditingController _releasedDateController;
  late TextEditingController _barangayController;

  late TextEditingController _releasedByController;
  late TextEditingController _builderNameController;
  late TextEditingController _builderAddressController;
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerAddressController;
  late TextEditingController _vesselNameController;
  late TextEditingController _vesselTypeClassController;
  late TextEditingController _materialsUsedController;
  late TextEditingController _lengthOverallController;
  late TextEditingController _breadthMoldedController;
  late TextEditingController _depthMoldedController;
  late TextEditingController _numberOfDecksController;
  late TextEditingController _numberOfMastsController;
  late TextEditingController _grossTonnageBuilderController;
  late TextEditingController _netTonnageBuilderController;
  late TextEditingController _dateFinishedLaunchedController;
  late TextEditingController _lifeVestsController;
  late TextEditingController _engineTypeController;
  late TextEditingController _horsepowerModelController;
  late TextEditingController _serialNumberController;
  late TextEditingController _dateManufacturedController;
  late TextEditingController _numberOfCylindersController;
  late TextEditingController _boreStrokeController;
  late TextEditingController _rpmController;
  late TextEditingController _numberOfEnginesOnlyController;
  late TextEditingController _numberOfPropellersController;
  late TextEditingController _datePlaceIssuedController;
  late TextEditingController _builderSignatureController;
  late TextEditingController _preparedByController;
  late TextEditingController _builderBarangayBuiltController;
  late TextEditingController _ownerSitioPurokController;
  late TextEditingController _ownerBarangayController;
  late TextEditingController _oathDayController;
  late TextEditingController _oathMonthController;
  late TextEditingController _oathYearController;
  late TextEditingController _oathDateController;
  late TextEditingController _residenceCertBlgController;
  late TextEditingController _residenceCertIssuedController;
  late TextEditingController _residenceCertPlaceController;
  late TextEditingController _residenceCertDetailsController;

  // Exclusive Fish Privilege controllers
  late TextEditingController _areaHasController;
  late TextEditingController _currentZoningController;
  late TextEditingController _locationController;
  late TextEditingController _kindOfLicenseController;
  late TextEditingController _signaturePrintedNameController;

  String _licenseType = 'New';

  DateTime _issuedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  int? _editingId;

  static const Map<String, String> _certificateTypeTitles = {
    'builders_form': 'Builders Form',
    'motorized_certification': 'Motorized Certification',
    'marine_certification': 'Marine Certification',
    'exclusive_fish_privilege': 'Exclusive Fish Privilege',
  };

  static const Map<String, String> _defaultNatureByType = {
    'builders_form': 'BUILDERS FORM APPLICATION',
    'motorized_certification': 'MOTORIZED CERTIFICATION APPLICATION',
    'marine_certification': 'MARINE CERTIFICATION APPLICATION',
    'exclusive_fish_privilege': 'EXCLUSIVE FISH PRIVILEGE APPLICATION',
  };

  bool get _isMotorized => widget.certificateType == 'motorized_certification';
  bool get _isBuilders => widget.certificateType == 'builders_form';

  /// Exclusive Fish Privilege form
  bool get _isExclusiveFish =>
      widget.certificateType == 'exclusive_fish_privilege';

  /// Creating a new row (not editing an existing saved certificate).
  bool get _isNewCertificate => widget.certificate == null;

  /// Renewals reuse the client's original control number; only New gets auto ID.
  bool get _controlNumberReadOnly =>
      _editingId != null || (_isNewCertificate && _licenseType == 'New');

  @override
  void initState() {
    super.initState();
    _controlNumberController = TextEditingController();
    _applicantNameController = TextEditingController();
    _applicantAddressController = TextEditingController();
    _natureOfBusinessController = TextEditingController(
      text: _defaultNatureByType[widget.certificateType] ??
          'MARINE CERTIFICATION APPLICATION',
    );
    _businessNameController = TextEditingController();
    _businessAddressController = TextEditingController();
    _contactNumberController = TextEditingController();
    _inspectorNameController = TextEditingController();
    _motorizedBarangayController = TextEditingController();
    _fishingDeviceUseController = TextEditingController();
    _motorBancaNameController = TextEditingController();
    _grossTonnageController = TextEditingController();
    _registeredNumberController = TextEditingController();
    _greenStripeController = TextEditingController();
    _colorCodingController = TextEditingController();
    _dateOfConstructionController = TextEditingController();
    _carpenterNameController = TextEditingController();
    _placeBuiltController = TextEditingController();
    _engineTypeNoController = TextEditingController();
    _conformedSignatureController = TextEditingController();
    _lengthController = TextEditingController();
    _breadthController = TextEditingController();
    _depthController = TextEditingController();
    _netTonnageController = TextEditingController();
    _approvalSignatureController = TextEditingController();
    _receivedDateTimeController = TextEditingController();
    _releasedDateController = TextEditingController();
    _barangayController = TextEditingController();

    _releasedByController = TextEditingController();
    _builderNameController = TextEditingController();
    _builderAddressController = TextEditingController();
    _ownerNameController = TextEditingController();
    _ownerAddressController = TextEditingController();
    _vesselNameController = TextEditingController();
    _vesselTypeClassController = TextEditingController();
    _materialsUsedController = TextEditingController();
    _lengthOverallController = TextEditingController();
    _breadthMoldedController = TextEditingController();
    _depthMoldedController = TextEditingController();
    _numberOfDecksController = TextEditingController();
    _numberOfMastsController = TextEditingController();
    _grossTonnageBuilderController = TextEditingController();
    _netTonnageBuilderController = TextEditingController();
    _dateFinishedLaunchedController = TextEditingController();
    _lifeVestsController = TextEditingController();
    _engineTypeController = TextEditingController();
    _horsepowerModelController = TextEditingController();
    _serialNumberController = TextEditingController();
    _dateManufacturedController = TextEditingController();
    _numberOfCylindersController = TextEditingController();
    _boreStrokeController = TextEditingController();
    _rpmController = TextEditingController();
    _numberOfEnginesOnlyController = TextEditingController();
    _numberOfPropellersController = TextEditingController();
    _datePlaceIssuedController = TextEditingController();
    _builderSignatureController = TextEditingController();
    _preparedByController = TextEditingController();
    _builderBarangayBuiltController = TextEditingController();
    _ownerSitioPurokController = TextEditingController();
    _ownerBarangayController = TextEditingController();
    _oathDayController = TextEditingController();
    _oathMonthController = TextEditingController();
    _oathYearController = TextEditingController();
    _oathDateController = TextEditingController();
    _residenceCertBlgController = TextEditingController();
    _residenceCertIssuedController = TextEditingController();
    _residenceCertPlaceController = TextEditingController();
    _residenceCertBlgController = TextEditingController();
    _residenceCertIssuedController = TextEditingController();
    _residenceCertPlaceController = TextEditingController();
    _residenceCertDetailsController = TextEditingController();

    // Exclusive Fish Privilege
    _areaHasController = TextEditingController();
    _currentZoningController = TextEditingController();
    _locationController = TextEditingController();
    _kindOfLicenseController = TextEditingController();
    _signaturePrintedNameController = TextEditingController();

    if (widget.certificate != null) {
      _loadCertificate(widget.certificate!);
    } else {
      if (widget.licenseTypeLock == 'New') {
        _licenseType = 'New';
      }
      // Official control numbers are assigned only by the server on sync.
      if (_licenseType == 'New') {
        _controlNumberController.text =
            CertificateModel.newLocalControlPlaceholder();
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onLicenseTypeSelectionChanged(Set<String> selection) async {
    if (widget.licenseTypeLock != null) return;
    final next = selection.first;
    if (next == _licenseType) return;
    setState(() => _licenseType = next);
    if (!_isNewCertificate) return;
    if (next == 'New') {
      _controlNumberController.text =
          CertificateModel.newLocalControlPlaceholder();
    } else {
      _controlNumberController.clear();
    }
    setState(() {});
  }

  void _loadCertificate(CertificateModel cert) {
    _editingId = cert.id;
    _controlNumberController.text = cert.controlNumber;
    _applicantNameController.text = cert.applicantName;
    _applicantAddressController.text = cert.applicantAddress;
    _licenseType = cert.licenseType;
    _natureOfBusinessController.text = cert.natureOfBusiness;
    _businessNameController.text = cert.businessName;
    _businessAddressController.text = cert.businessAddress;
    _contactNumberController.text = cert.contactNumber;
    _inspectorNameController.text = cert.inspectorName;
    final m = cert.motorizedData ?? const <String, dynamic>{};
    _motorizedBarangayController.text = (m['barangay'] ?? '').toString();

    _conformedSignatureController.text =
        (m['conformedSignature'] ?? '').toString();
    _fishingDeviceUseController.text = (m['fishingDeviceUse'] ?? '').toString();
    _registeredNumberController.text = (m['registeredNumber'] ?? '').toString();
    _motorBancaNameController.text = (m['motorBancaName'] ?? '').toString();
    _lengthController.text = (m['length'] ?? '').toString();
    _breadthController.text = (m['breadth'] ?? '').toString();
    _depthController.text = (m['depth'] ?? '').toString();
    _grossTonnageController.text = (m['grossTonnage'] ?? '').toString();
    _netTonnageController.text = (m['netTonnage'] ?? '').toString();
    _greenStripeController.text = (m['greenStripe'] ?? '').toString();
    _colorCodingController.text = (m['colorCoding'] ?? '').toString();
    _dateOfConstructionController.text =
        (m['dateOfConstruction'] ?? '').toString();
    _carpenterNameController.text = (m['carpenterName'] ?? '').toString();
    _placeBuiltController.text = (m['placeBuilt'] ?? '').toString();
    _engineTypeNoController.text = (m['engineTypeNo'] ?? '').toString();
    _approvalSignatureController.text =
        (m['approvalSignature'] ?? '').toString();
    _releasedByController.text = (m['releasedBy'] ?? '').toString();
    _receivedDateTimeController.text = (m['receivedDateTime'] ?? '').toString();
    _releasedDateController.text = (m['releasedDate'] ?? '').toString();
    _builderNameController.text = (m['builderName'] ?? '').toString();
    _builderAddressController.text = (m['builderAddress'] ?? '').toString();
    _ownerNameController.text = (m['ownerName'] ?? '').toString();
    _ownerAddressController.text = (m['ownerAddress'] ?? '').toString();
    _vesselNameController.text = (m['vesselName'] ?? '').toString();
    _vesselTypeClassController.text = (m['vesselTypeClass'] ?? '').toString();
    _materialsUsedController.text = (m['materialsUsed'] ?? '').toString();
    _lengthOverallController.text = (m['lengthOverall'] ?? '').toString();
    _breadthMoldedController.text = (m['breadthMolded'] ?? '').toString();
    _depthMoldedController.text = (m['depthMolded'] ?? '').toString();
    _numberOfDecksController.text = (m['numberOfDecks'] ?? '').toString();
    _numberOfMastsController.text = (m['numberOfMasts'] ?? '').toString();
    _grossTonnageBuilderController.text =
        (m['grossTonnageBuilder'] ?? '').toString();
    _netTonnageBuilderController.text =
        (m['netTonnageBuilder'] ?? '').toString();
    _dateFinishedLaunchedController.text =
        (m['dateFinishedLaunched'] ?? '').toString();
    _lifeVestsController.text = (m['lifeVests'] ?? '').toString();
    _engineTypeController.text = (m['engineType'] ?? '').toString();
    _horsepowerModelController.text = (m['horsepowerModel'] ?? '').toString();
    _serialNumberController.text = (m['serialNumber'] ?? '').toString();
    _dateManufacturedController.text = (m['dateManufactured'] ?? '').toString();
    _numberOfCylindersController.text =
        (m['numberOfCylinders'] ?? '').toString();
    _boreStrokeController.text = (m['boreStroke'] ?? '').toString();
    _rpmController.text = (m['rpm'] ?? '').toString();
    final neStr = (m['numberOfEngines'] ?? '').toString().trim();
    final npStr = (m['numberOfPropellers'] ?? '').toString().trim();
    if (neStr.isNotEmpty || npStr.isNotEmpty) {
      _numberOfEnginesOnlyController.text = neStr;
      _numberOfPropellersController.text = npStr;
    } else {
      final legacy = (m['numberOfEnginesScrews'] ?? '').toString().trim();
      if (legacy.contains('/')) {
        final p = legacy.split('/');
        _numberOfEnginesOnlyController.text = p.isNotEmpty ? p[0].trim() : '';
        _numberOfPropellersController.text = p.length > 1 ? p[1].trim() : '';
      } else {
        _numberOfPropellersController.text = legacy;
      }
    }
    _datePlaceIssuedController.text = (m['datePlaceIssued'] ?? '').toString();
    _builderSignatureController.text = (m['builderSignature'] ?? '').toString();
    _preparedByController.text = (m['preparedBy'] ?? '').toString();
    _builderBarangayBuiltController.text =
        (m['builderBarangayBuilt'] ?? '').toString();
    _ownerSitioPurokController.text = (m['ownerSitioPurok'] ?? '').toString();
    _ownerBarangayController.text = (m['ownerBarangay'] ?? '').toString();
    _oathDayController.text = (m['oathDay'] ?? '').toString();
    _oathMonthController.text = (m['oathMonth'] ?? '').toString();
    _oathYearController.text = (m['oathYear'] ?? '').toString();
    _oathDateController.text = (m['oathDate'] ?? '').toString();
    _residenceCertBlgController.text = (m['residenceCertBlg'] ?? '').toString();
    _residenceCertIssuedController.text =
        (m['residenceCertIssued'] ?? '').toString();
    _residenceCertPlaceController.text =
        (m['residenceCertPlace'] ?? '').toString();
    _residenceCertDetailsController.text =
        (m['residenceCertDetails'] ?? '').toString();
    // Exclusive Fish Privilege
    _areaHasController.text = (m['areaHas'] ?? '').toString();
    _currentZoningController.text = (m['currentZoning'] ?? '').toString();
    _locationController.text = (m['location'] ?? '').toString();
    _kindOfLicenseController.text = (m['kindOfLicense'] ?? '').toString();
    _signaturePrintedNameController.text =
        (m['signaturePrintedName'] ?? '').toString();
    try {
      _issuedDate = DateTime.parse(cert.issuedDate);
    } catch (_) {
      _issuedDate = DateTime.now();
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controlNumberController.dispose();
    _applicantNameController.dispose();
    _applicantAddressController.dispose();
    _natureOfBusinessController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _contactNumberController.dispose();
    _inspectorNameController.dispose();
    _motorizedBarangayController.dispose();
    _barangayController.dispose();
    _conformedSignatureController.dispose();
    _fishingDeviceUseController.dispose();
    _registeredNumberController.dispose();
    _motorBancaNameController.dispose();
    _lengthController.dispose();
    _breadthController.dispose();
    _depthController.dispose();
    _grossTonnageController.dispose();
    _netTonnageController.dispose();
    _greenStripeController.dispose();
    _colorCodingController.dispose();
    _dateOfConstructionController.dispose();
    _carpenterNameController.dispose();
    _placeBuiltController.dispose();
    _engineTypeNoController.dispose();
    _approvalSignatureController.dispose();
    _releasedByController.dispose();
    _receivedDateTimeController.dispose();
    _releasedDateController.dispose();
    _builderNameController.dispose();
    _builderAddressController.dispose();
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _vesselNameController.dispose();
    _vesselTypeClassController.dispose();
    _materialsUsedController.dispose();
    _lengthOverallController.dispose();
    _breadthMoldedController.dispose();
    _depthMoldedController.dispose();
    _numberOfDecksController.dispose();
    _numberOfMastsController.dispose();
    _grossTonnageBuilderController.dispose();
    _netTonnageBuilderController.dispose();
    _dateFinishedLaunchedController.dispose();
    _lifeVestsController.dispose();
    _engineTypeController.dispose();
    _horsepowerModelController.dispose();
    _serialNumberController.dispose();
    _dateManufacturedController.dispose();
    _numberOfCylindersController.dispose();
    _boreStrokeController.dispose();
    _rpmController.dispose();
    _numberOfEnginesOnlyController.dispose();
    _numberOfPropellersController.dispose();
    _datePlaceIssuedController.dispose();
    _builderSignatureController.dispose();
    _preparedByController.dispose();
    _builderBarangayBuiltController.dispose();
    _ownerSitioPurokController.dispose();
    _ownerBarangayController.dispose();
    _oathDayController.dispose();
    _oathMonthController.dispose();
    _oathYearController.dispose();
    _oathDateController.dispose();
    _residenceCertBlgController.dispose();
    _residenceCertIssuedController.dispose();
    _residenceCertPlaceController.dispose();
    _residenceCertDetailsController.dispose();
    _areaHasController.dispose();
    _currentZoningController.dispose();
    _locationController.dispose();
    _kindOfLicenseController.dispose();
    _signaturePrintedNameController.dispose();
    super.dispose();
  }

  CertificateModel _buildModel() {
    Map<String, dynamic>? data;
    if (_isMotorized) {
      data = <String, dynamic>{
        'barangay': _motorizedBarangayController.text.trim(),
        'conformedSignature': _conformedSignatureController.text.trim(),
        'fishingDeviceUse': _fishingDeviceUseController.text.trim(),
        'registeredNumber': _registeredNumberController.text.trim(),
        'motorBancaName': _motorBancaNameController.text.trim(),
        'length': _lengthController.text.trim(),
        'breadth': _breadthController.text.trim(),
        'depth': _depthController.text.trim(),
        'grossTonnage': _grossTonnageController.text.trim(),
        'netTonnage': _netTonnageController.text.trim(),
        'greenStripe': _greenStripeController.text.trim(),
        'colorCoding': _colorCodingController.text.trim(),
        'dateOfConstruction': _dateOfConstructionController.text.trim(),
        'carpenterName': _carpenterNameController.text.trim(),
        'placeBuilt': _placeBuiltController.text.trim(),
        'engineTypeNo': _engineTypeNoController.text.trim(),
        'approvalSignature': _approvalSignatureController.text.trim(),
        'releasedBy': _releasedByController.text.trim(),
        'receivedDateTime': _receivedDateTimeController.text.trim(),
        'releasedDate': _releasedDateController.text.trim(),
      };
    } else if (_isBuilders) {
      data = <String, dynamic>{
        'builderName': _builderNameController.text.trim(),
        'builderAddress': _builderAddressController.text.trim(),
        'builderBarangayBuilt': _builderBarangayBuiltController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'ownerSitioPurok': _ownerSitioPurokController.text.trim(),
        'ownerBarangay': _ownerBarangayController.text.trim(),
        'vesselName': _vesselNameController.text.trim(),
        'vesselTypeClass': _vesselTypeClassController.text.trim(),
        'materialsUsed': _materialsUsedController.text.trim(),
        'lengthOverall': _lengthOverallController.text.trim(),
        'breadthMolded': _breadthMoldedController.text.trim(),
        'depthMolded': _depthMoldedController.text.trim(),
        'numberOfDecks': _numberOfDecksController.text.trim(),
        'numberOfMasts': _numberOfMastsController.text.trim(),
        'grossTonnageBuilder': _grossTonnageBuilderController.text.trim(),
        'netTonnageBuilder': _netTonnageBuilderController.text.trim(),
        'dateFinishedLaunched': _dateFinishedLaunchedController.text.trim(),
        'lifeVests': _lifeVestsController.text.trim(),
        'engineType': _engineTypeController.text.trim(),
        'horsepowerModel': _horsepowerModelController.text.trim(),
        'serialNumber': _serialNumberController.text.trim(),
        'dateManufactured': _dateManufacturedController.text.trim(),
        'numberOfCylinders': _numberOfCylindersController.text.trim(),
        'boreStroke': _boreStrokeController.text.trim(),
        'rpm': _rpmController.text.trim(),
        'numberOfEngines': _numberOfEnginesOnlyController.text.trim(),
        'numberOfPropellers': _numberOfPropellersController.text.trim(),
        'datePlaceIssued': _datePlaceIssuedController.text.trim(),
        'builderSignature': _builderSignatureController.text.trim(),
        'preparedBy': _preparedByController.text.trim(),
        'oathDate': _oathDateController.text.trim(),
        'residenceCertBlg': _residenceCertBlgController.text.trim(),
        'residenceCertIssued': _residenceCertIssuedController.text.trim(),
        'residenceCertPlace': _residenceCertPlaceController.text.trim(),
      };
    } else if (_isExclusiveFish) {
      data = <String, dynamic>{
        'areaHas': _areaHasController.text.trim(),
        'currentZoning': _currentZoningController.text.trim(),
        'location': _locationController.text.trim(),
        'kindOfLicense': _kindOfLicenseController.text.trim(),
        'signaturePrintedName': _signaturePrintedNameController.text.trim(),
      };
    }

    return CertificateModel(
      id: _editingId,
      controlNumber: _controlNumberController.text.trim(),
      certificateType: widget.certificateType,
      applicantName: _applicantNameController.text.trim(),
      applicantAddress: _applicantAddressController.text.trim(),
      licenseType: _licenseType,
      natureOfBusiness: _natureOfBusinessController.text.trim(),
      businessName: _businessNameController.text.trim(),
      businessAddress: _businessAddressController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      issuedDate: DateFormat('MMMM d, yyyy').format(_issuedDate),
      inspectorName: _inspectorNameController.text.trim(),
      createdAt: widget.certificate?.createdAt ??
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      // Edits (including renewals) must re-sync so admin receives the latest data.
      syncStatus: _editingId != null
          ? CertificateModel.syncStatusPending
          : (widget.certificate?.syncStatus ??
              CertificateModel.syncStatusPending),
      motorizedData: data,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateMotorizedFields()) return;
    if (!_validateBuildersFields()) return;
    if (!_validateExclusiveFishFields()) return;

    setState(() => _isSaving = true);

    try {
      final model = _buildModel();
      if (_editingId != null) {
        await _db.updateCertificate(model);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Certificate updated. Use Sync on Home to send changes to admin.',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _db.insertCertificate(model);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Certificate saved. Use Send to admin to receive the official control number.',
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateMotorizedFields()) return;
    if (!_validateBuildersFields()) return;
    if (!_validateExclusiveFishFields()) return;

    setState(() => _isSaving = true);
    try {
      final model = _buildModel();
      final path = await PdfService.generatePdf(model);
      if (mounted) {
        _showFileSavedDialog('PDF', path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generateExcel() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateMotorizedFields()) return;
    if (!_validateBuildersFields()) return;

    setState(() => _isSaving = true);
    try {
      final model = _buildModel();
      final path = await ExcelService.generateExcel(model);
      if (mounted) {
        _showFileSavedDialog('Excel', path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generateWord() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateMotorizedFields()) return;
    if (!_validateBuildersFields()) return;

    setState(() => _isSaving = true);
    try {
      final model = _buildModel();
      final path = await WordService.generateWord(model);
      if (mounted) {
        _showFileSavedDialog('Word', path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showFileSavedDialog(String type, String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Saved'),
        content: const Text(
          'File saved successfully to Documents/Certificate_Inspection',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FileStorageService.openCertificateFolder();
              } catch (_) {
                // If folder can't be opened, do nothing (file is still saved).
              }
            },
            child: const Text('Open Folder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _issuedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Certificate Form')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editingId != null
              ? 'Edit ${_certificateTypeTitles[widget.certificateType] ?? 'Certificate'}'
              : 'New ${_certificateTypeTitles[widget.certificateType] ?? 'Certificate'}',
        ),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Certificate details',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                    const SizedBox(height: 6),
                    Text(
                      'Type: ${_certificateTypeTitles[widget.certificateType] ?? 'Unspecified'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _licenseType == 'Renew' && _isNewCertificate
                          ? 'Control number (same as first registration)'
                          : 'Control number',
                      _controlNumberController,
                      readOnly: _controlNumberReadOnly,
                      validator: _controlNumberValidator,
                    ),
                    if (_licenseType == 'New' && _isNewCertificate) ...[
                      const SizedBox(height: 6),
                      Text(
                        'The official number (e.g. MC-042) is created on the server when you tap Send to admin. It stays unique even if many inspectors sync at once.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                    if (_licenseType == 'Renew' && _isNewCertificate) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Enter the control number from the first registration. It must already exist on the server.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField('Applicant Name', _applicantNameController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    _buildTextField(
                        'Applicant Address', _applicantAddressController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    if (widget.licenseTypeLock == null) ...[
                      Text('License Type', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'New',
                            label: Text('New'),
                            icon: Icon(Icons.fiber_new_rounded),
                          ),
                          ButtonSegment(
                            value: 'Renew',
                            label: Text('Renew'),
                            icon: Icon(Icons.refresh_rounded),
                          ),
                        ],
                        selected: {_licenseType},
                        onSelectionChanged: _onLicenseTypeSelectionChanged,
                      ),
                    ] else ...[
                      Text('License Type', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: Icon(
                            widget.licenseTypeLock == 'Renew'
                                ? Icons.refresh_rounded
                                : Icons.fiber_new_rounded,
                            size: 18,
                          ),
                          label: Text(
                            widget.licenseTypeLock == 'Renew'
                                ? 'Renewal'
                                : 'New registration',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField(
                        'Nature of Business', _natureOfBusinessController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    _buildTextField('Business Name', _businessNameController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    _buildTextField(
                        'Business Address', _businessAddressController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    _buildTextField('Contact Number', _contactNumberController,
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    Text('Issued Date', style: _labelStyle(context)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: cs.primary),
                            const SizedBox(width: 12),
                            Text(
                                DateFormat('MMMM d, yyyy').format(_issuedDate)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Inspector Name', _inspectorNameController,
                        validator: _requiredValidator),
                  ],
                ),
              ),
            ),
            if (_isMotorized) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motorized Certification Details',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text('Applicant Information',
                          style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField('Barangay', _motorizedBarangayController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Conformed Signature (Printed Name)',
                        _conformedSignatureController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Fishing Device Use',
                        _fishingDeviceUseController,
                      ),
                      const SizedBox(height: 10),
                      if (_licenseType == 'Renew') ...[
                        _buildTextField(
                          'Registered Number (Renewal)',
                          _registeredNumberController,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text('Vessel Specifications',
                          style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Name of Motor Banca',
                        _motorBancaNameController,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField('Length', _lengthController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                _buildTextField('Breadth', _breadthController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField('Depth', _depthController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Gross Tonnage',
                              _grossTonnageController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Net Tonnage', _netTonnageController),
                      const SizedBox(height: 10),
                      _buildTextField('Green Stripe', _greenStripeController),
                      const SizedBox(height: 10),
                      _buildTextField('Color Coding', _colorCodingController),
                      const SizedBox(height: 10),
                      Text(
                        'Construction & Engine Details',
                        style: _labelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Date of Construction',
                        _dateOfConstructionController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Name of Carpenter',
                        _carpenterNameController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Place of Built', _placeBuiltController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Engine Type & No.',
                        _engineTypeNoController,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Administrative & Release Tracking',
                        style: _labelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Approval Signature',
                        _approvalSignatureController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Released By', _releasedByController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Date and Time Received',
                        _receivedDateTimeController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Date Released', _releasedDateController),
                    ],
                  ),
                ),
              ),
            ],
            if (_isBuilders) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '*SERTIPIKO NG PAGKAGAWA',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text('Pangalan ng gumawa', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Pangalan ng gumawa',
                        _builderNameController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Tirahan ng gumawa',
                        _builderAddressController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Barangay kung saan ginawa o binuo ang bangka',
                        _builderBarangayBuiltController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Pangalan ng may-ari',
                        _ownerNameController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Sitio / Purok ng may-ari',
                        _ownerSitioPurokController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Barangay ng may-ari sa lungsod ng Puerto Princesa',
                        _ownerBarangayController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '*PAGKAKAKILANLAN NG BANGKANG MAY MOTOR',
                        style: _labelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Pangalan ng bangka',
                        _vesselNameController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Uri/Klase',
                        _vesselTypeClassController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Mga materyales na ginamit',
                        _materialsUsedController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Kabuuang haba (m)',
                              _lengthOverallController,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Luwang – Breadth molded (m)',
                              _breadthMoldedController,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Sukat ng lalim – Depth molded (m)',
                        _depthMoldedController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Bilang ng deck / kamarote',
                              _numberOfDecksController,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Bilang ng mast / palo',
                              _numberOfMastsController,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'G.T. (Gross)',
                              _grossTonnageBuilderController,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'N.T. (Net)',
                              _netTonnageBuilderController,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Kailan natapos o ipinalaot',
                        _dateFinishedLaunchedController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Life vest / jacket (bilang)',
                        _lifeVestsController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Pagkakakilanlan ng makina',
                        style: _labelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Uri ng makina',
                        _engineTypeController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Lakas at modelo (HP & model)',
                        _horsepowerModelController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Serial number',
                        _serialNumberController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Petsang ginawa',
                        _dateManufacturedController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Ilang silindro',
                        _numberOfCylindersController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Bore at stroke',
                        _boreStrokeController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'R.P.M.',
                        _rpmController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Ilang makina',
                              _numberOfEnginesOnlyController,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Ilang propeller / screw',
                              _numberOfPropellersController,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Petsa at lugar na inisyu',
                        _datePlaceIssuedController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 14),
                      Text('Lagda at admin', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Pangalan at lagda ng gumawa',
                        _builderSignatureController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Prepared by',
                        _preparedByController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      Text('Sumpa (oath)', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Araw (ika-…)',
                              _oathDayController,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Buwan',
                              _oathMonthController,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Taon',
                        _oathYearController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Buong petsa / tala (optional)',
                        _oathDateController,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Katibayan ng paninirahan',
                        style: _labelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'BLG. (numero)',
                        _residenceCertBlgController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Na iginawad (petsa / pangalan, gaya ng template)',
                        _residenceCertIssuedController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Lugar',
                        _residenceCertPlaceController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Karagdagang detalye (optional)',
                        _residenceCertDetailsController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_isExclusiveFish) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('*Impormasyon ng Proyekto at Aplikante',
                          style: _labelStyle(context)
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('MR. / MS. (Pangalan ng aplikante)',
                          style: _labelStyle(context)),
                      _buildTextField('', _applicantNameController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('Address (Tirahan)', style: _labelStyle(context)),
                      _buildTextField('', _applicantAddressController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('Area of HAS. (Sukat ng lugar sa ektarya)',
                          style: _labelStyle(context)),
                      _buildTextField('', _areaHasController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('NEW o RENEW (Uri ng aplikasyon)',
                          style: _labelStyle(context)),
                      _buildTextField(
                          '', TextEditingController(text: _licenseType),
                          readOnly: true),
                      const SizedBox(height: 10),
                      Text('KIND OF LICENSE APPLIED FOR',
                          style: _labelStyle(context)),
                      _buildTextField('', _kindOfLicenseController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('NATURE OF BUSINESS', style: _labelStyle(context)),
                      _buildTextField('', _natureOfBusinessController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('CURRENT ZONING', style: _labelStyle(context)),
                      _buildTextField('', _currentZoningController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('LOCATION (Lokasyon)', style: _labelStyle(context)),
                      _buildTextField('', _locationController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('NAME OF BUSINESS (Pangalan ng Negosyo)',
                          style: _labelStyle(context)),
                      _buildTextField('', _businessNameController,
                          validator: _requiredValidator),
                      const SizedBox(height: 16),
                      Text('*Pagpapatunay at Kasunduan',
                          style: _labelStyle(context)
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          'Issued this ____ day of ________ 2026 (Petsa ng pag-isyu)',
                          style: _labelStyle(context)),
                      _buildTextField(
                          '',
                          TextEditingController(
                              text: DateFormat('MMMM d, yyyy')
                                  .format(_issuedDate)),
                          readOnly: true),
                      const SizedBox(height: 10),
                      Text(
                          'Signature over Printed Name (Lagda sa ibabaw ng pangalan ng May-ari/Kinatawan)',
                          style: _labelStyle(context)),
                      _buildTextField('', _signaturePrintedNameController,
                          validator: _requiredValidator),
                      const SizedBox(height: 10),
                      Text('Contact No.', style: _labelStyle(context)),
                      _buildTextField('', _contactNumberController),
                      const SizedBox(height: 10),
                      Text('Inspected by', style: _labelStyle(context)),
                      _buildTextField('', _inspectorNameController),
                      const SizedBox(height: 10),
                      Text('Approved by', style: _labelStyle(context)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Approver',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                    const SizedBox(height: 10),
                    Text('Approved By (auto-filled)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 8),
                    const Text(
                      'Cardelar Stevie Angel M. Madriñan',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'CG Assistant Department Head II (Assistant City ENRO)',
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: const Text('PDF'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _generateExcel,
                          icon: const Icon(Icons.table_chart_rounded),
                          label: const Text('Excel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _generateWord,
                          icon: const Icon(Icons.description_rounded),
                          label: const Text('Word'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle(context)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade200 : null,
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _controlNumberValidator(String? value) {
    if (_editingId != null) return null;
    if (_licenseType == 'Renew') {
      if (value == null || value.trim().isEmpty) {
        return 'Enter the control number from first registration';
      }
      if (value.trim().startsWith(CertificateModel.localControlPrefix)) {
        return 'Enter the registered control number';
      }
    }
    return null;
  }

  bool _validateMotorizedFields() {
    if (!_isMotorized) return true;
    final requiredMap = <String, String>{
      'Barangay': _motorizedBarangayController.text,
      'Conformed Signature': _conformedSignatureController.text,
      'Fishing Device Use': _fishingDeviceUseController.text,
      'Name of Motor Banca': _motorBancaNameController.text,
      'Length': _lengthController.text,
      'Breadth': _breadthController.text,
      'Depth': _depthController.text,
      'Gross Tonnage': _grossTonnageController.text,
      'Net Tonnage': _netTonnageController.text,
      'Green Stripe': _greenStripeController.text,
      'Color Coding': _colorCodingController.text,
      'Date of Construction': _dateOfConstructionController.text,
      'Name of Carpenter': _carpenterNameController.text,
      'Place of Built': _placeBuiltController.text,
      'Engine Type & No.': _engineTypeNoController.text,
      'Approval Signature': _approvalSignatureController.text,
      'Released By': _releasedByController.text,
      'Date and Time Received': _receivedDateTimeController.text,
      'Date Released': _releasedDateController.text,
    };
    if (_licenseType == 'Renew') {
      requiredMap['Registered Number'] = _registeredNumberController.text;
    }
    for (final entry in requiredMap.entries) {
      if (entry.value.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${entry.key} is required for motorized certification.')),
        );
        return false;
      }
    }
    return true;
  }

  bool _validateBuildersFields() {
    if (!_isBuilders) return true;
    final requiredMap = <String, String>{
      'Pangalan ng gumawa': _builderNameController.text,
      'Tirahan ng gumawa': _builderAddressController.text,
      'Barangay kung saan ginawa o binuo ang bangka':
          _builderBarangayBuiltController.text,
      'Pangalan ng may-ari': _ownerNameController.text,
      'Sitio / Purok ng may-ari': _ownerSitioPurokController.text,
      'Barangay ng may-ari sa lungsod ng Puerto Princesa':
          _ownerBarangayController.text,
      'Pangalan ng Bangkang may motor': _vesselNameController.text,
      'Uri/Klase ng Bangkang may motor': _vesselTypeClassController.text,
      'Mga Materyales na ginamit': _materialsUsedController.text,
      'Kabuuang Haba (Length overall)': _lengthOverallController.text,
      'Sukat ng bawat kabilugang gilid o Luwang (Breath-Molded)':
          _breadthMoldedController.text,
      'Sukat ng Lalim (Depth- Molded)': _depthMoldedController.text,
      'Bilang ng Kamarote (No. of Deck)': _numberOfDecksController.text,
      'Bilang ng Palo (No. of Mast)': _numberOfMastsController.text,
      'Kabuuang bigat sa tonelada (Gross Tonnage)':
          _grossTonnageBuilderController.text,
      'Netong bigat sa tonelada (Net Tonnage)':
          _netTonnageBuilderController.text,
      'Kailan natapos o ipinalaot (Date Finished/ Launched)':
          _dateFinishedLaunchedController.text,
      'Bilang ng gamit pangkaligtasan (Life Vest/ Life Jacket)':
          _lifeVestsController.text,
      'Uri ng Makina': _engineTypeController.text,
      'Lakas at Modelo (HP & MODEL)': _horsepowerModelController.text,
      'Serial Number ng makina': _serialNumberController.text,
      'Petsang Ginawa ang makina': _dateManufacturedController.text,
      'Ilang Silindro (Cylinder)': _numberOfCylindersController.text,
      'Bore at Stroke': _boreStrokeController.text,
      'R.P.M': _rpmController.text,
      'Ilang Makina': _numberOfEnginesOnlyController.text,
      'Ilang Turnilyo (Screw)': _numberOfPropellersController.text,
      'Petsa at lugar kung kailan inisyu ang dokumento':
          _datePlaceIssuedController.text,
      'Pangalan at Lagda ng Gumawa': _builderSignatureController.text,
      'Pangalan ng naghanda (Prepared By)': _preparedByController.text,
      'Petsa ng panunumpa sa harap ng opisyal': _oathDateController.text,
      'Numero ng katibayan ng paninirahan (BLG.)':
          _residenceCertBlgController.text,
      'Petsa at lugar kung kailan iginawad ang katibayan ng paninirahan':
          '${_residenceCertIssuedController.text} ${_residenceCertPlaceController.text}',
    };
    for (final entry in requiredMap.entries) {
      if (entry.value.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${entry.key} is required for builders form.')),
        );
        return false;
      }
    }
    return true;
  }

  bool _validateExclusiveFishFields() {
    if (!_isExclusiveFish) return true;
    final requiredMap = <String, String>{
      'Area of HAS': _areaHasController.text,
      'KIND OF LICENSE APPLIED FOR': _kindOfLicenseController.text,
      'CURRENT ZONING': _currentZoningController.text,
      'LOCATION': _locationController.text,
      'Signature over Printed Name': _signaturePrintedNameController.text,
    };
    for (final entry in requiredMap.entries) {
      if (entry.value.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${entry.key} is required for Exclusive Fish Privilege form.')),
        );
        return false;
      }
    }
    return true;
  }
}
