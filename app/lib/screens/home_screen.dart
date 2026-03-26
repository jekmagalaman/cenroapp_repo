import 'package:flutter/material.dart';
import 'records_screen.dart';
import 'select_certificate_type_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

/// Home screen with main navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _syncing = false;

  Future<void> _onSync() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in first to send certificates to admin.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() => _syncing = true);
    final count = await SyncService.syncPendingToServer();
    if (!mounted) return;
    setState(() => _syncing = false);

    if (count == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in first to sync.')),
      );
      return;
    }
    if (count == 0) {
      final hasConn = await SyncService.hasConnection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasConn
                ? 'No pending certificates to sync.'
                : 'No internet connection.',
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count certificate(s) sent to admin.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              AppColors.gradientStart,
              AppColors.gradientMid,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _HeaderCard(),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.add_rounded,
                title: 'Create new certificate',
                subtitle: 'Fill up details then export as PDF, Excel, or Word',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectCertificateTypeScreen(),
                    ),
                  );
                },
              ),
              _MenuCard(
                icon: Icons.folder_open_rounded,
                title: 'View records',
                subtitle: 'Search, filter by date, and manage saved certificates',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecordsScreen()),
                  );
                },
              ),
              _MenuCard(
                icon: Icons.cloud_upload_rounded,
                title: 'Send to admin',
                subtitle: 'Sync pending certificates to the admin dashboard',
                onTap: _syncing ? null : _onSync,
                trailing: _syncing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                'Tip: Exported files are saved to Documents/Certificate_Inspection.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Certificate of Inspection',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'City Government of Puerto Princesa • Bantay Dagat Section',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                ),
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (trailing != null) trailing! else Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
