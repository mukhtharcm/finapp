import 'package:pocketbase/pocketbase.dart';

class Category {
  final String? id;
  final String? userId;
  final String name;
  final String icon;
  final bool isDefault;

  Category({
    this.id,
    this.userId,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  factory Category.fromRecord(RecordModel record) {
    return Category(
      id: record.id,
      userId: record.getStringValue('user'),
      name: record.getStringValue('name'),
      icon: record.getStringValue('icon'),
      isDefault: record.getBoolValue('is_default'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'icon': icon,
      'is_default': isDefault,
    };
  }
}
