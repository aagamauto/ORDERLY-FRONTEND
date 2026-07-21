import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/crm_provider.dart';
import '../../utils/constants.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

class CrmDashboardScreen extends ConsumerStatefulWidget {
  const CrmDashboardScreen({super.key});

  @override
  ConsumerState<CrmDashboardScreen> createState() => _CrmDashboardScreenState();
}

class _CrmDashboardScreenState extends ConsumerState<CrmDashboardScreen> {
  String _shop = kShopNameOptions.first;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(crmAnalyticsProvider(_shop));
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Settings',
            onPressed: () => context.push('/crm/config'),
          ),
        ],
      ),
      body: CenteredConstrained(
        maxWidth: kContentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<String>(
                segments: [
                  for (final s in kShopNameOptions)
                    ButtonSegment(value: s, label: Text(s)),
                ],
                selected: {_shop},
                onSelectionChanged: (sel) => setState(() => _shop = sel.first),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child:
                        Text(extractApiError(err), textAlign: TextAlign.center),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No data yet'));
                  }
                  final a = list.first;
                  final tiles = <Widget>[
                    _tile(context, Icons.directions_walk,
                        '${a.visitsLast30d}', 'Visits (30d)'),
                    _tile(context, Icons.shopping_bag_outlined,
                        '${a.visitConversionPct}%', 'Visit → order'),
                    _tile(context, Icons.call_outlined, '${a.callsLast30d}',
                        'Calls (30d)'),
                    _tile(context, Icons.check_circle_outline,
                        '${a.callConversionPct}%', 'Call → order'),
                    _tile(context, Icons.schedule_outlined,
                        '${a.overdueCustomers}', 'Overdue reorders'),
                    _tile(context, Icons.today_outlined, '${a.dueTodayCalls}',
                        'Calls due today'),
                    _tile(context, Icons.person_off_outlined,
                        '${a.neverOrderedCustomers}', 'Never ordered'),
                  ];
                  return GridView(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    children: tiles,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext context, IconData icon, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
