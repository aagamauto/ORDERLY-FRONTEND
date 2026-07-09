import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).asData?.value;
    final userName = authState?.userName ?? 'User';
    final userRole = authState?.userRole ?? '';
    final isAdmin = userRole == 'Admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User info card
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                title: Text(userName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Chip(
                  label: Text(userRole),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            Card(
              child: Column(
                children: [
                  if (isAdmin) ...[
                    _ProfileTile(icon: Icons.receipt_long, label: 'All Orders', onTap: () => context.push('/orders')),
                    _ProfileTile(icon: Icons.people, label: 'All Customers', onTap: () => context.push('/customers')),
                    _ProfileTile(icon: Icons.payments, label: 'All Payments', onTap: () => context.push('/payments')),
                    _ProfileTile(icon: Icons.manage_accounts, label: 'All Staff Users', onTap: () => context.push('/admin/users')),
                    _ProfileTile(icon: Icons.person_add, label: 'Create User', onTap: () => context.push('/profile/create-user')),
                    _ProfileTile(icon: Icons.dashboard, label: 'Global Dashboard', onTap: () => context.push('/dashboard/admin')),
                  ] else ...[
                    _ProfileTile(icon: Icons.receipt, label: 'My Orders', onTap: () => context.push('/orders/mine')),
                    _ProfileTile(icon: Icons.payments, label: 'My Payments', onTap: () => context.push('/payments/mine')),
                    _ProfileTile(icon: Icons.analytics, label: 'My Dashboard', onTap: () => context.push('/dashboard/me')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 16)),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}
