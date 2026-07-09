class PaymentModel {
  const PaymentModel({
    required this.paymentId,
    required this.ordId,
    required this.custId,
    this.amount,
    this.date,
    required this.mode,
  });

  final int paymentId;
  final int ordId;
  final int custId;
  final int? amount;
  final DateTime? date;
  final String mode;

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
        paymentId: (j['payment_id'] as int?) ?? 0,
        ordId: (j['ord_id'] as int?) ?? 0,
        custId: (j['cust_id'] as int?) ?? 0,
        amount: j['Amount'] as int?,
        date: j['date'] != null ? DateTime.parse(j['date'] as String) : null,
        mode: (j['Mode'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'payment_id': paymentId,
        'ord_id': ordId,
        'cust_id': custId,
        'Amount': amount ?? 0,
        'Mode': mode,
      };
}

/// Payment joined with customer name + shop (from GET /Payment/ and /Payment/Customer/{id})
class PaymentWithCustomer extends PaymentModel {
  const PaymentWithCustomer({
    required super.paymentId,
    required super.ordId,
    required super.custId,
    super.amount,
    super.date,
    required super.mode,
    required this.name,
    required this.shop,
  });

  final String name;
  final String shop;

  factory PaymentWithCustomer.fromJson(Map<String, dynamic> j) =>
      PaymentWithCustomer(
        paymentId: j['payment_id'] as int,
        ordId: (j['ord_id'] as int?) ?? 0,
        custId: (j['cust_id'] as int?) ?? 0,
        amount: j['Amount'] as int?,
        date: j['date'] != null ? DateTime.parse(j['date'] as String) : null,
        mode: j['Mode'] as String,
        name: (j['name'] as String?) ?? '',
        shop: (j['shop'] as String?) ?? '',
      );
}
