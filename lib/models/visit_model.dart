// Visit outcomes — MUST match the backend db_models VISIT_* constants.
const String kVisitOrdered = 'ordered';
const String kVisitNoOrder = 'no_order';
const String kVisitNotAvailable = 'not_available';
const String kVisitClosed = 'closed';

/// Category pitch suggestions for a customer.
class CategorySuggestions {
  const CategorySuggestions({
    this.reorderDue = const [],
    this.crossSell = const [],
  });

  final List<String> reorderDue; // bought before, now overdue
  final List<String> crossSell; // popular in the business, never bought

  factory CategorySuggestions.fromJson(Map<String, dynamic> j) =>
      CategorySuggestions(
        reorderDue:
            (j['reorder_due'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        crossSell:
            (j['cross_sell'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
      );
}

/// A recommended customer to visit, with a "why" reason + category suggestions.
/// Returned by GET /CRM/Visits/Recommendations/
class VisitCandidate {
  const VisitCandidate({
    required this.custId,
    required this.name,
    this.city,
    this.contact,
    this.recencyDays,
    required this.effectiveCycleDays,
    this.overdueRatio,
    required this.rfmComposite,
    required this.isNew,
    this.lastOrderDate,
    required this.visitScore,
    required this.reason,
    required this.categories,
  });

  final int custId;
  final String name;
  final String? city;
  final String? contact;
  final int? recencyDays;
  final int effectiveCycleDays;
  final double? overdueRatio;
  final double rfmComposite;
  final bool isNew;
  final DateTime? lastOrderDate;
  final double visitScore;
  final String reason;
  final CategorySuggestions categories;

  factory VisitCandidate.fromJson(Map<String, dynamic> j) => VisitCandidate(
        custId: (j['cust_id'] as int?) ?? 0,
        name: (j['name'] as String?) ?? '',
        city: j['city'] as String?,
        contact: j['contact'] as String?,
        recencyDays: (j['recency_days'] as num?)?.toInt(),
        effectiveCycleDays: (j['effective_cycle_days'] as num?)?.toInt() ?? 0,
        overdueRatio: (j['overdue_ratio'] as num?)?.toDouble(),
        rfmComposite: (j['rfm_composite'] as num?)?.toDouble() ?? 0,
        isNew: (j['is_new'] as bool?) ?? false,
        lastOrderDate: j['last_order_date'] != null
            ? DateTime.parse(j['last_order_date'] as String)
            : null,
        visitScore: (j['visit_score'] as num?)?.toDouble() ?? 0,
        reason: (j['reason'] as String?) ?? '',
        categories: j['categories'] != null
            ? CategorySuggestions.fromJson(
                j['categories'] as Map<String, dynamic>)
            : const CategorySuggestions(),
      );
}
