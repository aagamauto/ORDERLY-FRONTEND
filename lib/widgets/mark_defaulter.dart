import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/customer_provider.dart';
import '../providers/order_provider.dart';
import '../services/api_service.dart';
import '../utils/format_utils.dart';

/// Bottom sheet to flag / unflag a customer as a defaulter (any user).
/// Returns the new is_defaulter value, or null if dismissed. Invalidates the
/// customer providers so badges update everywhere.
Future<bool?> showMarkDefaulterSheet(
  BuildContext context,
  WidgetRef ref, {
  required int custId,
  required String custName,
  required bool currentlyDefaulter,
  String? currentReason,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MarkDefaulterSheet(
      custId: custId,
      custName: custName,
      currentlyDefaulter: currentlyDefaulter,
      currentReason: currentReason,
      onDone: () {
        ref.invalidate(customerListProvider);
        ref.invalidate(defaulterListProvider);
        ref.invalidate(customerByIdProvider(custId));
        ref.invalidate(orderPreloadProvider);
      },
    ),
  );
}

class _MarkDefaulterSheet extends StatefulWidget {
  const _MarkDefaulterSheet({
    required this.custId,
    required this.custName,
    required this.currentlyDefaulter,
    required this.currentReason,
    required this.onDone,
  });

  final int custId;
  final String custName;
  final bool currentlyDefaulter;
  final String? currentReason;
  final VoidCallback onDone;

  @override
  State<_MarkDefaulterSheet> createState() => _MarkDefaulterSheetState();
}

class _MarkDefaulterSheetState extends State<_MarkDefaulterSheet> {
  late bool _isDefaulter = widget.currentlyDefaulter;
  late final TextEditingController _reason =
      TextEditingController(text: widget.currentReason ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DioClient.instance.dio.put(
        '/Customer/${widget.custId}/Defaulter',
        data: {
          'is_defaulter': _isDefaulter,
          if (_isDefaulter) 'reason': _reason.text.trim(),
        },
      );
      widget.onDone();
      if (mounted) {
        Navigator.of(context).pop(_isDefaulter);
        messenger.showSnackBar(SnackBar(
          content: Text(_isDefaulter
              ? 'Marked as defaulter'
              : 'Defaulter flag cleared'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } on DioException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractApiError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Defaulter — ${widget.custName}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mark as defaulter'),
            subtitle: const Text('Customer refuses / fails to pay'),
            value: _isDefaulter,
            activeThumbColor: scheme.error,
            onChanged: (v) => setState(() => _isDefaulter = v),
          ),
          if (_isDefaulter)
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: _isDefaulter ? scheme.error : null,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isDefaulter ? 'Save' : 'Clear flag'),
          ),
        ],
      ),
    );
  }
}
