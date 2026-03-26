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

  const FormScreen({
    super.key,
    this.certificate,
    this.certificateType = 'marine_certification',
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
  late TextEditingController _barangayController;
  late TextEditingController _conformedSignatureController;
  late TextEditingController _fishingDeviceUseController;
  late TextEditingController _registeredNumberController;
  late TextEditingController _motorBancaNameController;
  late TextEditingController _lengthController;
  late TextEditingController _breadthController;
  late TextEditingController _depthController;
  late TextEditingController _grossTonnageController;
  late TextEditingController _netTonnageController;
  late TextEditingController _greenStripeController;
  late TextEditingController _colorCodingController;
  late TextEditingController _dateOfConstructionController;
  late TextEditingController _carpenterNameController;
  late TextEditingController _placeBuiltController;
  late TextEditingController _engineTypeNoController;
  late TextEditingController _approvalSignatureController;
  late TextEditingController _releasedByController;
  late TextEditingController _receivedDateTimeController;
  late TextEditingController _releasedDateController;
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
  late TextEditingController _numberOfEnginesScrewsController;
  late TextEditingController _datePlaceIssuedController;
  late TextEditingController _builderSignatureController;
  late TextEditingController _preparedByController;
  late TextEditingController _oathDateController;
  late TextEditingController _residenceCertDetailsController;

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

  bool get _isMotorized =>
      widget.certificateType == 'motorized_certification';
  bool get _isBuilders => widget.certificateType == 'builders_form';

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
    _barangayController = TextEditingController();
    _conformedSignatureController = TextEditingController();
    _fishingDeviceUseController = TextEditingController();
    _registeredNumberController = TextEditingController();
    _motorBancaNameController = TextEditingController();
    _lengthController = TextEditingController();
    _breadthController = TextEditingController();
    _depthController = TextEditingController();
    _grossTonnageController = TextEditingController();
    _netTonnageController = TextEditingController();
    _greenStripeController = TextEditingController();
    _colorCodingController = TextEditingController();
    _dateOfConstructionController = TextEditingController();
    _carpenterNameController = TextEditingController();
    _placeBuiltController = TextEditingController();
    _engineTypeNoController = TextEditingController();
    _approvalSignatureController = TextEditingController();
    _releasedByController = TextEditingController();
    _receivedDateTimeController = TextEditingController();
    _releasedDateController = TextEditingController();
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
    _numberOfEnginesScrewsController = TextEditingController();
    _datePlaceIssuedController = TextEditingController();
    _builderSignatureController = TextEditingController();
    _preparedByController = TextEditingController();
    _oathDateController = TextEditingController();
    _residenceCertDetailsController = TextEditingController();

    if (widget.certificate != null) {
      _loadCertificate(widget.certificate!);
    } else {
      _loadNextControlNumber();
    }
  }

  Future<void> _loadNextControlNumber() async {
    final nextNumber = await _db.getNextControlNumber(widget.certificateType);
    setState(() {
      _controlNumberController.text = nextNumber;
      _isLoading = false;
    });
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
    _barangayController.text = (m['barangay'] ?? '').toString();
    _conformedSignatureController.text =
        (m['conformedSignature'] ?? '').toString();
    _fishingDeviceUseController.text =
        (m['fishingDeviceUse'] ?? '').toString();
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
    _numberOfEnginesScrewsController.text =
        (m['numberOfEnginesScrews'] ?? '').toString();
    _datePlaceIssuedController.text = (m['datePlaceIssued'] ?? '').toString();
    _builderSignatureController.text = (m['builderSignature'] ?? '').toString();
    _preparedByController.text = (m['preparedBy'] ?? '').toString();
    _oathDateController.text = (m['oathDate'] ?? '').toString();
    _residenceCertDetailsController.text =
        (m['residenceCertDetails'] ?? '').toString();
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
    _numberOfEnginesScrewsController.dispose();
    _datePlaceIssuedController.dispose();
    _builderSignatureController.dispose();
    _preparedByController.dispose();
    _oathDateController.dispose();
    _residenceCertDetailsController.dispose();
    super.dispose();
  }

  CertificateModel _buildModel() {
    final motorizedData = _isMotorized
        ? <String, dynamic>{
            'barangay': _barangayController.text.trim(),
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
          }
        : _isBuilders
            ? <String, dynamic>{
                'builderName': _builderNameController.text.trim(),
                'builderAddress': _builderAddressController.text.trim(),
                'ownerName': _ownerNameController.text.trim(),
                'ownerAddress': _ownerAddressController.text.trim(),
                'vesselName': _vesselNameController.text.trim(),
                'vesselTypeClass': _vesselTypeClassController.text.trim(),
                'materialsUsed': _materialsUsedController.text.trim(),
                'lengthOverall': _lengthOverallController.text.trim(),
                'breadthMolded': _breadthMoldedController.text.trim(),
                'depthMolded': _depthMoldedController.text.trim(),
                'numberOfDecks': _numberOfDecksController.text.trim(),
                'numberOfMasts': _numberOfMastsController.text.trim(),
                'grossTonnageBuilder':
                    _grossTonnageBuilderController.text.trim(),
                'netTonnageBuilder': _netTonnageBuilderController.text.trim(),
                'dateFinishedLaunched':
                    _dateFinishedLaunchedController.text.trim(),
                'lifeVests': _lifeVestsController.text.trim(),
                'engineType': _engineTypeController.text.trim(),
                'horsepowerModel': _horsepowerModelController.text.trim(),
                'serialNumber': _serialNumberController.text.trim(),
                'dateManufactured': _dateManufacturedController.text.trim(),
                'numberOfCylinders': _numberOfCylindersController.text.trim(),
                'boreStroke': _boreStrokeController.text.trim(),
                'rpm': _rpmController.text.trim(),
                'numberOfEnginesScrews':
                    _numberOfEnginesScrewsController.text.trim(),
                'datePlaceIssued': _datePlaceIssuedController.text.trim(),
                'builderSignature': _builderSignatureController.text.trim(),
                'preparedBy': _preparedByController.text.trim(),
                'oathDate': _oathDateController.text.trim(),
                'residenceCertDetails':
                    _residenceCertDetailsController.text.trim(),
              }
        : null;

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
      syncStatus:
          widget.certificate?.syncStatus ?? CertificateModel.syncStatusPending,
      motorizedData: motorizedData,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateMotorizedFields()) return;
    if (!_validateBuildersFields()) return;

    setState(() => _isSaving = true);

    try {
      final model = _buildModel();
      if (_editingId != null) {
        await _db.updateCertificate(model);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate updated successfully')),
          );
        }
      } else {
        await _db.insertCertificate(model);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate saved successfully')),
          );
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
                    _buildTextField('Control Number', _controlNumberController,
                        readOnly: true),
                    const SizedBox(height: 12),
                    _buildTextField('Applicant Name', _applicantNameController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
                    _buildTextField(
                        'Applicant Address', _applicantAddressController,
                        validator: _requiredValidator),
                    const SizedBox(height: 12),
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
                      onSelectionChanged: (s) {
                        setState(() => _licenseType = s.first);
                      },
                    ),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text('Applicant Information', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField('Barangay', _barangayController),
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
                      Text('Vessel Specifications', style: _labelStyle(context)),
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
                        'Builders Form Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text('Builder & Owner Information', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField("Builder's Name", _builderNameController),
                      const SizedBox(height: 10),
                      _buildTextField("Builder's Address", _builderAddressController),
                      const SizedBox(height: 10),
                      _buildTextField("Owner's Name", _ownerNameController),
                      const SizedBox(height: 10),
                      _buildTextField("Owner's Address", _ownerAddressController),
                      const SizedBox(height: 10),
                      Text('Vessel Identification', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField('Vessel Name', _vesselNameController),
                      const SizedBox(height: 10),
                      _buildTextField('Vessel Type/Class', _vesselTypeClassController),
                      const SizedBox(height: 10),
                      _buildTextField('Materials Used', _materialsUsedController),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Length Overall (m)',
                              _lengthOverallController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Breadth-Molded (m)',
                              _breadthMoldedController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Depth-Molded (m)', _depthMoldedController),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Number of Decks',
                              _numberOfDecksController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Number of Masts',
                              _numberOfMastsController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Gross Tonnage (G.T.)',
                              _grossTonnageBuilderController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              'Net Tonnage (N.T.)',
                              _netTonnageBuilderController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Date Finished/Launched',
                        _dateFinishedLaunchedController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Life Vests/Jackets', _lifeVestsController),
                      const SizedBox(height: 10),
                      Text('Engine Specifications', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField('Engine Type', _engineTypeController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Horsepower & Model',
                        _horsepowerModelController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Serial Number', _serialNumberController),
                      const SizedBox(height: 10),
                      _buildTextField('Date Manufactured', _dateManufacturedController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Number of Cylinders',
                        _numberOfCylindersController,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Bore and Stroke', _boreStrokeController),
                      const SizedBox(height: 10),
                      _buildTextField('R.P.M.', _rpmController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Number of Engines and Screws/Propellers',
                        _numberOfEnginesScrewsController,
                      ),
                      const SizedBox(height: 10),
                      Text('Legal & Notary Details', style: _labelStyle(context)),
                      const SizedBox(height: 8),
                      _buildTextField('Date and Place Issued', _datePlaceIssuedController),
                      const SizedBox(height: 10),
                      _buildTextField("Builder's Signature", _builderSignatureController),
                      const SizedBox(height: 10),
                      _buildTextField('Prepared By', _preparedByController),
                      const SizedBox(height: 10),
                      _buildTextField('Oath Date', _oathDateController),
                      const SizedBox(height: 10),
                      _buildTextField(
                        'Residence Certificate Details',
                        _residenceCertDetailsController,
                      ),
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

  bool _validateMotorizedFields() {
    if (!_isMotorized) return true;
    final requiredMap = <String, String>{
      'Barangay': _barangayController.text,
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
          SnackBar(content: Text('${entry.key} is required for motorized certification.')),
        );
        return false;
      }
    }
    return true;
  }

  bool _validateBuildersFields() {
    if (!_isBuilders) return true;
    final requiredMap = <String, String>{
      "Builder's Name": _builderNameController.text,
      "Builder's Address": _builderAddressController.text,
      "Owner's Name": _ownerNameController.text,
      "Owner's Address": _ownerAddressController.text,
      'Vessel Name': _vesselNameController.text,
      'Vessel Type/Class': _vesselTypeClassController.text,
      'Materials Used': _materialsUsedController.text,
      'Length Overall': _lengthOverallController.text,
      'Breadth-Molded': _breadthMoldedController.text,
      'Depth-Molded': _depthMoldedController.text,
      'Number of Decks': _numberOfDecksController.text,
      'Number of Masts': _numberOfMastsController.text,
      'Gross Tonnage': _grossTonnageBuilderController.text,
      'Net Tonnage': _netTonnageBuilderController.text,
      'Date Finished/Launched': _dateFinishedLaunchedController.text,
      'Life Vests/Jackets': _lifeVestsController.text,
      'Engine Type': _engineTypeController.text,
      'Horsepower & Model': _horsepowerModelController.text,
      'Serial Number': _serialNumberController.text,
      'Date Manufactured': _dateManufacturedController.text,
      'Number of Cylinders': _numberOfCylindersController.text,
      'Bore and Stroke': _boreStrokeController.text,
      'R.P.M.': _rpmController.text,
      'Number of Engines and Screws/Propellers':
          _numberOfEnginesScrewsController.text,
      'Date and Place Issued': _datePlaceIssuedController.text,
      "Builder's Signature": _builderSignatureController.text,
      'Prepared By': _preparedByController.text,
      'Oath Date': _oathDateController.text,
      'Residence Certificate Details': _residenceCertDetailsController.text,
    };
    for (final entry in requiredMap.entries) {
      if (entry.value.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${entry.key} is required for builders form.')),
        );
        return false;
      }
    }
    return true;
  }
}
