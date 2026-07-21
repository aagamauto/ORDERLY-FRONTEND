import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/visit_model.dart';
import '../../providers/visit_provider.dart';
import '../../services/api_service.dart';
import '../../services/offline_queue.dart';
import '../../utils/constants.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

class VisitPlannerScreen extends ConsumerStatefulWidget {
  const VisitPlannerScreen({super.key});

  @override
  ConsumerState<VisitPlannerScreen> createState() => _VisitPlannerScreenState();
}

class _VisitPlannerScreenState extends ConsumerState<VisitPlannerScreen> {
  String _shop = kShopNameOptions.first;
  final Set<String> _cities = {};
  bool _show = false;
  final Set<int> _visited = {}; // optimistic "Visited ✓" set

  String get _citiesCsv {
    final list = _cities.toList()..sort();
    return list.join(',');
  }

  Future<void> _openCityPicker() async {
    List<String> all;
    try {
      all = await ref.read(visitCitiesProvider(_shop).future);
    } catch (_) {
      all = const [];
    }
    if (!mounted) return;
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CityPickerSheet(all: all, initial: _cities),
    );
    if (result != null) {
      setState(() {
        _cities
          ..clear()
          ..addAll(result);
        _show = false;
      });
    }
  }

  Future<void> _markVisit(int custId, String outcome, String? note) async {
    final messenger = ScaffoldMessenger.of(context);
    final payload = <String, dynamic>{
      'cust_id': custId,
      'outcome': outcome,
      if (note != null && note.trim().isNotEmpty) 'notes': note.trim(),
    };
    try {
      if (!await OfflineQueue.instance.isOnline()) {
        await OfflineQueue.instance.enqueueVisit(payload);
        messenger.showSnackBar(
          const SnackBar(content: Text('Saved — will sync when online')),
        );
      } else {
        await DioClient.instance.dio.post('/CRM/Visits/', data: payload);
        messenger.showSnackBar(const SnackBar(content: Text('Visit marked')));
      }
      setState(() => _visited.add(custId));
      ref.invalidate(visitPlanProvider(_shop, _citiesCsv));
    } on DioException catch (e) {
      // Network error mid-request → queue it so it isn't lost on tour.
      if (e.response == null) {
        await OfflineQueue.instance.enqueueVisit(payload);
        setState(() => _visited.add(custId));
        messenger.showSnackBar(
          const SnackBar(content: Text('Saved — will sync when online')),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(extractApiError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Planner')),
      body: CenteredConstrained(
        maxWidth: kContentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _selector(context),
            const Divider(height: 1),
            Expanded(
              child: (!_show || _cities.isEmpty)
                  ? _hint(context)
                  : _planBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<String>(
            segments: [
              for (final s in kShopNameOptions)
                ButtonSegment(value: s, label: Text(s)),
            ],
            selected: {_shop},
            onSelectionChanged: (sel) => setState(() {
              _shop = sel.first;
              _cities.clear();
              _show = false;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _cities.isEmpty
                      ? [
                          Text('No cities selected',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                        ]
                      : _cities
                          .map((c) => Chip(
                                label: Text(c),
                                onDeleted: () => setState(() {
                                  _cities.remove(c);
                                  _show = false;
                                }),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                ),
              ),
              TextButton.icon(
                onPressed: _openCityPicker,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Cities'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _cities.isEmpty ? null : () => setState(() => _show = true),
              icon: const Icon(Icons.route_outlined),
              label: const Text("Show today's plan"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hint(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_search_outlined,
                  size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'Pick a business and the cities you\'ll cover, then show the plan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );

  Widget _planBody(BuildContext context) {
    final async = ref.watch(visitPlanProvider(_shop, _citiesCsv));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(extractApiError(err), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(visitPlanProvider(_shop, _citiesCsv)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text('No visits due in these cities',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: list.length,
          itemBuilder: (context, i) => _VisitCard(
            candidate: list[i],
            visited: _visited.contains(list[i].custId),
            onMark: (outcome, note) =>
                _markVisit(list[i].custId, outcome, note),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.candidate,
    required this.visited,
    required this.onMark,
  });

  final VisitCandidate candidate;
  final bool visited;
  final Future<void> Function(String outcome, String? note) onMark;

  Future<void> _openMarkSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MarkVisitSheet(name: candidate.name, onMark: onMark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    candidate.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (candidate.isNew)
                  Chip(
                    label: const Text('NEW', style: TextStyle(fontSize: 10)),
                    backgroundColor: scheme.tertiaryContainer,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (candidate.city != null && candidate.city!.isNotEmpty)
              Text(candidate.city!,
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 15, color: scheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(candidate.reason,
                      style: TextStyle(
                          fontSize: 12.5, color: scheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (candidate.categories.reorderDue.isNotEmpty ||
                candidate.categories.crossSell.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in candidate.categories.reorderDue)
                    _catChip(c, true, scheme),
                  for (final c in candidate.categories.crossSell)
                    _catChip(c, false, scheme),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: visited
                  ? Chip(
                      avatar: Icon(Icons.check_circle,
                          size: 16, color: scheme.primary),
                      label: const Text('Visited'),
                      visualDensity: VisualDensity.compact,
                    )
                  : TextButton.icon(
                      onPressed: () => _openMarkSheet(context),
                      icon: const Icon(Icons.how_to_reg_outlined),
                      label: const Text('Mark Visit'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catChip(String label, bool reorder, ColorScheme scheme) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11.5)),
      backgroundColor:
          reorder ? Colors.orange.shade100 : scheme.primaryContainer,
      labelStyle: TextStyle(
          color: reorder ? Colors.orange.shade900 : scheme.onPrimaryContainer),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

// ---------------------------------------------------------------------------
class _MarkVisitSheet extends StatefulWidget {
  const _MarkVisitSheet({required this.name, required this.onMark});

  final String name;
  final Future<void> Function(String outcome, String? note) onMark;

  @override
  State<_MarkVisitSheet> createState() => _MarkVisitSheetState();
}

class _MarkVisitSheetState extends State<_MarkVisitSheet> {
  String _outcome = kVisitNoOrder;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  static const _options = <String, String>{
    kVisitOrdered: 'Ordered',
    kVisitNoOrder: 'No order',
    kVisitNotAvailable: 'Not available',
    kVisitClosed: 'Closed',
  };

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Visit — ${widget.name}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final e in _options.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _outcome == e.key,
                  onSelected: (_) => setState(() => _outcome = e.key),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    await widget.onMark(_outcome, _noteCtrl.text);
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({required this.all, required this.initial});

  final List<String> all;
  final Set<String> initial;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  late final Set<String> _sel = Set<String>.from(widget.initial);
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.all
        .where((c) => c.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Search cities',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            if (widget.all.isEmpty)
              const Expanded(
                child: Center(child: Text('No cities for this business')),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    for (final c in filtered)
                      CheckboxListTile(
                        dense: true,
                        value: _sel.contains(c),
                        title: Text(c),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _sel.add(c);
                          } else {
                            _sel.remove(c);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(_sel.clear),
                      child: const Text('Clear'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_sel),
                      child: Text('Use ${_sel.length} cities'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
