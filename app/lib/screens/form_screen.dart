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

  const FormScreen({super.key, this.certificate});

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

  String _licenseType = 'New';
  DateTime _issuedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _controlNumberController = TextEditingController();
    _applicantNameController = TextEditingController();
    _applicantAddressController = TextEditingController();
    _natureOfBusinessController =
        TextEditingController(text: 'BUY AND SELL OF MARINE PRODUCTS');
    _businessNameController = TextEditingController();
    _businessAddressController = TextEditingController();
    _contactNumberController = TextEditingController();
    _inspectorNameController = TextEditingController();

    if (widget.certificate != null) {
      _loadCertificate(widget.certificate!);
    } else {
      _loadNextControlNumber();
    }
  }

  Future<void> _loadNextControlNumber() async {
    final nextNumber = await _db.getNextControlNumber();
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
    super.dispose();
  }

  CertificateModel _buildModel() {
    return CertificateModel(
      id: _editingId,
      controlNumber: _controlNumberController.text.trim(),
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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

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
        title:
            Text(_editingId != null ? 'Edit Certificate' : 'New Certificate'),
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
}
