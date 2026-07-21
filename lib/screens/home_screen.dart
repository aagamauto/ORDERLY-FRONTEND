import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/offline_queue.dart';

Widget _navCard(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String route,
}) {
  return Card(
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider) ?? 'there';
    final userRole = ref.watch(userRoleProvider);

    final tiles = <Widget>[
      _navCard(context,
          icon: Icons.receipt_long_outlined,
          label: 'Orders',
          route: '/orders'),
      _navCard(context,
          icon: Icons.people_outline,
          label: 'Customers',
          route: '/customers'),
      _navCard(context,
          icon: Icons.payments_outlined,
          label: 'Payments',
          route: '/payments'),
      _navCard(context,
          icon: Icons.inventory_2_outlined,
          label: 'Products',
          route: '/products'),
      _navCard(context,
          icon: Icons.menu_book_outlined,
          label: 'Catalogues',
          route: '/catalogues'),
      if (userRole == 'Admin' || userRole == 'Employee')
        _navCard(context,
            icon: Icons.local_shipping_outlined,
            label: 'Dispatch Queue',
            route: '/dispatch/queue'),
      if (userRole == 'Admin') ...[
        _navCard(context,
            icon: Icons.person_add_outlined,
            label: 'Create User',
            route: '/profile/create-user'),
        _navCard(context,
            icon: Icons.dashboard_outlined,
            label: 'Global Dashboard',
            route: '/dashboard/admin'),
        _navCard(context,
            icon: Icons.insights_outlined,
            label: 'CRM Analytics',
            route: '/crm'),
      ],
      if (userRole == 'Salesman' || userRole == 'Admin')
        _navCard(context,
            icon: Icons.map_outlined,
            label: 'Visit Planner',
            route: '/visits/planner'),
      if (userRole == 'Admin' || userRole == 'Employee')
        _navCard(context,
            icon: Icons.call_outlined,
            label: 'Follow-up Calls',
            route: '/calls/today'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi, $userName!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Shows how many offline orders are waiting to sync.
          ValueListenableBuilder<int>(
            valueListenable: OfflineQueue.instance.pendingCount,
            builder: (context, count, _) {
              if (count == 0) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Tooltip(
                    message: '$count order(s) waiting to sync',
                    child: Chip(
                      avatar: const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: Text('$count'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: GridView(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          padding: const EdgeInsets.all(16),
          children: tiles,
        ),
      ),
    );
  }
}
