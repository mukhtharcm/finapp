import 'package:pocketbase/pocketbase.dart';
import 'package:signals/signals.dart';
import 'package:finapp/models/user.dart';
import 'dart:async';

class AuthService {
  final PocketBase _pb;

  // Main user signal
  final user = signal<UserModel>(UserModel.empty());

  // Computed signals for frequently used values
  late final userName = computed(() => user.value.name);
  late final preferredCurrency = computed(() => user.value.preferredCurrency);

  AuthService(this._pb) {
    // Initialize user data if authenticated
    if (isAuthenticated) {
      user.value = UserModel.fromRecord(currentUser);
    }

    // Setup realtime subscription when service is created
    _setupRealtimeSubscription();
  }

  bool get isAuthenticated => _pb.authStore.isValid;
  Stream<AuthStoreEvent> get authStateChanges => _pb.authStore.onChange;
  RecordModel? get currentUser => _pb.authStore.model;

  void _setupRealtimeSubscription() {
    if (!isAuthenticated) return;

    final userId = currentUser!.id;
    _pb.collection('users').subscribe(userId, (e) {
      if (e.record != null) {
        // Update user signal with new data
        user.value = UserModel.fromRecord(e.record);
      }
    });
  }

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
    user.value = UserModel.fromRecord(currentUser);
    _setupRealtimeSubscription();
  }

  Future<void> signUp(String email, String password) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': 'User',
      'preferred_currency': 'USD',
    });
    await login(email, password);
  }

  Future<void> logout() async {
    await _pb.collection('users').unsubscribe(currentUser!.id);
    _pb.authStore.clear();
    await _pb.realtime.unsubscribe();
    user.value = UserModel.empty();
  }

  Future<void> updateUserProfile(
      {String? name, String? preferredCurrency}) async {
    if (!isAuthenticated) return;

    final userId = currentUser!.id;
    await _pb.collection('users').update(userId, body: {
      if (name != null) 'name': name,
      if (preferredCurrency != null) 'preferred_currency': preferredCurrency,
    });

    await _pb.collection('users').authRefresh();
    user.value = UserModel.fromRecord(currentUser);
  }
}
