import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/order_status.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key, this.mineOnly = false});

  final bool mineOnly;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showUpdateBottomSheet(BuildContext context, PaymentWithCustomer p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _UpdatePaymentSheet(payment: p, onSuccess: () {
        ref.invalidate(paymentListProvider);
        ref.invalidate(myPaymentListProvider);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = widget.mineOnly
        ? ref.watch(myPaymentListProvider)
        : ref.watch(paymentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mineOnly ? 'My Payments' : 'Payments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search by customer name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                final filtered = _searchQuery.isEmpty
                    ? payments
                    : payments
                        .where((p) =>
                            p.name.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No payments found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.payments_outlined),
                        ),
                        title: Text(
                          '${p.name}  •  ${p.shop}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                            '${p.mode}  •  ${p.date?.toString().substring(0, 10) ?? '-'}'),
                        trailing: Text(
                          formatMoney(p.amount),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _showUpdateBottomSheet(context, p),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $e'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => widget.mineOnly
                          ? ref.invalidate(myPaymentListProvider)
                          : ref.invalidate(paymentListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdatePaymentSheet extends StatefulWidget {
  const _UpdatePaymentSheet({
    required this.payment,
    required this.onSuccess,
  });

  final PaymentWithCustomer payment;
  final VoidCallback onSuccess;

  @override
  State<_UpdatePaymentSheet> createState() => _UpdatePaymentSheetState();
}

class _UpdatePaymentSheetState extends State<_UpdatePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late String _selectedMode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
        text: widget.payment.amount?.toString() ?? '');
    _selectedMode = widget.payment.mode;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await DioClient.instance.dio.put(
        '/Payment/${widget.payment.paymentId}',
        data: {
          'Amount': int.tryParse(_amountCtrl.text.trim()) ?? 0,
          'Mode': _selectedMode,
        },
      );
      widget.onSuccess();
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data['detail'] as String? ??
                  'Failed to update payment',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Payment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: kPaymentModes.contains(_selectedMode)
                    ? _selectedMode
                    : kPaymentModes.first,
                decoration: const InputDecoration(
                  labelText: 'Mode',
                  border: OutlineInputBorder(),
                ),
                items: kPaymentModes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMode = v);
                },
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Select a mode' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
