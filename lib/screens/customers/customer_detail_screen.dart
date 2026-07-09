import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/customer_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/payment_provider.dart';
import '../../services/api_service.dart';
import '../../utils/order_status.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.custId});

  final int custId;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerByIdProvider(widget.custId));

    return customerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Failed to load customer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.invalidate(customerByIdProvider(widget.custId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (customer) => _CustomerDetailBody(
        custId: widget.custId,
        customer: customer,
      ),
    );
  }
}

class _CustomerDetailBody extends ConsumerWidget {
  const _CustomerDetailBody({
    required this.custId,
    required this.customer,
  });

  final int custId;
  final CustomerModel customer;

  void _showUpdateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _UpdateCustomerSheet(
        custId: custId,
        customer: customer,
        onSuccess: () => ref.invalidate(customerByIdProvider(custId)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(customer.name),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Info Card
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${customer.city}, ${customer.state}'),
                          Text('📞 ${customer.contact}'),
                          Text('🏪 ${customer.shop}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: ElevatedButton.icon(
                        onPressed: () => _showUpdateSheet(context, ref),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Update Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar
            const TabBar(
              tabs: [
                Tab(text: 'Orders'),
                Tab(text: 'Payments'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _OrdersTab(custId: custId),
                  _PaymentsTab(custId: custId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Orders Tab
// ---------------------------------------------------------------------------

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({required this.custId});

  final int custId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider(custId));
    final userRole = ref.watch(userRoleProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Failed to load orders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(customerOrdersProvider(custId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No orders yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final summary = orders[index];
            return _OrderCard(
              custId: custId,
              summary: summary,
              userRole: userRole,
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({
    required this.custId,
    required this.summary,
    required this.userRole,
  });

  final int custId;
  final CustomerOrderSummary summary;
  final String? userRole;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _dispatching = false;

  Future<void> _dispatch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispatch Order'),
        content: Text('Are you sure you want to dispatch Order #${widget.summary.ordId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dispatch'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _dispatching = true);
    try {
      await DioClient.instance.dio.put(
        '/Customer/${widget.custId}/Orders/${widget.summary.ordId}/dispatch/',
      );
      ref.invalidate(customerOrdersProvider(widget.custId));
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data['detail'] as String? ?? 'Failed to dispatch order',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dispatching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final isStaff =
        widget.userRole == 'Admin' || widget.userRole == 'Employee';
    final style = orderStatusStyle(summary.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(style.icon, color: style.color.shade700),
            title: Text(
              'Order #${summary.ordId}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${summary.formattedCreateDate}  •  Qty: ${summary.totalQuantity}'
              '${summary.userName != null ? '\nBy: ${summary.userName}' : ''}',
            ),
            trailing: Chip(
              label: Text(
                style.label,
                style: TextStyle(
                  color: style.color.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: style.color.shade100,
              padding: EdgeInsets.zero,
            ),
            onTap: () => context.push(
              '/customers/${widget.custId}/orders/${summary.ordId}',
            ),
          ),
          if (isStaff && !summary.isDispatched)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: _dispatching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : summary.isPacked
                        ? TextButton.icon(
                            onPressed: _dispatch,
                            icon: const Icon(Icons.local_shipping_outlined),
                            label: const Text('Dispatch'),
                          )
                        : TextButton.icon(
                            onPressed: () async {
                              await context
                                  .push('/orders/pack/${summary.ordId}');
                              ref.invalidate(
                                  customerOrdersProvider(widget.custId));
                            },
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Pack'),
                          ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payments Tab
// ---------------------------------------------------------------------------

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.custId});

  final int custId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(customerPaymentsProvider(custId));

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Failed to load payments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(customerPaymentsProvider(custId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payments_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No payments recorded',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final p = payments[index];
            return _PaymentCard(payment: p);
          },
        );
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentWithCustomer payment;

  @override
  Widget build(BuildContext context) {
    final dateStr = payment.date != null
        ? payment.date.toString().substring(0, 10)
        : '-';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: const Icon(Icons.payments_outlined),
        title: Text(
          'Order #${payment.ordId}  —  ₹${payment.amount ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${payment.mode}  •  $dateStr'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Update Customer Bottom Sheet
// ---------------------------------------------------------------------------

class _UpdateCustomerSheet extends ConsumerStatefulWidget {
  const _UpdateCustomerSheet({
    required this.custId,
    required this.customer,
    required this.onSuccess,
  });

  final int custId;
  final CustomerModel customer;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_UpdateCustomerSheet> createState() =>
      _UpdateCustomerSheetState();
}

class _UpdateCustomerSheetState extends ConsumerState<_UpdateCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _shopCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer.name);
    _cityCtrl = TextEditingController(text: widget.customer.city);
    _stateCtrl = TextEditingController(text: widget.customer.state);
    _contactCtrl = TextEditingController(text: widget.customer.contact);
    _shopCtrl = TextEditingController(text: widget.customer.shop);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _contactCtrl.dispose();
    _shopCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await DioClient.instance.dio.put(
        '/Customer/${widget.custId}',
        data: {
          'name': _nameCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _stateCtrl.text.trim(),
          'contact': _contactCtrl.text.trim(),
          'shop': _shopCtrl.text.trim(),
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
                  'Failed to update customer',
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Customer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'City is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateCtrl,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'State is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Contact is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shopCtrl,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Shop name is required'
                        : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
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
