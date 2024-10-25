import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Future<void> logout() async {
    _pb.authStore.clear();
  }
}
