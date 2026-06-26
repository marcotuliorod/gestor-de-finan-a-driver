import 'package:driver_finance/app.dart';
import 'package:driver_finance/core/network/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await AppSupabaseClient.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(const ProviderScope(child: DriverFinanceApp())),
  );
}
