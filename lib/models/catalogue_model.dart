class CatalogueModel {
  const CatalogueModel({
    required this.id,
    required this.title,
    required this.category,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
    this.uploadedBy,
  });

  final int id;
  final String title;
  final String category;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadedAt;
  final String? uploadedBy;

  factory CatalogueModel.fromJson(Map<String, dynamic> j) => CatalogueModel(
        id: j['id'] as int,
        title: j['title'] as String,
        category: j['category'] as String,
        fileUrl: j['file_url'] as String,
        fileSize: (j['file_size'] as num?)?.toInt() ?? 0,
        uploadedAt: DateTime.parse(j['uploaded_at'] as String),
        uploadedBy: j['uploaded_by'] as String?,
      );

  String get readableSize {
    if (fileSize <= 0) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = fileSize.toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${units[i]}';
  }

  @override
  String toString() => title;
}
