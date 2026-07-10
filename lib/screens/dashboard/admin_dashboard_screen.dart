import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dashboard_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/format_utils.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Dashboard')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 8),
                Text(
                  extractApiError(e),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(onPressed: () => ref.invalidate(adminDashboardProvider), child: const Text('Retry')),
              ]),
            ),
          ),
        ),
        data: (dashboard) => _DashboardBody(dashboard: dashboard),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.dashboard});
  final AdminDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(label: 'Total Users', value: dashboard.totalUsers, icon: Icons.people),
        _StatCard(label: 'Total Customers', value: dashboard.totalCustomers, icon: Icons.store),
        _StatCard(label: 'Total Orders', value: dashboard.totalSystemOrders, icon: Icons.receipt_long),
        _StatCard(label: 'Total Revenue', value: formatAmount(dashboard.totalSystemRevenue), icon: Icons.currency_rupee),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final Object value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$value',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}
