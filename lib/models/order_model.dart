import 'customer_model.dart';
import 'payment_model.dart';
import 'product_model.dart';

String _fmt(DateTime? d) => d == null
    ? '-'
    : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

// ── OrderSummary ──────────────────────────────────────────────────────────────
/// Full order joined with customer data — returned by GET /Orders/
class OrderSummary {
  const OrderSummary({
    required this.ordId,
    required this.userId,
    required this.custId,
    this.createDate,
    required this.totalQuantity,
    required this.status,
    this.dispatchDate,
    required this.name,
    required this.city,
    required this.state,
    required this.contact,
    required this.shop,
    this.userName,
  });

  final int ordId;
  final int userId;
  final int custId;
  final DateTime? createDate;
  final int totalQuantity;
  final String status;
  final DateTime? dispatchDate;
  final String name; // customer full name
  final String city;
  final String state;
  final String contact;
  final String shop;
  final String? userName; // name of the staff user who created the order

  bool get isPending => dispatchDate == null;
  bool get isPacked => status == 'Packed';
  bool get isDispatched => dispatchDate != null;
  String get customerFirstName => name.split(' ').first;
  String get formattedCreateDate => _fmt(createDate);
  String get statusLabel =>
      status.isNotEmpty ? status : (isPending ? 'Ordered' : 'Dispatched');
  String get displayStatus => statusLabel;

  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(
        ordId: (j['ord_id'] as int?) ?? 0,
        userId: (j['user_id'] as int?) ?? 0,
        custId: (j['cust_id'] as int?) ?? 0,
        createDate: j['create_date'] != null
            ? DateTime.parse(j['create_date'] as String)
            : null,
        totalQuantity: (j['total_quantity'] as int?) ?? 0,
        status: (j['status'] as String?) ?? '',
        dispatchDate: j['dispatch_date'] != null
            ? DateTime.parse(j['dispatch_date'] as String)
            : null,
        name: (j['name'] as String?) ?? '',
        city: (j['city'] as String?) ?? '',
        state: (j['state'] as String?) ?? '',
        contact: (j['contact'] as String?) ?? '',
        shop: (j['shop'] as String?) ?? '',
        userName: j['user_name'] as String?,
      );
}

// ── CustomerOrderSummary ──────────────────────────────────────────────────────
/// Customer-scoped order — returned by GET /Customer/{id}/Orders/
class CustomerOrderSummary {
  const CustomerOrderSummary({
    required this.ordId,
    required this.custId,
    required this.userId,
    this.createDate,
    required this.totalQuantity,
    required this.status,
    this.dispatchDate,
    this.userName,
  });

  final int ordId;
  final int custId;
  final int userId;
  final DateTime? createDate;
  final int totalQuantity;
  final String status;
  final DateTime? dispatchDate;
  final String? userName;

  bool get isPending => dispatchDate == null;
  bool get isPacked => status == 'Packed';
  bool get isDispatched => dispatchDate != null;
  String get formattedCreateDate => _fmt(createDate);
  String get statusLabel =>
      status.isNotEmpty ? status : (isPending ? 'Ordered' : 'Dispatched');
  String get displayStatus => statusLabel;

  factory CustomerOrderSummary.fromJson(Map<String, dynamic> j) =>
      CustomerOrderSummary(
        ordId: (j['ord_id'] as int?) ?? 0,
        custId: (j['cust_id'] as int?) ?? 0,
        userId: (j['user_id'] as int?) ?? 0,
        createDate: j['create_date'] != null
            ? DateTime.parse(j['create_date'] as String)
            : null,
        totalQuantity: (j['total_quantity'] as int?) ?? 0,
        status: (j['status'] as String?) ?? '',
        dispatchDate: j['dispatch_date'] != null
            ? DateTime.parse(j['dispatch_date'] as String)
            : null,
        userName: j['user_name'] as String?,
      );
}

// ── OrderItem ─────────────────────────────────────────────────────────────────
/// Individual product line within an order
class OrderItem {
  const OrderItem({
    required this.id,
    required this.ordId,
    required this.pid,
    required this.pname,
    required this.category,
    required this.quantity,
    this.packedQuantity,
    this.mrp,
    this.pridis,
  });

  final int id;
  final int ordId;
  final int pid;
  final String pname;
  final String category;
  final int quantity;

  /// Quantity actually packed by staff (null until packed).
  final int? packedQuantity;

  /// MRP entered at packing time, frozen on this line (null until packed).
  final double? mrp;
  final String? pridis;

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id: (j['id'] as int?) ?? 0,
        ordId: (j['ord_id'] as int?) ?? 0,
        pid: (j['pid'] as int?) ?? 0,
        pname: (j['pname'] as String?) ?? '',
        category: (j['category'] as String?) ?? '',
        quantity: (j['quantity'] as int?) ?? 0,
        packedQuantity: j['packed_quantity'] as int?,
        mrp: (j['mrp'] as num?)?.toDouble(),
        pridis: j['pridis'] as String?,
      );
}

// ── OrderDetail ───────────────────────────────────────────────────────────────
/// Full order detail: items list + optional payment
/// Returned by GET /Orders/{id}/ and GET /Customer/{cid}/Orders/{oid}/
class OrderDetail {
  const OrderDetail({
    required this.items,
    this.payment,
    this.lastEditedByName,
    this.lastEditedDate,
  });

  final List<OrderItem> items;
  final PaymentModel? payment;

  /// Name of the user who last edited this order (null if never edited).
  final String? lastEditedByName;

  /// Date this order was last edited (null if never edited).
  final DateTime? lastEditedDate;

  factory OrderDetail.fromJson(Map<String, dynamic> j) => OrderDetail(
        items: (j['Orders'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        payment: j['Payment'] != null
            ? PaymentModel.fromJson(j['Payment'] as Map<String, dynamic>)
            : null,
        lastEditedByName: j['LastEditedBy'] as String?,
        lastEditedDate: j['LastEditedDate'] != null
            ? DateTime.parse(j['LastEditedDate'] as String)
            : null,
      );
}

// ── OrderPreload ──────────────────────────────────────────────────────────────
/// Pre-loaded data for the order creation form — GET /Orders/add/
class OrderPreload {
  const OrderPreload({required this.items, required this.customers});

  final List<ProductModel> items;
  final List<CustomerModel> customers;

  factory OrderPreload.fromJson(Map<String, dynamic> j) => OrderPreload(
        items: (j['items'] as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        customers: (j['customer'] as List)
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── OrderItemCreate ───────────────────────────────────────────────────────────
/// Mutable form row for creating/editing an order item
class OrderItemCreate {
  OrderItemCreate({
    this.pname = '',
    this.category = '',
    this.quantity = 1,
    this.pridis,
    this.selectedProduct,
  });

  String pname;
  String category;
  int quantity;
  String? pridis;
  ProductModel? selectedProduct;

  bool get isValid => pname.isNotEmpty && category.isNotEmpty && quantity > 0;

  Map<String, dynamic> toJson() => {
        'pname': pname,
        'category': category,
        'quantity': quantity,
        if (pridis != null && pridis!.isNotEmpty) 'pridis': pridis,
      };
}

// ── QueueOrder ────────────────────────────────────────────────────────────────
/// A row in the dispatch queue — returned by GET /Orders/queue/
class QueueOrder {
  const QueueOrder({
    required this.ordId,
    required this.custId,
    required this.userId,
    this.createDate,
    required this.totalQuantity,
    required this.status,
    required this.userName,
    required this.name,
    required this.shop,
    required this.city,
    required this.state,
    required this.contact,
  });

  final int ordId;
  final int custId;
  final int userId;
  final DateTime? createDate;
  final int totalQuantity;
  final String status;
  final String userName;
  final String name; // customer name
  final String shop;
  final String city;
  final String state;
  final String contact;

  factory QueueOrder.fromJson(Map<String, dynamic> j) => QueueOrder(
        ordId: (j['ord_id'] as int?) ?? 0,
        custId: (j['cust_id'] as int?) ?? 0,
        userId: (j['user_id'] as int?) ?? 0,
        createDate: j['create_date'] != null
            ? DateTime.parse(j['create_date'] as String)
            : null,
        totalQuantity: (j['total_quantity'] as int?) ?? 0,
        status: (j['status'] as String?) ?? 'Ordered',
        userName: (j['user_name'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        shop: (j['shop'] as String?) ?? '',
        city: (j['city'] as String?) ?? '',
        state: (j['state'] as String?) ?? '',
        contact: (j['contact'] as String?) ?? '',
      );
}
