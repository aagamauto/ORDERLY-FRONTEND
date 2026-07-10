import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../../utils/order_status.dart';

/// Packing-staff screen: enter MRP + packed quantity per item to make the bill,
/// then optionally dispatch. MRP auto-loads from the product's last value.
class PackOrderScreen extends ConsumerStatefulWidget {
  const PackOrderScreen({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<PackOrderScreen> createState() => _PackOrderScreenState();
}

class _PackLine {
  _PackLine({
    required this.itemId,
    required this.pid,
    required this.pname,
    required this.orderedQty,
    required this.mrpController,
    required this.packedQtyController,
  });

  final int itemId;
  final int pid;
  final String pname;
  final int orderedQty;
  final TextEditingController mrpController;
  final TextEditingController packedQtyController;
}

/// Clamps a numeric text field to a maximum value — used to cap the packed
/// quantity at the ordered quantity (handles typing and paste).
class _MaxIntFormatter extends TextInputFormatter {
  _MaxIntFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final n = int.tryParse(newValue.text);
    if (n == null) return oldValue;
    if (n > max) {
      final t = max.toString();
      return TextEditingValue(
        text: t,
        selection: TextSelection.collapsed(offset: t.length),
      );
    }
    return newValue;
  }
}

class _PackOrderScreenState extends ConsumerState<PackOrderScreen> {
  bool _initialized = false;
  bool _saving = false;
  final List<_PackLine> _lines = [];

  @override
  void dispose() {
    for (final l in _lines) {
      l.mrpController.dispose();
      l.packedQtyController.dispose();
    }
    super.dispose();
  }

  void _init(OrderDetail detail, List<ProductModel> products) {
    if (_initialized) return;
    _initialized = true;
    for (final item in detail.items) {
      // MRP: use the frozen order MRP if already packed, else the product's
      // remembered MRP (auto-load).
      double? mrp = item.mrp;
      if (mrp == null) {
        final p = products.cast<ProductModel?>().firstWhere(
              (p) => p?.pid == item.pid,
              orElse: () => null,
            );
        mrp = p?.mrp;
      }
      _lines.add(_PackLine(
        itemId: item.id,
        pid: item.pid,
        pname: item.pname,
        orderedQty: item.quantity,
        mrpController:
            TextEditingController(text: mrp == null ? '' : _trimNum(mrp)),
        packedQtyController: TextEditingController(
            text: (item.packedQuantity ?? item.quantity).toString()),
      ));
    }
  }

  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  double get _billTotal {
    double total = 0;
    for (final l in _lines) {
      final mrp = double.tryParse(l.mrpController.text.trim()) ?? 0;
      final qty = int.tryParse(l.packedQtyController.text.trim()) ?? 0;
      total += mrp * qty;
    }
    return total;
  }

  Future<void> _save({required bool thenDispatch}) async {
    setState(() => _saving = true);
    try {
      final items = _lines.map((l) {
        final mrp = double.tryParse(l.mrpController.text.trim());
        final packed = int.tryParse(l.packedQtyController.text.trim()) ?? 0;
        final map = <String, dynamic>{
          'id': l.itemId,
          'packed_quantity': packed,
        };
        if (mrp != null) map['mrp'] = mrp;
        return map;
      }).toList();

      await DioClient.instance.dio
          .put('/Orders/${widget.orderId}/pack/', data: {'items': items});

      if (thenDispatch) {
        await DioClient.instance.dio.put('/Orders/${widget.orderId}/dispatch/');
      }

      ref.invalidate(orderDetailProvider(widget.orderId));
      ref.invalidate(dispatchQueueProvider);
      ref.invalidate(orderListProvider);
      ref.invalidate(myOrderListProvider);
      ref.invalidate(productListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(thenDispatch
                ? 'Order packed & dispatched'
                : 'Order packed — bill saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['detail'] as String? ??
                'Failed to save. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDispatch() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pack & Dispatch'),
        content: const Text(
            'Save the MRPs and dispatch this order now? Once dispatched it can no longer be edited.'),
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
    if (ok == true) _save(thenDispatch: true);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(orderDetailProvider(widget.orderId));
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Pack Order #${widget.orderId}')),
      body: detailAsync.when(
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(orderDetailProvider(widget.orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (detail) {
          // Wait for the product list (for remembered MRP) unless it errored.
          if (productsAsync.isLoading && !productsAsync.hasValue) {
            return const Center(child: CircularProgressIndicator());
          }
          final products =
              productsAsync.asData?.value ?? const <ProductModel>[];
          _init(detail, products);

          if (_lines.isEmpty) {
            return const Center(child: Text('This order has no items.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Text(
                      'Enter MRP and the quantity you actually packed. '
                      'Packing less than ordered marks the order Partially Dispatched.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ..._lines.map(_buildLine),
                  ],
                ),
              ),
              _buildBottomBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLine(_PackLine l) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.pname.isNotEmpty ? l.pname : 'Item #${l.itemId}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Ordered: ${l.orderedQty}',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: l.mrpController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'MRP (₹)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: l.packedQtyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _MaxIntFormatter(l.orderedQty),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Packed',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      helperText: 'max ${l.orderedQty}',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bill total',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Flexible(
                  child: Text(
                    formatMoney(_billTotal),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final saveButton = OutlinedButton.icon(
                  onPressed: _saving ? null : () => _save(thenDispatch: false),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Save Packed'),
                );
                final dispatchButton = ElevatedButton.icon(
                  onPressed: _saving ? null : _confirmDispatch,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.local_shipping_outlined),
                  label: const Text('Pack & Dispatch'),
                );
                // Narrow screens / large fonts: stack full-width to avoid overflow.
                if (constraints.maxWidth < 360) {
                  return Column(
                    children: [
                      SizedBox(width: double.infinity, child: saveButton),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: dispatchButton),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: saveButton),
                    const SizedBox(width: 8),
                    Expanded(child: dispatchButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
