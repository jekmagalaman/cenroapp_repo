import 'dart:io';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/photo_report_model.dart';

class PhotoReportsListScreen extends StatefulWidget {
  const PhotoReportsListScreen({super.key});

  @override
  State<PhotoReportsListScreen> createState() => _PhotoReportsListScreenState();
}

class _PhotoReportsListScreenState extends State<PhotoReportsListScreen> {
  final _db = DbHelper();
  bool _loading = true;
  List<PhotoReportModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _db.getAllPhotoReports();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _delete(PhotoReportModel r) async {
    if (r.id == null) return;
    await _db.deletePhotoReport(r.id!);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Photo Reports'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    'No photo reports yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = _items[i];
                    final img = File(r.imagePath);
                    final statusColor = r.syncStatus == PhotoReportModel.syncStatusSynced
                        ? cs.tertiary
                        : cs.primary;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: img.existsSync()
                                  ? Image.file(
                                      img,
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 84,
                                      height: 84,
                                      color: cs.surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child: Icon(Icons.broken_image_rounded,
                                          color: cs.onSurfaceVariant),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          r.syncStatus,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        r.createdAt,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    r.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  if (r.latitude != null && r.longitude != null)
                                    Text(
                                      'Location: ${r.latitude!.toStringAsFixed(6)}, ${r.longitude!.toStringAsFixed(6)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    )
                                  else
                                    Text(
                                      'Location: —',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _delete(r),
                                      icon: const Icon(Icons.delete_outline_rounded),
                                      label: const Text('Delete'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

