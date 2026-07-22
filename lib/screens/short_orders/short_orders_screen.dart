import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/pending_model.dart';
import '../../providers/shortfall_provider.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

class ShortOrdersScreen extends ConsumerWidget {
  const ShortOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Short Orders'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Pending'), Tab(text: 'Product analysis')],
          ),
        ),
        body: const TabBarView(children: [_PendingTab(), _AnalysisTab()]),
      ),
    );
  }
}

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allPendingShortsProvider);
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(allPendingShortsProvider),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(children: [
          const SizedBox(height: 80),
          Center(child: Text(extractApiError(err))),
        ]),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: [
              const SizedBox(height: 120),
              Center(
                  child: Text('No pending shorts.',
                      style: TextStyle(color: scheme.onSurfaceVariant))),
            ]);
          }
          final byCust = <int, List<PendingShort>>{};
          for (final p in list) {
            byCust.putIfAbsent(p.custId, () => []).add(p);
          }
          final custIds = byCust.keys.toList();
          return CenteredConstrained(
            maxWidth: kContentMaxWidth,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: custIds.length,
              itemBuilder: (context, i) {
                final items = byCust[custIds[i]]!;
                final first = items.first;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () =>
                              context.push('/customers/${first.custId}'),
                          child: Text(
                            '${first.custName ?? 'Customer'}  •  ${first.shop ?? ''}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...items.map((p) => Text('•  ${p.pname} — short ${p.shortQty}',
                            style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant))),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnalysisTab extends ConsumerWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(shortfallAnalyticsProvider);
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(shortfallAnalyticsProvider),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(children: [
          const SizedBox(height: 80),
          Center(child: Text(extractApiError(err))),
        ]),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: [
              const SizedBox(height: 120),
              Center(
                  child: Text('No short history yet.',
                      style: TextStyle(color: scheme.onSurfaceVariant))),
            ]);
          }
          return CenteredConstrained(
            maxWidth: kContentMaxWidth,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(p.pname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        if (p.isRecurring) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('RECURRING',
                                style: TextStyle(
                                    color: scheme.onErrorContainer,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                        'Short ${p.timesShort}×  •  ${p.totalShortQty} units  •  '
                        '${p.customersAffected} customers  •  ${p.pendingQty} pending'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
