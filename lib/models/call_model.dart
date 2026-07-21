// Follow-up call statuses — MUST match the backend db_models CALL_* constants.
const String kCallInterested = 'interested';
const String kCallNoAnswer = 'no_answer';
const String kCallOrdered = 'ordered';
const String kCallCallback = 'callback';
const String kCallNotInterested = 'not_interested';

/// A customer recommended for a follow-up call today.
/// Returned by GET /CRM/Calls/Today/
class CallCandidate {
  const CallCandidate({
    required this.custId,
    required this.name,
    this.contact,
    this.city,
    required this.reason,
    this.lastCallDate,
    this.lastOrderDate,
    this.overdueRatio,
    required this.callPriority,
  });

  final int custId;
  final String name;
  final String? contact;
  final String? city;
  final String reason; // callback | post_visit_no_order | overdue | credit_pending
  final DateTime? lastCallDate;
  final DateTime? lastOrderDate;
  final double? overdueRatio;
  final double callPriority;

  factory CallCandidate.fromJson(Map<String, dynamic> j) => CallCandidate(
        custId: (j['cust_id'] as int?) ?? 0,
        name: (j['name'] as String?) ?? '',
        contact: j['contact'] as String?,
        city: j['city'] as String?,
        reason: (j['reason'] as String?) ?? '',
        lastCallDate: j['last_call_date'] != null
            ? DateTime.parse(j['last_call_date'] as String)
            : null,
        lastOrderDate: j['last_order_date'] != null
            ? DateTime.parse(j['last_order_date'] as String)
            : null,
        overdueRatio: (j['overdue_ratio'] as num?)?.toDouble(),
        callPriority: (j['call_priority'] as num?)?.toDouble() ?? 0,
      );
}
