import 'package:pocketbase/pocketbase.dart';

class Account {
  final String? id;
  final String userId;
  final String name;
  final String type; // e.g., 'cash', 'bank', 'credit_card', 'savings'
  final String icon;
  final bool isDefault;
  final double initialBalance;

  Account({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    this.isDefault = false,
    this.initialBalance = 0.0,
  });

  factory Account.fromRecord(RecordModel record) {
    return Account(
      id: record.id,
      userId: record.getStringValue('user'),
      name: record.getStringValue('name'),
      type: record.getStringValue('type'),
      icon: record.getStringValue('icon'),
      isDefault: record.getBoolValue('is_default'),
      initialBalance: record.getDoubleValue('initial_balance'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'is_default': isDefault,
      'initial_balance': initialBalance,
    };
  }

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    bool? isDefault,
    double? initialBalance,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}
