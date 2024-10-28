class UserModel {
  final String id;
  final String email;
  final String name;
  final String preferredCurrency;
  // Add any other user fields here

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.preferredCurrency,
  });

  factory UserModel.fromRecord(dynamic record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name') ?? 'User',
      preferredCurrency: record.getStringValue('preferred_currency') ?? 'USD',
    );
  }

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      email: '',
      name: 'User',
      preferredCurrency: 'USD',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? preferredCurrency,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }
}
