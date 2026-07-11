import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/format_utils.dart';
import '../../utils/order_status.dart';

/// The Employee/Admin work screen: orders still needing action, oldest first.
class DispatchQueueScreen extends ConsumerWidget {
  const DispatchQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(dispatchQueueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dispatch Queue')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dispatchQueueProvider),
        child: queueAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    extractApiError(err),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(dispatchQueueProvider),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Nothing waiting to dispatch.')),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: orders.length,
              itemBuilder: (context, i) => _QueueCard(order: orders[i]),
            );
          },
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.order});

  final QueueOrder order;

  int get _waitingDays {
    if (order.createDate == null) return 0;
    return DateTime.now().difference(order.createDate!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final style = orderStatusStyle(order.status);
    final waiting = _waitingDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/orders/pack/${order.ordId}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: style.color.shade100,
                child: Icon(style.icon, color: style.color.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.name.isNotEmpty ? order.name : order.shop,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      order.shop,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order #${order.ordId}  •  Qty ${order.totalQuantity}  •  by ${order.userName.isNotEmpty ? order.userName : 'Unknown'}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 4),
                  Text(
                    waiting <= 0 ? 'today' : '${waiting}d waiting',
                    style: TextStyle(
                      fontSize: 11,
                      color: waiting >= 2
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight:
                          waiting >= 2 ? FontWeight.bold : FontWeight.normal,
                    ),
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
