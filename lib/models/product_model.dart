class ProductModel {
  const ProductModel({
    required this.pid,
    required this.pname,
    required this.category,
    this.mrp,
  });

  final int pid;
  final String pname;
  final String category;

  /// Latest remembered MRP for this product (set by packing staff). May be null.
  final double? mrp;

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        pid: j['pid'] as int,
        pname: j['pname'] as String,
        category: j['category'] as String,
        mrp: (j['mrp'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'pname': pname,
        'category': category,
      };

  @override
  String toString() => pname;
}
