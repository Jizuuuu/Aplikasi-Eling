class Category {
  final int? id;
  final String name;
  final String colorHex;
  final String iconName;

  const Category({
    this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      iconName: map['icon_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_name': iconName,
    };
  }
}
