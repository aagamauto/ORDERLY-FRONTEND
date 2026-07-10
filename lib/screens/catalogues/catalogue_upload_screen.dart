import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../providers/catalogue_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive.dart';

class CatalogueUploadScreen extends ConsumerStatefulWidget {
  const CatalogueUploadScreen({super.key});

  @override
  ConsumerState<CatalogueUploadScreen> createState() =>
      _CatalogueUploadScreenState();
}

class _CatalogueUploadScreenState extends ConsumerState<CatalogueUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  PlatformFile? _picked;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _picked = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_picked == null || _picked!.path == null) {
      _snack('Please pick a PDF file');
      return;
    }
    setState(() => _loading = true);

    try {
      final form = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'file': await MultipartFile.fromFile(
          _picked!.path!,
          filename: _picked!.name,
        ),
      });

      // Fresh Dio with manual auth — bypasses our shared LogInterceptor so
      // the multi-MB PDF binary doesn't get printed to debug logs.
      final token = await const FlutterSecureStorage().read(key: kTokenKey);
      final uploadDio = Dio(
        BaseOptions(
          baseUrl: kBaseUrl,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      await uploadDio.post(
        '/Catalogue/Create',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      ref.invalidate(catalogueListProvider);
      ref.invalidate(catalogueCategoriesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catalogue uploaded!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final detail = data is Map ? data['detail'] : null;
      _snack(detail?.toString() ?? 'Upload failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(catalogueCategoriesProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Catalogue')),
      body: CenteredConstrained(
        maxWidth: 480,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  optionsBuilder: (textValue) {
                    if (textValue.text.isEmpty) return categories;
                    return categories.where(
                      (c) => c.toLowerCase().contains(textValue.text.toLowerCase()),
                    );
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    if (controller.text.isEmpty && _categoryCtrl.text.isNotEmpty) {
                      controller.text = _categoryCtrl.text;
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSubmitted(),
                      onChanged: (v) => _categoryCtrl.text = v,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        hintText: categories.isEmpty
                            ? 'e.g. Spring Collection'
                            : 'Select or type new...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Category is required'
                          : null,
                    );
                  },
                  onSelected: (value) => _categoryCtrl.text = value,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _picked?.name ?? 'Pick PDF file',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_picked != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(_picked!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: const Text('Upload', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
