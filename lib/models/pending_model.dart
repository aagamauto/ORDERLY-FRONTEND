/// A customer's pending "short" item (back-order from a partial dispatch).
/// GET /Shortfalls/Customer/{id}/ and GET /Shortfalls/Pending/ (latter adds customer).
class PendingShort {
  const PendingShort({
    required this.id,
    required this.custId,
    this.custName,
    this.shop,
    required this.pid,
    required this.pname,
    this.category,
    required this.shortQty,
    this.dispatchDate,
    required this.ordId,
  });

  final int id;
  final int custId;
  final String? custName;
  final String? shop;
  final int pid;
  final String pname;
  final String? category;
  final int shortQty;
  final DateTime? dispatchDate;
  final int ordId;

  factory PendingShort.fromJson(Map<String, dynamic> j) => PendingShort(
        id: (j['id'] as int?) ?? 0,
        custId: (j['cust_id'] as int?) ?? 0,
        custName: j['cust_name'] as String?,
        shop: j['shop'] as String?,
        pid: (j['pid'] as int?) ?? 0,
        pname: (j['pname'] as String?) ?? '',
        category: j['category'] as String?,
        shortQty: (j['short_qty'] as int?) ?? 0,
        dispatchDate: j['dispatch_date'] != null
            ? DateTime.parse(j['dispatch_date'] as String)
            : null,
        ordId: (j['ord_id'] as int?) ?? 0,
      );
}

/// Per-product short analytics — GET /Shortfalls/Analytics/
class ShortProduct {
  const ShortProduct({
    required this.pid,
    required this.pname,
    this.category,
    required this.timesShort,
    required this.totalShortQty,
    required this.customersAffected,
    required this.pendingQty,
    required this.isRecurring,
  });

  final int pid;
  final String pname;
  final String? category;
  final int timesShort;
  final int totalShortQty;
  final int customersAffected;
  final int pendingQty;
  final bool isRecurring;

  factory ShortProduct.fromJson(Map<String, dynamic> j) => ShortProduct(
        pid: (j['pid'] as int?) ?? 0,
        pname: (j['pname'] as String?) ?? '',
        category: j['category'] as String?,
        timesShort: (j['times_short'] as int?) ?? 0,
        totalShortQty: (j['total_short_qty'] as int?) ?? 0,
        customersAffected: (j['customers_affected'] as int?) ?? 0,
        pendingQty: (j['pending_qty'] as int?) ?? 0,
        isRecurring: (j['is_recurring'] as bool?) ?? false,
      );
}
