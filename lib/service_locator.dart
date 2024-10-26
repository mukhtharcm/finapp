import 'package:get_it/get_it.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

final getIt = GetIt.instance;

String _getPocketBaseUrl() {
  return kDebugMode ? 'https://pb.76545689.xyz' : 'https://finbot.76545689.xyz';
}

Future<void> setupServiceLocator() async {
  // Set up AsyncAuthStore
  const storage = FlutterSecureStorage();
  final authData = await storage.read(key: 'pb_auth');

  final authStore = AsyncAuthStore(
    save: (String data) async =>
        await storage.write(key: 'pb_auth', value: data),
    initial: authData,
  );

  // Register PocketBase with AsyncAuthStore
  getIt.registerLazySingleton(() => PocketBase(
        _getPocketBaseUrl(),
        authStore: authStore,
      ));

  // Register AuthService
  getIt.registerLazySingleton(() => AuthService(getIt<PocketBase>()));

  // Register FinanceService
  getIt.registerLazySingleton(() => FinanceService(getIt<PocketBase>()));

  // initialize services
  getIt<FinanceService>().initialize();
}
