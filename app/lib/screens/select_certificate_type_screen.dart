import 'package:flutter/material.dart';
import 'certificate_action_screen.dart';

class CertificateTypeOption {
  final String key;
  final String label;
  final String description;
  final IconData icon;

  const CertificateTypeOption({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
}

class SelectCertificateTypeScreen extends StatelessWidget {
  const SelectCertificateTypeScreen({super.key});

  static const List<CertificateTypeOption> _types = [
    CertificateTypeOption(
      key: 'builders_form',
      label: 'Builders Form',
      description: 'Certificate workflow for builders form applications',
      icon: Icons.construction_rounded,
    ),
    CertificateTypeOption(
      key: 'motorized_certification',
      label: 'Motorized Certification',
      description: 'Certificate workflow for motorized units/operations',
      icon: Icons.directions_boat_filled_rounded,
    ),
    CertificateTypeOption(
      key: 'marine_certification',
      label: 'Marine Certification',
      description: 'Certificate workflow for marine-related applications',
      icon: Icons.sailing_rounded,
    ),
    CertificateTypeOption(
      key: 'exclusive_fish_privilege',
      label: 'Exclusive Fish Privilege',
      description: 'Certificate workflow for exclusive fish privilege',
      icon: Icons.phishing_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Certificate Type'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose the certificate type before proceeding to the form.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ..._types.map(
            (type) => Card(
              margin: const EdgeInsets.symmetric(vertical: 7),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(type.icon, color: cs.onPrimaryContainer),
                ),
                title: Text(
                  type.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(type.description),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CertificateActionScreen(certificateType: type.key),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
