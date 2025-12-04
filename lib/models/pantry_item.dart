class PantryItem {
  final String id;
  final String name;
  final DateTime expiryDate;
  final String category;

  PantryItem({required this.id, required this.name, required this.expiryDate, required this.category});

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'expiryDate': expiryDate.toIso8601String(), 'category': category,
  };

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      expiryDate: DateTime.parse(json['expiryDate']),
      category: json['category'],
    );
  }
}
