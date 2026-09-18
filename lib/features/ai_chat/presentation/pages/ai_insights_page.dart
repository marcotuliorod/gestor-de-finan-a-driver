import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AiInsightsPage extends StatelessWidget {
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: SafeArea(
        child: Column(
          children: [
            const DfaStatusBar(),
            const DfaHeader(kicker: 'POWERED BY CLAUDE', title: 'AI Insights'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SuggestionChips(),
                    const SizedBox(height: 14),
                    const DfaSectionLabel('RECENT INSIGHTS · 5 NEW'),
                    const SizedBox(height: 8),
                    DfaInsightCard(
                      category: 'PROFITABILITY',
                      categoryColor: AppColors.dfaRed,
                      age: '2H AGO',
                      title: 'Airport queue cost you \$68 this week',
                      body:
                          'Your 4 airport waits averaged \$11.40/hr against \$27.10/hr on downtown short hops. Same fuel, 3.2x the idle time.',
                      actionLabel: 'SEE THE 4 TRIPS',
                      onTap: () => context.go('/app/trips'),
                    ),
                    const SizedBox(height: 8),
                    DfaInsightCard(
                      category: 'TAX',
                      categoryColor: AppColors.dfaAmber,
                      age: '6H AGO',
                      title: 'Set aside \$128 more before Sunday',
                      body:
                          'You are 14% behind the pace needed for the Q4 estimate. A \$128 sweep this week keeps you on schedule.',
                      actionLabel: 'SWEEP \$128',
                      onTap: () => context.go('/app/tax'),
                    ),
                    const SizedBox(height: 8),
                    DfaInsightCard(
                      category: 'EXPENSE ANOMALY',
                      categoryColor: AppColors.dfaBlue,
                      age: 'YESTERDAY',
                      title: 'Fuel spend up 18% on flat miles',
                      body:
                          'You filled at Shell on Airport Blvd 5 of 7 times at \$4.41/gal. Costco on Halsey is \$3.88 — about \$31/week back.',
                      actionLabel: 'MAP CHEAPER STOPS',
                      onTap: () => context.go('/app/money'),
                    ),
                    const SizedBox(height: 8),
                    DfaInsightCard(
                      category: 'SCHEDULE',
                      categoryColor: AppColors.dfaGreen,
                      age: '2 DAYS AGO',
                      title: 'Tuesday 4–8p is your best hour window',
                      body:
                          'Over 8 weeks, Tue 4–8p nets \$38.20/hr — 34% above your weekly average. Only 3 of those slots were worked.',
                      actionLabel: 'BLOCK CALENDAR',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    DfaInsightCard(
                      category: 'MILEAGE',
                      categoryColor: AppColors.dfaViolet,
                      age: '3 DAYS AGO',
                      title: '142 miles unlogged last week',
                      body:
                          'GPS trace captured 142 miles not yet confirmed as business. At \$0.70/mi that\'s \$99.40 in deductions waiting.',
                      actionLabel: 'REVIEW MILES',
                      onTap: () => context.go('/app/money'),
                    ),
                  ],
                ),
              ),
            ),
            _ChatInputBar(),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  static const _chips = [
    'Why was last week low?',
    'Best hours this month',
    'Tax estimate Q4',
    'Fuel savings tips',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.dfaRaised,
              border: Border.all(color: const Color(0xFF232A32)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(_chips[i],
                style: GoogleFonts.ibmPlexSans(
                    fontSize: 11, color: AppColors.dfaInk3)),
          );
        },
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: const BorderSide(color: AppColors.dfaLine)),
        color: AppColors.dfaSurface,
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dfaRaised,
                border: Border.all(color: AppColors.dfaLine),
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text('Ask anything about your finances…',
                  style: GoogleFonts.ibmPlexSans(
                      fontSize: 13, color: AppColors.dfaInk5)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.dfaGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_upward,
                size: 18, color: Color(0xFF06080A)),
          ),
        ],
      ),
    );
  }
}
