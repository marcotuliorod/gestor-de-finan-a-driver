import 'package:driver_finance/app.dart';
import 'package:driver_finance/core/network/auth_session.dart';
import 'package:driver_finance/core/notifications/notification_service.dart';
import 'package:driver_finance/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

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
