import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_provider.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _query = '';

  Color _roleColor(String role, BuildContext context) {
    return switch (role) {
      'Admin' => Theme.of(context).colorScheme.errorContainer,
      'Employee' => Theme.of(context).colorScheme.secondaryContainer,
      _ => Theme.of(context).colorScheme.tertiaryContainer,
    };
  }

  Color _roleTextColor(String role, BuildContext context) {
    return switch (role) {
      'Admin' => Theme.of(context).colorScheme.onErrorContainer,
      'Employee' => Theme.of(context).colorScheme.onSecondaryContainer,
      _ => Theme.of(context).colorScheme.onTertiaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Users')),
      body: SafeArea(
        child: CenteredConstrained(
          maxWidth: kContentMaxWidth,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _query = ''))
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: asyncUsers.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 8),
                      Text(extractApiError(e)),
                      TextButton(onPressed: () => ref.invalidate(userListProvider), child: const Text('Retry')),
                    ]),
                  ),
                  data: (users) {
                    final filtered = _query.isEmpty
                        ? users
                        : users.where((u) =>
                            u.name.toLowerCase().contains(_query) ||
                            u.email.toLowerCase().contains(_query)).toList();

                    if (filtered.isEmpty) return const Center(child: Text('No users found.'));

                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(userListProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final user = filtered[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Chip(
                                label: Text(user.role),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: _roleTextColor(user.role, context),
                                ),
                                backgroundColor: _roleColor(user.role, context),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
