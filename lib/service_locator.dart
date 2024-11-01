import 'package:finapp/services/theme_service.dart';
import 'package:get_it/get_it.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

String _getPocketBaseUrl() {
  // if (kDebugMode && Platform.isAndroid) {
  //   return 'http://192.168.209.209:8090';
  // }
  return kDebugMode ? 'http://pb.76545689.xyz' : 'https://finbot.76545689.xyz';
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

  final authService = AuthService(getIt<PocketBase>());
  getIt.registerLazySingleton(() => authService);

  final financeService = FinanceService(getIt<PocketBase>());
  await financeService.initialize();
  getIt.registerLazySingleton(() => financeService);

  final themeService = ThemeService(await SharedPreferences.getInstance());
  getIt.registerLazySingleton(() => themeService);
}
