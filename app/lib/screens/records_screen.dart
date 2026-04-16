import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/certificate_model.dart';
import 'form_screen.dart';

/// Records screen - list, search, filter, view, delete certificates
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

/// Labels for [CertificateModel.certificateType] (must match app form types).
const Map<String, String> _certificateTypeLabels = {
  'builders_form': 'Builders Form',
  'motorized_certification': 'Motorized Certification',
  'marine_certification': 'Marine Certification',
  'exclusive_fish_privilege': 'Exclusive Fish Privilege',
};

String _labelForCertificateType(String key) =>
    _certificateTypeLabels[key] ?? key;

class _RecordsScreenState extends State<RecordsScreen> {
  final _db = DbHelper();
  final _searchController = TextEditingController();

  List<CertificateModel> _certificates = [];
  List<CertificateModel> _filteredCertificates = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _filterDate;
  /// `null` = all certificate types.
  String? _filterCertificateType;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    final list = await _db.getAllCertificates();
    if (!mounted) return;
    setState(() {
      _certificates = list;
      _isLoading = false;
    });
    _applyFilters();
  }

  /// Applies certificate type, search text, and issued date together (same source list).
  void _applyFilters() {
    var result = List<CertificateModel>.from(_certificates);

    if (_filterCertificateType != null &&
        _filterCertificateType!.isNotEmpty) {
      result = result
          .where((c) => c.certificateType == _filterCertificateType)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) {
        return c.controlNumber.toLowerCase().contains(q) ||
            c.applicantName.toLowerCase().contains(q) ||
            c.businessName.toLowerCase().contains(q);
      }).toList();
    }

    if (_filterDate != null) {
      final dateStr = DateFormat('MMMM d, yyyy').format(_filterDate!);
      result = result.where((c) => c.issuedDate == dateStr).toList();
    }

    setState(() => _filteredCertificates = result);
  }

  void _filterByDate(DateTime? date) {
    setState(() => _filterDate = date);
    _applyFilters();
  }

  Future<void> _deleteCertificate(CertificateModel cert) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text(
          'Are you sure you want to delete ${cert.controlNumber} - ${cert.applicantName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && cert.id != null) {
      await _db.deleteCertificate(cert.id!);
      _loadCertificates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate deleted')),
        );
      }
    }
  }

  void _viewDetails(CertificateModel cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                cert.controlNumber,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _DetailRow(
                      'Certificate type',
                      _labelForCertificateType(cert.certificateType),
                    ),
                    _DetailRow('Applicant', cert.applicantName),
                    _DetailRow('Address', cert.applicantAddress),
                    _DetailRow('License (New / Renew)', cert.licenseType),
                    _DetailRow('Business', cert.businessName),
                    _DetailRow('Business Address', cert.businessAddress),
                    _DetailRow('Nature', cert.natureOfBusiness),
                    _DetailRow('Contact', cert.contactNumber),
                    _DetailRow('Issued', cert.issuedDate),
                    _DetailRow('Inspector', cert.inspectorName),
                    _DetailRow(
                      'Sync status',
                      cert.syncStatus == CertificateModel.syncStatusSynced
                          ? 'Synced to admin'
                          : 'Pending upload',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FormScreen(
                              certificate: cert,
                              certificateType: cert.certificateType.isNotEmpty
                                  ? cert.certificateType
                                  : _inferCertificateTypeFromRecord(cert),
                            ),
                          ),
                        ).then((_) => _loadCertificates());
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteCertificate(cert);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by control #, name, or business...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _filterCertificateType,
                  decoration: const InputDecoration(
                    labelText: 'Certificate type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All types'),
                    ),
                    ..._certificateTypeLabels.entries.map(
                      (e) => DropdownMenuItem<String?>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _filterCertificateType = v);
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _filterDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) _filterByDate(date);
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: Text(
                          _filterDate == null
                              ? 'Issued date'
                              : DateFormat('MMM d, yyyy')
                                  .format(_filterDate!),
                        ),
                      ),
                    ),
                    if (_filterDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _filterByDate(null),
                        icon: const Icon(Icons.clear_rounded),
                        tooltip: 'Clear date',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCertificates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No certificates found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCertificates.length,
                        itemBuilder: (context, index) {
                          final cert = _filteredCertificates[index];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: cs.primaryContainer,
                                foregroundColor: cs.onPrimaryContainer,
                                child: Text(
                                  _initials(cert.controlNumber),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(
                                cert.controlNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _labelForCertificateType(
                                      cert.certificateType,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '${cert.applicantName} · ${cert.businessName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cert.syncStatus == CertificateModel.syncStatusSynced
                                        ? Icons.cloud_done_rounded
                                        : Icons.cloud_upload_rounded,
                                    size: 20,
                                    color: cert.syncStatus == CertificateModel.syncStatusSynced
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right_rounded,
                                      color: cs.onSurfaceVariant),
                                ],
                              ),
                              onTap: () => _viewDetails(cert),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

String _inferCertificateTypeFromRecord(CertificateModel cert) {
  final nature = cert.natureOfBusiness.toLowerCase();
  if (nature.contains('builder')) {
    return 'builders_form';
  }
  if (nature.contains('motor')) {
    return 'motorized_certification';
  }
  if (nature.contains('exclusive') || nature.contains('fish privilege')) {
    return 'exclusive_fish_privilege';
  }
  return 'marine_certification';
}

String _initials(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'CI';
  final cleaned = v.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (cleaned.length >= 2) return cleaned.substring(0, 2).toUpperCase();
  return cleaned.toUpperCase();
}
