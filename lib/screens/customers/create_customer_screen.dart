import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/customer_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive.dart';

class CreateCustomerScreen extends ConsumerStatefulWidget {
  const CreateCustomerScreen({super.key});

  @override
  ConsumerState<CreateCustomerScreen> createState() =>
      _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends ConsumerState<CreateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _contactCtrl.dispose();
    _shopCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await DioClient.instance.dio.post('/Customer/Create', data: {
        'name': _nameCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
        'shop': _shopCtrl.text.trim(),
      });
      ref.invalidate(customerListProvider);
      if (mounted) context.pop();
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data['detail'] as String? ??
                  'Failed to create customer',
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CenteredConstrained(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // City
                TextFormField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'City is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // State
                TextFormField(
                  controller: _stateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'State *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'State is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Contact
                TextFormField(
                  controller: _contactCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contact *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Contact number is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Shop Name
                DropdownButtonFormField<String>(
                  // Set the initial value if _shopCtrl already has text, otherwise null
                  initialValue:
                      _shopCtrl.text.isNotEmpty ? _shopCtrl.text : null,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  items: kShopNameOptions.map((String shop) {
                    return DropdownMenuItem<String>(
                      value: shop,
                      child: Text(shop),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _shopCtrl.text = newValue ?? '';
                    });
                  },
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Shop name is required' : null,
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          'Create Customer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
