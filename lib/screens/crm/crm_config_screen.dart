import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crm_model.dart';
import '../../providers/crm_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../../widgets/responsive.dart';

class CrmConfigScreen extends ConsumerStatefulWidget {
  const CrmConfigScreen({super.key});

  @override
  ConsumerState<CrmConfigScreen> createState() => _CrmConfigScreenState();
}

class _CrmConfigScreenState extends ConsumerState<CrmConfigScreen> {
  String? _shop;
  final _dailyCall = TextEditingController();
  final _defCycle = TextEditingController();
  final _maxCycle = TextEditingController();
  final _wVol = TextEditingController();
  final _wPay = TextEditingController();
  final _wOverdue = TextEditingController();
  final _crossSell = TextEditingController();
  bool _saving = false;

  List<TextEditingController> get _all =>
      [_dailyCall, _defCycle, _maxCycle, _wVol, _wPay, _wOverdue, _crossSell];

  void _populate(CrmConfig c) {
    _shop = c.shop;
    _dailyCall.text = '${c.dailyCallTarget}';
    _defCycle.text = '${c.defaultReorderCycleDays}';
    _maxCycle.text = '${c.maxReorderCycleDays}';
    _wVol.text = '${c.weightMVolume}';
    _wPay.text = '${c.weightMPayment}';
    _wOverdue.text = '${c.weightOverdue}';
    _crossSell.text = '${c.crossSellLimit}';
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_shop == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final body = <String, dynamic>{
      'daily_call_target': int.tryParse(_dailyCall.text) ?? 40,
      'default_reorder_cycle_days': int.tryParse(_defCycle.text) ?? 30,
      'max_reorder_cycle_days': int.tryParse(_maxCycle.text) ?? 90,
      'weight_m_volume': double.tryParse(_wVol.text) ?? 0.5,
      'weight_m_payment': double.tryParse(_wPay.text) ?? 0.5,
      'weight_overdue': double.tryParse(_wOverdue.text) ?? 2.0,
      'cross_sell_limit': int.tryParse(_crossSell.text) ?? 3,
    };
    try {
      await DioClient.instance.dio.put('/CRM/Config/$_shop', data: body);
      ref.invalidate(crmConfigListProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Settings saved')));
    } on DioException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractApiError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(crmConfigListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('CRM Settings')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(extractApiError(err), textAlign: TextAlign.center),
          ),
        ),
        data: (configs) {
          if (configs.isEmpty) {
            return const Center(child: Text('No config found'));
          }
          if (_shop == null) _populate(configs.first);
          return CenteredConstrained(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    segments: [
                      for (final c in configs)
                        ButtonSegment(value: c.shop, label: Text(c.shop)),
                    ],
                    selected: {_shop ?? configs.first.shop},
                    onSelectionChanged: (sel) {
                      final c =
                          configs.firstWhere((e) => e.shop == sel.first);
                      setState(() => _populate(c));
                    },
                  ),
                  const SizedBox(height: 16),
                  _numField(_dailyCall, 'Daily call target'),
                  _numField(_defCycle, 'Default reorder cycle (days)'),
                  _numField(_maxCycle, 'Max reorder cycle cap (days)'),
                  _numField(_crossSell, 'Cross-sell suggestions per customer'),
                  const SizedBox(height: 8),
                  Text('Customer value weighting',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _numField(_wVol, 'Weight — order volume', decimal: true),
                  _numField(_wPay, 'Weight — payments collected',
                      decimal: true),
                  _numField(_wOverdue, 'Weight — overdue reorder',
                      decimal: true),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _numField(TextEditingController c, String label,
      {bool decimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: decimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
