class CustomerModel {
  const CustomerModel({
    required this.custId,
    required this.name,
    required this.city,
    required this.state,
    required this.contact,
    required this.shop,
    this.isDefaulter = false,
    this.defaulterReason,
  });

  final int custId;
  final String name;
  final String city;
  final String state;
  final String contact;
  final String shop;
  final bool isDefaulter;
  final String? defaulterReason;

  factory CustomerModel.fromJson(Map<String, dynamic> j) => CustomerModel(
        custId: j['cust_id'] as int,
        name: j['name'] as String,
        city: j['city'] as String,
        state: j['state'] as String,
        contact: j['contact'] as String,
        shop: j['shop'] as String,
        isDefaulter: (j['is_defaulter'] as bool?) ?? false,
        defaulterReason: j['defaulter_reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'state': state,
        'contact': contact,
        'shop': shop,
      };

  /// Used by searchable dropdowns to display the customer.
  @override
  String toString() => '$name  •  $shop';
}
