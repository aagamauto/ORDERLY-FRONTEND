/// Per-business CRM analytics — returned by GET /CRM/Analytics/
class CrmAnalytics {
  const CrmAnalytics({
    required this.shop,
    required this.visitsLast30d,
    required this.visitConversionPct,
    required this.callsLast30d,
    required this.callConversionPct,
    required this.overdueCustomers,
    required this.neverOrderedCustomers,
    required this.dueTodayCalls,
  });

  final String shop;
  final int visitsLast30d;
  final double visitConversionPct;
  final int callsLast30d;
  final double callConversionPct;
  final int overdueCustomers;
  final int neverOrderedCustomers;
  final int dueTodayCalls;

  factory CrmAnalytics.fromJson(Map<String, dynamic> j) => CrmAnalytics(
        shop: (j['shop'] as String?) ?? '',
        visitsLast30d: (j['visits_last_30d'] as num?)?.toInt() ?? 0,
        visitConversionPct:
            (j['visit_conversion_pct'] as num?)?.toDouble() ?? 0,
        callsLast30d: (j['calls_last_30d'] as num?)?.toInt() ?? 0,
        callConversionPct: (j['call_conversion_pct'] as num?)?.toDouble() ?? 0,
        overdueCustomers: (j['overdue_customers'] as num?)?.toInt() ?? 0,
        neverOrderedCustomers:
            (j['never_ordered_customers'] as num?)?.toInt() ?? 0,
        dueTodayCalls: (j['due_today_calls'] as num?)?.toInt() ?? 0,
      );
}

/// Per-business tunables — GET /CRM/Config/ (editable subset for the config screen).
class CrmConfig {
  const CrmConfig({
    required this.shop,
    required this.dailyCallTarget,
    required this.defaultReorderCycleDays,
    required this.maxReorderCycleDays,
    required this.weightMVolume,
    required this.weightMPayment,
    required this.weightOverdue,
    required this.crossSellLimit,
  });

  final String shop;
  final int dailyCallTarget;
  final int defaultReorderCycleDays;
  final int maxReorderCycleDays;
  final double weightMVolume;
  final double weightMPayment;
  final double weightOverdue;
  final int crossSellLimit;

  factory CrmConfig.fromJson(Map<String, dynamic> j) => CrmConfig(
        shop: (j['shop'] as String?) ?? '',
        dailyCallTarget: (j['daily_call_target'] as num?)?.toInt() ?? 40,
        defaultReorderCycleDays:
            (j['default_reorder_cycle_days'] as num?)?.toInt() ?? 30,
        maxReorderCycleDays:
            (j['max_reorder_cycle_days'] as num?)?.toInt() ?? 90,
        weightMVolume: (j['weight_m_volume'] as num?)?.toDouble() ?? 0.5,
        weightMPayment: (j['weight_m_payment'] as num?)?.toDouble() ?? 0.5,
        weightOverdue: (j['weight_overdue'] as num?)?.toDouble() ?? 2.0,
        crossSellLimit: (j['cross_sell_limit'] as num?)?.toInt() ?? 3,
      );

  /// Body for PUT /CRM/Config/{shop} (all fields set; backend ignores the rest).
  Map<String, dynamic> toJson() => {
        'daily_call_target': dailyCallTarget,
        'default_reorder_cycle_days': defaultReorderCycleDays,
        'max_reorder_cycle_days': maxReorderCycleDays,
        'weight_m_volume': weightMVolume,
        'weight_m_payment': weightMPayment,
        'weight_overdue': weightOverdue,
        'cross_sell_limit': crossSellLimit,
      };
}
