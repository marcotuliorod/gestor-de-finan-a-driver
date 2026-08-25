import 'package:driver_finance/app.dart';
import 'package:driver_finance/core/network/auth_session.dart';
import 'package:driver_finance/core/network/supabase_client.dart';
import 'package:driver_finance/core/notifications/notification_service.dart';
import 'package:driver_finance/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(sprint-15): SUPABASE_URL/SUPABASE_ANON_KEY seguem em uso só pelos
  // repositórios de dados (trips, expenses, etc.) até serem migrados para o
  // backend próprio. Auth já usa API_BASE_URL (ver AuthSession/ApiClient).
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await AppSupabaseClient.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  final authSession = AuthSession();
  await authSession.load();

  await NotificationService.instance.init();

  final prefs = await SharedPreferences.getInstance();

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authSessionProvider.overrideWithValue(authSession),
        ],
        child: const DriverFinanceApp(),
      ),
    ),
  );
}
