import 'package:driver_finance/core/ui/components/app_shell.dart';
import 'package:driver_finance/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:driver_finance/features/auth/presentation/pages/login_page.dart';
import 'package:driver_finance/features/auth/presentation/pages/onboarding_page.dart';
import 'package:driver_finance/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:driver_finance/features/expenses/presentation/pages/expense_list_page.dart';
import 'package:driver_finance/features/reports/presentation/pages/reports_page.dart';
import 'package:driver_finance/features/settings/presentation/pages/settings_page.dart';
import 'package:driver_finance/features/trips/presentation/pages/trip_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/app/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/app/trips',
            builder: (context, state) => const TripListPage(),
          ),
          GoRoute(
            path: '/app/expenses',
            builder: (context, state) => const ExpenseListPage(),
          ),
          GoRoute(
            path: '/app/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/app/ai',
            builder: (context, state) => const AiChatPage(),
          ),
          GoRoute(
            path: '/app/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
