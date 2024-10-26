import 'package:pocketbase/pocketbase.dart';
import 'dart:async';

class AuthService {
  final PocketBase _pb;

  AuthService(this._pb);

  bool get isAuthenticated => _pb.authStore.isValid;

  Stream<AuthStoreEvent> get authStateChanges => _pb.authStore.onChange;

  RecordModel? get currentUser => _pb.authStore.model;

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
    });
    // After creating the user, log them in
    await login(email, password);
  }

  Future<void> logout() async {
    _pb.authStore.clear();
  }
}
