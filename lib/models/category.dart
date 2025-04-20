class Category {
  final String id;
  final String name;
  final String imageAsset;

  Category({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      imageAsset: data['imageAsset'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageAsset': imageAsset,
    };
  }
}
