import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../models/catalogue_model.dart';
import '../../providers/catalogue_provider.dart';

class CatalogueViewerScreen extends ConsumerStatefulWidget {
  const CatalogueViewerScreen({
    super.key,
    required this.id,
    this.preloaded,
  });

  final int id;
  final CatalogueModel? preloaded;

  @override
  ConsumerState<CatalogueViewerScreen> createState() =>
      _CatalogueViewerScreenState();
}

class _CatalogueViewerScreenState extends ConsumerState<CatalogueViewerScreen> {
  CatalogueModel? _catalogue;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _catalogue = widget.preloaded;
    if (_catalogue == null) _loadFromList();
  }

  void _loadFromList() {
    final list = ref.read(catalogueListProvider).asData?.value;
    if (list == null) return;
    final found = list.where((c) => c.id == widget.id).firstOrNull;
    if (found != null) setState(() => _catalogue = found);
  }

  Future<void> _download() async {
    final cat = _catalogue;
    if (cat == null) return;
    setState(() => _downloading = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeName = cat.title.replaceAll(RegExp(r'[^\w\s.-]'), '_');
      final path = '${dir.path}/$safeName.pdf';

      // Fresh Dio bypasses our app's auth interceptor — R2 presigned URLs
      // reject requests that carry an extra Authorization header.
      await Dio().download(cat.fileUrl, path);

      if (!mounted) return;
      _snack('Saved');
      await OpenFilex.open(path);
    } catch (e) {
      if (!mounted) return;
      _snack('Download failed: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = _catalogue;

    return Scaffold(
      appBar: AppBar(
        title: Text(cat?.title ?? 'Loading...'),
        actions: [
          IconButton(
            icon: _downloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: (cat == null || _downloading) ? null : _download,
          ),
        ],
      ),
      body: cat == null
          ? const Center(child: CircularProgressIndicator())
          : SfPdfViewer.network(
              cat.fileUrl,
              canShowScrollHead: true,
              canShowScrollStatus: true,
            ),
    );
  }
}
