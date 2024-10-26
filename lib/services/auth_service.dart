import 'package:pocketbase/pocketbase.dart';
import 'dart:async';

class AuthService {
  final PocketBase _pb;

  AuthService(this._pb);

  bool get isAuthenticated => _pb.authStore.isValid;

  Stream<AuthStoreEvent> get authStateChanges => _pb.authStore.onChange;

  RecordModel? get currentUser => _pb.authStore.model;

  String get userName => currentUser?.getStringValue('name') ?? 'User';
  String get preferredCurrency =>
      currentUser?.getStringValue('preferred_currency') ?? 'USD';

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      // We'll set default values for name and preferred_currency
      'name': 'User',
      'preferred_currency': 'USD',
    });
    // After creating the user, log them in
    await login(email, password);
  }

  Future<void> logout() async {
    _pb.authStore.clear();
  }

  Future<void> updateUserProfile(
      {String? name, String? preferredCurrency}) async {
    if (!isAuthenticated) return;

    final userId = currentUser!.id;
    await _pb.collection('users').update(userId, body: {
      if (name != null) 'name': name,
      if (preferredCurrency != null) 'preferred_currency': preferredCurrency,
    });

    // Refresh the auth store to get the updated user data
    await _pb.collection('users').authRefresh();
  }
}
