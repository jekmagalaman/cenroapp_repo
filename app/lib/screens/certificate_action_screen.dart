import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'form_screen.dart';

/// After choosing certificate type: register new or renew an existing one.
class CertificateActionScreen extends StatelessWidget {
  final String certificateType;

  const CertificateActionScreen({super.key, required this.certificateType});

  static const Map<String, String> _typeTitles = {
    'builders_form': 'Builders Form',
    'motorized_certification': 'Motorized Certification',
    'marine_certification': 'Marine Certification',
    'exclusive_fish_privilege': 'Exclusive Fish Privilege',
  };

  String get _title => _typeTitles[certificateType] ?? 'Certificate';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Is this a new certificate or a renewal of an existing registration?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.fiber_new_rounded, color: cs.onPrimaryContainer),
              ),
              title: const Text(
                'New certificate',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Start with a blank form and a new control number'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormScreen(
                      certificateType: certificateType,
                      licenseTypeLock: 'New',
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.secondaryContainer,
                child: Icon(Icons.refresh_rounded, color: cs.onSecondaryContainer),
              ),
              title: const Text(
                'Renew',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Enter the registered control number to load and update that certificate',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RenewCertificateLookupScreen(
                      certificateType: certificateType,
                      typeTitle: _title,
                    ),
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

class RenewCertificateLookupScreen extends StatefulWidget {
  final String certificateType;
  final String typeTitle;

  const RenewCertificateLookupScreen({
    super.key,
    required this.certificateType,
    required this.typeTitle,
  });

  @override
  State<RenewCertificateLookupScreen> createState() =>
      _RenewCertificateLookupScreenState();
}

class _RenewCertificateLookupScreenState extends State<RenewCertificateLookupScreen> {
  final _db = DbHelper();
  final _controlFieldKey = GlobalKey<FormState>();
  final _controlController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controlController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    if (!(_controlFieldKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final cert = await _db.getLatestCertificateByControlNumberAndType(
        _controlController.text,
        widget.certificateType,
      );
      if (!mounted) return;
      if (cert == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No saved certificate found for that control number and type.',
            ),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FormScreen(
            certificate: cert.copyWith(licenseType: 'Renew'),
            certificateType: widget.certificateType,
            licenseTypeLock: 'Renew',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Renew — ${widget.typeTitle}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Enter the control number from the original registration. The saved record will open so you can update it for renewal.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _controlFieldKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Registered control number',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controlController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. MC-001',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter the control number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loading ? null : _lookup,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(_loading ? 'Loading…' : 'Load certificate'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
