import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/customer_provider.dart';
import '../../utils/format_utils.dart';
import '../../widgets/defaulter_badge.dart';
import '../../widgets/responsive.dart';

class DefaultersScreen extends ConsumerWidget {
  const DefaultersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(defaulterListProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Defaulters')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(defaulterListProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(children: [
            const SizedBox(height: 80),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child:
                    Text(extractApiError(err), textAlign: TextAlign.center),
              ),
            ),
          ]),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: [
                const SizedBox(height: 120),
                Center(
                    child: Text('No defaulters flagged.',
                        style: TextStyle(color: scheme.onSurfaceVariant))),
              ]);
            }
            return CenteredConstrained(
              maxWidth: kContentMaxWidth,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  final hasReason = c.defaulterReason != null &&
                      c.defaulterReason!.isNotEmpty;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.money_off, color: scheme.error),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          const DefaulterBadge(compact: true),
                        ],
                      ),
                      subtitle: Text(
                        '${c.city} • ${c.shop}${hasReason ? '\n${c.defaulterReason}' : ''}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: hasReason,
                      onTap: () => context.push('/customers/${c.custId}'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
