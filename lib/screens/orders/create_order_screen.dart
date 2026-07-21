import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import '../../models/customer_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../services/offline_queue.dart';
import '../../utils/constants.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  CustomerModel? _selectedCustomer;
  final List<OrderItemCreate> _items = [OrderItemCreate()];
  int _amount = 0;
  String _mode = 'Cash';
  bool _loading = false;

  // TypeAhead controllers for product name per item
  final List<TextEditingController> _controllers = [TextEditingController()];
  // Category controllers per item
  final List<TextEditingController> _categoryControllers = [
    TextEditingController()
  ];
  // Amount text controller
  final TextEditingController _amountController =
      TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final c in _categoryControllers) {
      c.dispose();
    }
    _amountController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(OrderItemCreate());
      _controllers.add(TextEditingController());
      _categoryControllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) return;
    setState(() {
      _items.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _categoryControllers[index].dispose();
      _categoryControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a customer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_items.any((i) => !i.isValid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all item fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _loading = true);

    // The order is tied to the logged-in salesman on the server (from the JWT),
    // so we no longer send user_id from the client.
    final payload = <String, dynamic>{
      'cust_id': _selectedCustomer!.custId,
      'items': _items.map((i) => i.toJson()).toList(),
      'Amount': _mode == 'Next Visit' ? 0 : _amount,
      'Mode': _mode,
      // Idempotency: the same key travels on the online submit AND any offline
      // re-queue, so a network drop mid-request can't create a duplicate order.
      'client_uuid':
          '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(0x7fffffff)}',
    };

    try {
      // Offline? Save locally and let the queue sync it automatically.
      if (!await OfflineQueue.instance.isOnline()) {
        await OfflineQueue.instance.enqueue(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No internet — order saved and will sync automatically.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
        return;
      }

      await DioClient.instance.dio.post('/Orders/add/', data: payload);
      ref.invalidate(orderListProvider);
      ref.invalidate(myOrderListProvider);
      if (mounted) context.pop();
    } on DioException catch (e) {
      final networky = e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      if (networky) {
        await OfflineQueue.instance.enqueue(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Connection issue — order saved and will sync automatically.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['detail'] as String? ??
                'Failed to create order'),
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
    final preloadAsync = ref.watch(orderPreloadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
      ),
      body: preloadAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  extractApiError(err),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderPreloadProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (preload) {
          return CenteredConstrained(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // ── Section 1: Customer ──────────────────────────────
                Text(
                  'Customer',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownSearch<CustomerModel>(
                  items: (filter, _) {
                    final q = filter.toLowerCase();
                    if (q.isEmpty) return preload.customers;
                    return preload.customers
                        .where((c) =>
                            c.name.toLowerCase().contains(q) ||
                            c.shop.toLowerCase().contains(q))
                        .toList();
                  },
                  selectedItem: _selectedCustomer,
                  itemAsString: (c) => '${c.name} • ${c.shop}',
                  compareFn: (a, b) => a.custId == b.custId,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                  ),
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Select Customer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onSelected: (value) {
                    setState(() => _selectedCustomer = value);
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New Customer'),
                  onPressed: () async {
                    await context.push('/customers/create');
                    ref.invalidate(customerListProvider);
                  },
                ),
                const SizedBox(height: 20),

                // ── Section 2: Order Items ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Items',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Item',
                      onPressed: _addItem,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...List.generate(_items.length, (index) {
                  return _OrderItemRow(
                    index: index,
                    item: _items[index],
                    controller: _controllers[index],
                    categoryController: _categoryControllers[index],
                    onRemove: () => _removeItem(index),
                    onChanged: () => setState(() {}),
                    getProducts: () =>
                        ref.read(orderPreloadProvider).asData?.value.items ??
                        [],
                    getCategories: () {
                      final items = ref
                              .read(orderPreloadProvider)
                              .asData
                              ?.value
                              .items ??
                          [];
                      return (items.map((p) => p.category).toSet().toList()
                            ..sort())
                          .cast<String>();
                    },
                  );
                }),
                const SizedBox(height: 20),

                // ── Section 3: Payment ───────────────────────────────
                Text(
                  'Payment',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _mode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: kPaymentModes
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _mode = value;
                      if (_mode == 'Next Visit') {
                        _amount = 0;
                        _amountController.text = '0';
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  enabled: _mode != 'Next Visit',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    border: const OutlineInputBorder(),
                    filled: _mode == 'Next Visit',
                    fillColor: _mode == 'Next Visit'
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : null,
                  ),
                  onChanged: (v) {
                    _amount = int.tryParse(v) ?? 0;
                  },
                ),
                const SizedBox(height: 24),

                // ── Submit ───────────────────────────────────────────
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Order'),
                ),
                const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderItemRow extends StatefulWidget {
  const _OrderItemRow({
    required this.index,
    required this.item,
    required this.controller,
    required this.categoryController,
    required this.onRemove,
    required this.onChanged,
    required this.getProducts,
    required this.getCategories,
  });

  final int index;
  final OrderItemCreate item;
  final TextEditingController controller;
  final TextEditingController categoryController;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final List<ProductModel> Function() getProducts;
  final List<String> Function() getCategories;

  @override
  State<_OrderItemRow> createState() => _OrderItemRowState();
}

class _OrderItemRowState extends State<_OrderItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _pridisController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity > 0 ? widget.item.quantity.toString() : '',
    );
    _pridisController =
        TextEditingController(text: widget.item.pridis ?? '');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _pridisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product TypeAhead
                Expanded(
                  flex: 3,
                  child: TypeAheadField<ProductModel>(
                    controller: widget.controller,
                    suggestionsCallback: (pattern) {
                      final products = widget.getProducts();
                      if (pattern.isEmpty) {
                        return products.take(10).toList();
                      }
                      return products
                          .where((p) => p.pname
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList();
                    },
                    builder: (context, controller, focusNode) => TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => widget.item.pname = v,
                    ),
                    itemBuilder: (context, product) => ListTile(
                      title: Text(product.pname),
                      subtitle: Text(product.category),
                      dense: true,
                    ),
                    onSelected: (product) {
                      widget.item.pname = product.pname;
                      widget.item.category = product.category;
                      widget.item.selectedProduct = product;
                      widget.controller.text = product.pname;
                      widget.categoryController.text = product.category;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Category — typeahead from existing, free-type for new
                Expanded(
                  flex: 2,
                  child: TypeAheadField<String>(
                    controller: widget.categoryController,
                    suggestionsCallback: (pattern) {
                      final cats = widget.getCategories();
                      if (pattern.isEmpty) return cats;
                      return cats
                          .where((c) => c
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList();
                    },
                    builder: (context, controller, focusNode) => TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => widget.item.category = v,
                    ),
                    itemBuilder: (context, cat) => ListTile(
                      dense: true,
                      title: Text(cat),
                    ),
                    onSelected: (cat) {
                      widget.item.category = cat;
                      widget.categoryController.text = cat;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Quantity
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      widget.item.quantity = int.tryParse(v) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Price / Discount note
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _pridisController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      widget.item.pridis = v.isEmpty ? null : v;
                    },
                  ),
                ),
                // Delete
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error),
                  tooltip: 'Remove item',
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
