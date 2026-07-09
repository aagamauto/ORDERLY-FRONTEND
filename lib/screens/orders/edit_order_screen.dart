import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';

import '../../models/customer_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class EditOrderScreen extends ConsumerStatefulWidget {
  const EditOrderScreen({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  bool _initialized = false;
  CustomerModel? _selectedCustomer;
  List<OrderItemCreate> _items = [];
  List<TextEditingController> _controllers = [];
  List<TextEditingController> _categoryControllers = [];
  int _amount = 0;
  String _mode = kPaymentModes.first;
  bool _loading = false;
  OrderDetail? _originalDetail;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '0');
  }

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

  void _initFromData(OrderDetail detail, OrderPreload preload) {
    if (_initialized) return;
    _initialized = true;
    _originalDetail = detail;

    // Pre-populate customer from payment.custId
    final custId = detail.payment?.custId;
    if (custId != null) {
      try {
        _selectedCustomer =
            preload.customers.firstWhere((c) => c.custId == custId);
      } catch (_) {}
    }

    // Pre-populate items — look up pname by matching pid in preload
    _items = [];
    _controllers = [];
    _categoryControllers = [];

    for (final item in detail.items) {
      final product = preload.items.cast<ProductModel?>().firstWhere(
            (p) => p?.pid == item.pid,
            orElse: () => null,
          );
      final pname = product?.pname ?? '';

      _items.add(OrderItemCreate(
        pname: pname,
        category: item.category,
        quantity: item.quantity,
        pridis: item.pridis,
        selectedProduct: product,
      ));
      _controllers.add(TextEditingController(text: pname));
      _categoryControllers.add(TextEditingController(text: item.category));
    }

    if (_items.isEmpty) {
      _items.add(OrderItemCreate());
      _controllers.add(TextEditingController());
      _categoryControllers.add(TextEditingController());
    }

    // Pre-populate payment
    _mode = detail.payment?.mode ?? kPaymentModes.first;
    _amount = detail.payment?.amount ?? 0;
    _amountController.text = _amount.toString();
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
    try {
      final userId = ref.read(userIdProvider) ?? 0;
      final payment = _originalDetail?.payment;

      await DioClient.instance.dio.put(
        '/Orders/${widget.orderId}/update/',
        data: {
          'orderdetails': {
            'ord_id': widget.orderId,
            'cust_id': _selectedCustomer!.custId,
            'user_id': userId,
            'total_quantity': _items.fold(0, (s, i) => s + i.quantity),
            'status': 'pending',
          },
          'orderitems': _items.map((i) => i.toJson()).toList(),
          'Payment': {
            'payment_id': payment?.paymentId,
            'ord_id': widget.orderId,
            'cust_id': _selectedCustomer!.custId,
            'Amount': _mode == 'Next Visit' ? 0 : _amount,
            'Mode': _mode,
          },
        },
      );

      ref.invalidate(orderListProvider);
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) context.pop();
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                e.response?.data['detail'] as String? ??
                    'Failed to update order'),
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
    final detailAsync = ref.watch(orderDetailProvider(widget.orderId));
    final preloadAsync = ref.watch(orderPreloadProvider);

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Edit Order #${widget.orderId}')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: Text('Edit Order #${widget.orderId}')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load: $err'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(orderDetailProvider(widget.orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (detail) => preloadAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text('Edit Order #${widget.orderId}')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: Text('Edit Order #${widget.orderId}')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load: $err'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(orderPreloadProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (preload) {
          _initFromData(detail, preload);

          return Scaffold(
            appBar: AppBar(title: Text('Edit Order #${widget.orderId}')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Customer ──────────────────────────────────────────
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
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Select Customer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onSelected: (value) =>
                        setState(() => _selectedCustomer = value),
                  ),
                  const SizedBox(height: 20),

                  // ── Order Items ───────────────────────────────────────
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
                    return _EditOrderItemRow(
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

                  // ── Payment ───────────────────────────────────────────
                  Text(
                    'Payment',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Key forces rebuild when _mode changes from _initFromData
                  DropdownButtonFormField<String>(
                    key: ValueKey(_mode),
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
                          ? Colors.grey.shade200
                          : null,
                    ),
                    onChanged: (v) {
                      _amount = int.tryParse(v) ?? 0;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Submit ────────────────────────────────────────────
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
                        : const Text('Save Changes'),
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

// ── Item Row Widget ────────────────────────────────────────────────────────────

class _EditOrderItemRow extends StatefulWidget {
  const _EditOrderItemRow({
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
  State<_EditOrderItemRow> createState() => _EditOrderItemRowState();
}

class _EditOrderItemRowState extends State<_EditOrderItemRow> {
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
                      if (pattern.isEmpty) return products.take(10).toList();
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
                SizedBox(
                  width: 70,
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
                SizedBox(
                  width: 100,
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
                const Spacer(),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
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
