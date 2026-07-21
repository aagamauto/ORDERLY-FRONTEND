import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/call_model.dart';
import '../../providers/call_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/dialer.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

const Map<String, String> _reasonLabels = {
  'callback': 'Callback due',
  'post_visit_no_order': 'Visited, no order',
  'overdue': 'Overdue reorder',
  'credit_pending': 'Payment pending',
};

class FollowUpCallsScreen extends ConsumerStatefulWidget {
  const FollowUpCallsScreen({super.key});

  @override
  ConsumerState<FollowUpCallsScreen> createState() =>
      _FollowUpCallsScreenState();
}

class _FollowUpCallsScreenState extends ConsumerState<FollowUpCallsScreen> {
  String _shop = kShopNameOptions.first;

  Future<void> _logCall(
      int custId, String status, DateTime? callback, String? note) async {
    final messenger = ScaffoldMessenger.of(context);
    final payload = <String, dynamic>{
      'cust_id': custId,
      'status': status,
      if (callback != null)
        'next_call_date': callback.toIso8601String().substring(0, 10),
      if (note != null && note.trim().isNotEmpty) 'notes': note.trim(),
    };
    try {
      await DioClient.instance.dio.post('/CRM/Calls/', data: payload);
      messenger.showSnackBar(const SnackBar(content: Text('Call logged')));
      ref.invalidate(callTodayProvider(_shop));
    } on DioException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractApiError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(callTodayProvider(_shop));
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-up Calls')),
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
            const Divider(height: 1),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(extractApiError(err),
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(callTodayProvider(_shop)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No follow-up calls due today',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(callTodayProvider(_shop)),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _CallCard(
                        candidate: list[i],
                        onCall: () => dialNumber(context, list[i].contact ?? ''),
                        onLog: (status, callback, note) =>
                            _logCall(list[i].custId, status, callback, note),
                        onOpen: () =>
                            context.push('/customers/${list[i].custId}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _CallCard extends StatelessWidget {
  const _CallCard({
    required this.candidate,
    required this.onCall,
    required this.onLog,
    required this.onOpen,
  });

  final CallCandidate candidate;
  final VoidCallback onCall;
  final VoidCallback onOpen;
  final Future<void> Function(String status, DateTime? callback, String? note)
      onLog;

  Future<void> _openLogSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LogCallSheet(name: candidate.name, onLog: onLog),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final meta = <String>[
      if (candidate.city != null && candidate.city!.isNotEmpty) candidate.city!,
      candidate.lastCallDate != null
          ? 'last called ${formatDate(candidate.lastCallDate)}'
          : 'never called',
    ].join('  •  ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onOpen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(meta,
                            style: TextStyle(
                                fontSize: 12.5, color: scheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: onCall,
                  icon: const Icon(Icons.call),
                  tooltip: 'Call ${candidate.name}',
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Chip(
                  label: Text(
                    _reasonLabels[candidate.reason] ?? candidate.reason,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: scheme.secondaryContainer,
                  labelStyle: TextStyle(color: scheme.onSecondaryContainer),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openLogSheet(context),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Log Call'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _LogCallSheet extends StatefulWidget {
  const _LogCallSheet({required this.name, required this.onLog});

  final String name;
  final Future<void> Function(String status, DateTime? callback, String? note)
      onLog;

  @override
  State<_LogCallSheet> createState() => _LogCallSheetState();
}

class _LogCallSheetState extends State<_LogCallSheet> {
  String _status = kCallInterested;
  DateTime? _callback;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  static const _options = <String, String>{
    kCallInterested: 'Interested',
    kCallNoAnswer: 'No answer',
    kCallOrdered: 'Ordered',
    kCallCallback: 'Callback',
    kCallNotInterested: 'Not interested',
  };

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCallback() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _callback = picked);
  }

  @override
  Widget build(BuildContext context) {
    final showCallback = _status == kCallCallback;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Log call — ${widget.name}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in _options.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _status == e.key,
                  onSelected: (_) => setState(() => _status = e.key),
                ),
            ],
          ),
          if (showCallback) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickCallback,
              icon: const Icon(Icons.event_outlined),
              label: Text(_callback == null
                  ? 'Pick callback date'
                  : 'Callback: ${formatDate(_callback)}'),
            ),
          ],
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
                    await widget.onLog(
                        _status, showCallback ? _callback : null, _noteCtrl.text);
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
