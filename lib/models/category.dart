class Category {
  final String id;
  final String name;
  final String imageAsset;
  final String translatedName;

  Category({
    required this.id,
    required this.name,
    required this.imageAsset,
    this.translatedName = '',
  });

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      imageAsset: data['imageAsset'] ?? '',
      translatedName: data['TranslatedName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageAsset': imageAsset,
      'TranslatedName': translatedName,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? imageAsset,
    String? translatedName,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageAsset: imageAsset ?? this.imageAsset,
      translatedName: translatedName ?? this.translatedName,
    );
  }
}
