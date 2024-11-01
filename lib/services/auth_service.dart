import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:finapp/models/user.dart';

class AuthService {
  final PocketBase pb;

  AuthService(this.pb);

  UserModel? get currentUser {
    if (!pb.authStore.isValid) return null;
    return UserModel.fromRecord(pb.authStore.model);
  }

  String get userName => currentUser?.name ?? 'Guest';

  Future<void> signIn(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
      });
      await signIn(email, password);
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    pb.authStore.clear();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? preferredCurrency,
  }) async {
    if (!pb.authStore.isValid) return;

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (preferredCurrency != null) {
      data['preferredCurrency'] = preferredCurrency;
    }

    try {
      await pb.collection('users').update(
            pb.authStore.model.id,
            body: data,
          );
      // Refresh auth to get updated user data
      await pb.collection('users').authRefresh();
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    if (!pb.authStore.isValid) return;

    try {
      await pb.collection('users').update(
        pb.authStore.model.id,
        body: {
          'oldPassword': oldPassword,
          'password': newPassword,
          'passwordConfirm': newPassword,
        },
      );
    } catch (e) {
      debugPrint('Update password error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (!pb.authStore.isValid) return;

    try {
      await pb.collection('users').delete(pb.authStore.model.id);
      pb.authStore.clear();
    } catch (e) {
      debugPrint('Delete account error: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => pb.authStore.isValid;

  Stream<bool> get authStateChanges {
    return pb.authStore.onChange.map((_) => pb.authStore.isValid);
  }
}
