import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/responsive.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key});

  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await DioClient.instance.dio.post('/Product/Create', data: {
        'pname': _nameCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
      });
      ref.invalidate(productListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product created!'), behavior: SnackBarBehavior.floating),
        );
        context.pop();
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['detail'] as String? ?? 'Failed to create product'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CenteredConstrained(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Product name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                // Category with autocomplete for existing categories
                Autocomplete<String>(
                  optionsBuilder: (textValue) {
                    if (textValue.text.isEmpty) return categories;
                    return categories.where(
                      (c) =>
                          c.toLowerCase().contains(textValue.text.toLowerCase()),
                    );
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
                    // Sync the autocomplete's internal controller to our _categoryCtrl
                    if (controller.text.isEmpty &&
                        _categoryCtrl.text.isNotEmpty) {
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
                            ? 'e.g. Shirts'
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
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: const Text('Create Product',
                        style: TextStyle(fontSize: 16)),
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
