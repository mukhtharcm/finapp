import 'package:pocketbase/pocketbase.dart';

class Category {
  final String? id;
  final String name;
  final String icon;

  const Category({
    this.id,
    required this.name,
    required this.icon,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  factory Category.empty() {
    return const Category(
      name: 'Unknown',
      icon: '❓',
    );
  }

  factory Category.fromRecord(RecordModel record) {
    return Category(
      id: record.id,
      name: record.getStringValue('name'),
      icon: record.getStringValue('icon'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}
