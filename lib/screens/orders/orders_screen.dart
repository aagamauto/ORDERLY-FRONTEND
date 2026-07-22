import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../../utils/order_status.dart';
import '../../widgets/defaulter_badge.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.mineOnly = false});

  final bool mineOnly;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _chipFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _normalize(String s) =>
      s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

  List<OrderSummary> _applyFilters(List<OrderSummary> orders) {
    List<OrderSummary> filtered = List.of(orders);

    final q = _normalize(_searchQuery);
    if (q.isNotEmpty) {
      filtered = filtered
          .where((o) => _normalize(o.name).contains(q) || _normalize(o.shop).contains(q))
          .toList();
    }

    if (_chipFilter == 'Ordered') {
      filtered =
          filtered.where((o) => !o.isDispatched && !o.isPacked).toList();
    } else if (_chipFilter == 'Packed') {
      filtered = filtered.where((o) => o.isPacked).toList();
    } else if (_chipFilter == 'Dispatched') {
      filtered = filtered.where((o) => o.isDispatched).toList();
    }

    // Orders still needing action first.
    filtered.sort((a, b) =>
        a.isDispatched == b.isDispatched ? 0 : (a.isDispatched ? 1 : -1));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userRoleProvider);
    final ordersAsync = widget.mineOnly
        ? ref.watch(myOrderListProvider)
        : ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mineOnly ? 'My Orders' : 'Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by customer name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Ordered', 'Packed', 'Dispatched'].map((label) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(label),
                      selected: _chipFilter == label,
                      onSelected: (_) {
                        setState(() => _chipFilter = label);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create New Order'),
                onPressed: () => context.push('/orders/create'),
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
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
                      onPressed: () => widget.mineOnly
                          ? ref.invalidate(myOrderListProvider)
                          : ref.invalidate(orderListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                final filtered = _applyFilters(orders);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _OrderCard(
                      key: ValueKey(order.ordId),
                      order: order,
                      userRole: userRole,
                      onTap: () => context.push('/orders/${order.ordId}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({
    super.key,
    required this.order,
    required this.userRole,
    required this.onTap,
  });

  final OrderSummary order;
  final String? userRole;
  final VoidCallback onTap;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _dispatching = false;
  bool _justDispatched = false;

  Future<void> _dispatch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispatch Order'),
        content:
            Text('Are you sure you want to dispatch Order #${widget.order.ordId}?'),
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
      await DioClient.instance.dio
          .put('/Orders/${widget.order.ordId}/dispatch/');
      setState(() => _justDispatched = true);
      ref.invalidate(orderListProvider);
      ref.invalidate(myOrderListProvider);
      ref.invalidate(dispatchQueueProvider);
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['detail'] as String? ?? 'Error'),
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
    final order = widget.order;
    final isStaff =
        widget.userRole == 'Admin' || widget.userRole == 'Employee';
    final dispatched = _justDispatched || order.isDispatched;
    final style =
        orderStatusStyle(dispatched ? kStatusDispatched : order.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  order.customerFirstName.isNotEmpty
                      ? order.customerFirstName[0].toUpperCase()
                      : '?',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            order.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (order.isDefaulter) ...[
                          const SizedBox(width: 6),
                          const DefaulterBadge(compact: true),
                        ],
                      ],
                    ),
                    Text(
                      order.shop,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.formattedCreateDate}   Qty: ${order.totalQuantity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    label:
                        Text(style.label, style: const TextStyle(fontSize: 11)),
                    backgroundColor: style.color.shade100,
                    side: BorderSide(color: style.color),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (isStaff && !dispatched)
                    _dispatching
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : order.isPacked
                            ? TextButton.icon(
                                onPressed: _dispatch,
                                icon: const Icon(
                                    Icons.local_shipping_outlined,
                                    size: 18),
                                label: const Text('Dispatch'),
                              )
                            : TextButton.icon(
                                onPressed: () => context
                                    .push('/orders/pack/${order.ordId}'),
                                icon: const Icon(Icons.inventory_2_outlined,
                                    size: 18),
                                label: const Text('Pack'),
                              ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
