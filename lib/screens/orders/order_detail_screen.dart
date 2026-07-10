import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../../utils/order_status.dart';
import '../../widgets/responsive.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  Future<void> _dispatchOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispatch Order'),
        content: Text('Are you sure you want to dispatch Order #$orderId? '
            'Once dispatched it can no longer be edited.'),
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
    if (confirmed != true || !context.mounted) return;

    try {
      await DioClient.instance.dio.put('/Orders/$orderId/dispatch/');
      ref.invalidate(orderListProvider);
      ref.invalidate(myOrderListProvider);
      ref.invalidate(dispatchQueueProvider);
      ref.invalidate(orderDetailProvider(orderId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order dispatched'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['detail'] as String? ??
                'Failed to dispatch order'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
            'Are you sure you want to delete Order #$orderId? This will also delete all items and payment for this order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await DioClient.instance.dio.delete('/Orders/$orderId/delete/');
      ref.invalidate(orderListProvider);
      ref.invalidate(myOrderListProvider);
      ref.invalidate(dispatchQueueProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order deleted'),
              behavior: SnackBarBehavior.floating),
        );
        context.pop();
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['detail'] as String? ??
                'Failed to delete order'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final detailAsync = ref.watch(orderDetailProvider(orderId));
    final userRole = ref.watch(userRoleProvider);
    // Pull status/creator from cached list; falls back to myOrderList for non-admins.
    final allOrders = [
      ...ref.watch(orderListProvider).asData?.value ?? const [],
      ...ref.watch(myOrderListProvider).asData?.value ?? const [],
    ];
    final summaryIdx = allOrders.indexWhere((o) => o.ordId == orderId);
    final summary = summaryIdx >= 0 ? allOrders[summaryIdx] : null;

    final isStaff = userRole == 'Admin' || userRole == 'Employee';
    final locked = summary != null && summary.isDispatched;
    final canAct = summary != null && !summary.isDispatched && isStaff;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderId'),
      ),
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
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (detail) {
          return CenteredConstrained(
            maxWidth: kContentMaxWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Order Status ─────────────────────────────────────────
                if (summary != null) _StatusCard(summary: summary),
                if (summary != null) const SizedBox(height: 16),

                // ── Last edited by ───────────────────────────────────────
                if (detail.lastEditedByName != null) ...[
                  Row(
                    children: [
                      Icon(Icons.edit_note,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Last edited by ${detail.lastEditedByName}'
                          '${detail.lastEditedDate != null ? ' • ${formatDate(detail.lastEditedDate)}' : ''}',
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Order Items ──────────────────────────────────────────
                Text(
                  'Order Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (detail.items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No items found.'),
                    ),
                  )
                else
                  ...detail.items.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(
                          item.pname.isNotEmpty ? item.pname : item.category,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Category: ${item.category}  •  Qty: ${item.quantity}'
                          '${item.packedQuantity != null ? '  •  Packed: ${item.packedQuantity}' : ''}'
                          '${item.mrp != null ? '  •  MRP: ${formatMoney(item.mrp)}' : ''}'
                          '${item.pridis != null ? '\nNote: ${item.pridis}' : ''}',
                        ),
                        trailing: item.mrp != null
                            ? Text(
                                formatMoney(
                                    item.mrp! * (item.packedQuantity ?? item.quantity)),
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                              )
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Payment ──────────────────────────────────────────────
                Text(
                  'Payment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (detail.payment == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No payment information available.'),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _PaymentRow(
                              label: 'Mode', value: detail.payment!.mode),
                          const Divider(),
                          _PaymentRow(
                            label: 'Amount',
                            value: formatMoney(detail.payment!.amount),
                          ),
                          const Divider(),
                          _PaymentRow(
                            label: 'Date',
                            value: detail.payment!.date != null
                                ? formatDate(detail.payment!.date)
                                : '—',
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // ── Pack & Dispatch (staff, not yet dispatched) ─────────
                if (canAct) ...[
                  ElevatedButton.icon(
                    onPressed: () => context.push('/orders/pack/$orderId'),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(summary.isPacked
                        ? 'Edit MRP / Re-pack'
                        : 'Pack & Price'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _dispatchOrder(context, ref),
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Dispatch Order'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Edit (blocked once dispatched) ───────────────────────
                if (locked)
                  Card(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                'This order is dispatched and can no longer be edited.'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => context.push('/orders/edit/$orderId'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Order'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),

                // ── Delete (Admin only) ──────────────────────────────────
                if (userRole == 'Admin') ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _deleteOrder(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.summary});

  final dynamic summary; // OrderSummary

  @override
  Widget build(BuildContext context) {
    final style = orderStatusStyle(summary.status as String);
    return Card(
      color: style.color.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(style.icon, color: style.color.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${style.label}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: style.color.shade800,
                    ),
                  ),
                  if (summary.dispatchDate != null)
                    Text(
                      'Dispatched on: ${formatDate(summary.dispatchDate as DateTime?)}',
                      style:
                          TextStyle(fontSize: 12, color: style.color.shade700),
                    ),
                  if (summary.userName != null)
                    Text(
                      'Created by: ${summary.userName}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
