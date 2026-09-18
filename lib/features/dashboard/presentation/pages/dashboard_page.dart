import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: SafeArea(
        child: Column(
          children: [
            const DfaStatusBar(),
            const DfaHeader(
              kicker: 'MARCUS R · CAMRY LE',
              title: 'Overview',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeeklyEarningsCard(),
                    const SizedBox(height: 10),
                    DfaStatGrid(
                      items: dfaStats([
                        ('GROSS', r'$1,512', null),
                        ('MILES', '784', null),
                        ('HOURS', '41.5', null),
                        (r'$/HR', r'$28.6', AppColors.dfaGreen),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _AiInsightsSection(),
                    const SizedBox(height: 18),
                    DfaSectionLabel(
                      'TODAY · 3 SHIFTS',
                      trailingLabel: 'LOG →',
                      onTrailingTap: () => context.go('/app/trips'),
                    ),
                    const SizedBox(height: 8),
                    _TodayShifts(),
                    const SizedBox(height: 16),
                    _BottomCards(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyEarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DfaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dfaMonoLabel('NET THIS WEEK'),
                    const SizedBox(height: 2),
                    dfaMonoBig(r'$1,186.40'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+9.4%',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dfaGreen)),
                  const SizedBox(height: 2),
                  dfaMonoLabel('VS WK 37', spacing: 0),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: const Color(0xFF1B2430),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.85,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1F9E63), AppColors.dfaGreen],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dfaMonoLabel(r'85% OF $1,400 GOAL', spacing: 0),
              dfaMonoLabel(r'$214 TO GO', spacing: 0),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiInsightsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _PulseDot(),
                const SizedBox(width: 7),
                Text('AI INSIGHTS · 5 NEW',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        letterSpacing: 0.16,
                        color: AppColors.dfaInk3)),
              ],
            ),
            GestureDetector(
              onTap: () => context.go('/app/ai'),
              child: Text('ALL →',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10, color: AppColors.dfaBlue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DfaInsightCard(
          category: 'PROFITABILITY',
          categoryColor: AppColors.dfaRed,
          age: '2H AGO',
          title: 'Airport queue cost you \$68 this week',
          body:
              'Your 4 airport waits averaged \$11.40/hr against \$27.10/hr on downtown short hops. Same fuel, 3.2x the idle time.',
          actionLabel: 'SEE THE 4 TRIPS',
          onTap: () => context.go('/app/ai'),
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
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.dfaGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _TodayShifts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dfaLine),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _ShiftRow(
            time: '6:40a',
            title: 'Morning airport push',
            sub: 'UBER · 4.2 hrs · 9 trips',
            amount: r'$132.40',
            rate: r'$31.5/h',
            rateColor: AppColors.dfaGreen,
            isLast: false,
          ),
          _ShiftRow(
            time: '11:15a',
            title: 'Lunch delivery block',
            sub: 'UBER EATS · 2.8 hrs · 11 orders',
            amount: r'$71.85',
            rate: r'$25.7/h',
            rateColor: AppColors.dfaInk,
            isLast: false,
          ),
          _ShiftRow(
            time: '4:00p',
            title: 'Evening mixed',
            sub: 'LYFT + DOORDASH · 3.1 hrs',
            amount: r'$68.20',
            rate: r'$22.0/h',
            rateColor: AppColors.dfaRed,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({
    required this.time,
    required this.title,
    required this.sub,
    required this.amount,
    required this.rate,
    required this.rateColor,
    required this.isLast,
  });

  final String time, title, sub, amount, rate;
  final Color rateColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dfaRaised,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.dfaLine2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(time,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 10, color: AppColors.dfaInk3)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dfaInk)),
                const SizedBox(height: 2),
                Text(sub,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10, color: AppColors.dfaInk4)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dfaInk)),
              const SizedBox(height: 2),
              Text(rate,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10, color: rateColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/app/tax'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dfaRaised,
                border: Border.all(color: AppColors.dfaLine),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dfaMonoLabel('TAX SET-ASIDE', spacing: 0.12),
                  const SizedBox(height: 5),
                  Text(r'$2,410',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dfaAmber)),
                  const SizedBox(height: 6),
                  Text('14% behind Q4 pace · \$128 short this week',
                      style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          height: 1.35,
                          color: AppColors.dfaInk3)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/app/forecast'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dfaRaised,
                border: Border.all(color: AppColors.dfaLine),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dfaMonoLabel('30-DAY FORECAST', spacing: 0.12),
                  const SizedBox(height: 5),
                  Text(r'$4,120',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dfaBlue)),
                  const SizedBox(height: 6),
                  Text('Projected net after fuel, tax & service',
                      style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          height: 1.35,
                          color: AppColors.dfaInk3)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
