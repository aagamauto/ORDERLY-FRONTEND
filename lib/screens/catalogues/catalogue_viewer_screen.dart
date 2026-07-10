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
  }

  Future<void> _download(CatalogueModel cat) async {
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
    final preloaded = _catalogue;
    // Only resolve from the list when we weren't handed a preloaded model.
    // A one-shot read would spin forever if the screen is opened directly
    // (deep link) before the list has loaded, or for an id that no longer
    // exists — watching lets us settle into a viewer or a not-found state.
    final listAsync =
        preloaded == null ? ref.watch(catalogueListProvider) : null;
    final cat = preloaded ??
        listAsync?.asData?.value
            .where((c) => c.id == widget.id)
            .firstOrNull;
    final isLoading = preloaded == null && (listAsync?.isLoading ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cat?.title ?? 'Loading...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
            onPressed:
                (cat == null || _downloading) ? null : () => _download(cat),
          ),
        ],
      ),
      body: cat != null
          ? SfPdfViewer.network(
              cat.fileUrl,
              canShowScrollHead: true,
              canShowScrollStatus: true,
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Catalogue not found',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'It may have been removed or is unavailable.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go back'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
