import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0D11),
          border: Border(top: BorderSide(color: AppColors.dfaLine, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(icon: '■', label: 'HOME', active: idx == 0, onTap: () => context.go('/app/dashboard')),
                _NavItem(icon: '≡', label: 'TRIPS', active: idx == 1, onTap: () => context.go('/app/trips')),
                _NavItem(icon: '◎', label: 'MONEY', active: idx == 2, onTap: () => context.go('/app/money')),
                _NavItem(icon: '%', label: 'TAX', active: idx == 3, onTap: () => context.go('/app/tax')),
                _NavItem(icon: '✦', label: 'AI', active: idx == 4, onTap: () => context.go('/app/ai')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/app/trips')) return 1;
    if (loc.startsWith('/app/money')) return 2;
    if (loc.startsWith('/app/tax')) return 3;
    if (loc.startsWith('/app/ai') || loc.startsWith('/app/forecast')) return 4;
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.dfaGreen : AppColors.dfaInk4;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 8.5,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w500,
                    color: color)),
            const SizedBox(height: 4),
            Container(
              width: 14,
              height: 2,
              decoration: BoxDecoration(
                color: active ? AppColors.dfaGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
