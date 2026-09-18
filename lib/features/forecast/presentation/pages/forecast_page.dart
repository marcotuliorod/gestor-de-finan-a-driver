import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: SafeArea(
        child: Column(
          children: [
            const DfaStatusBar(),
            const DfaHeader(kicker: 'NEXT 30 DAYS', title: 'Forecast'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProjectedNetCard(),
                    const SizedBox(height: 12),
                    DfaStatGrid(
                      items: dfaStats([
                        ('TRIPS EST', '168', null),
                        ('MILES EST', '940', null),
                        ('HOURS EST', '52', null),
                        (r'$/HR EST', r'$29', AppColors.dfaGreen),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    const DfaSectionLabel('6-WEEK OUTLOOK · W39–W44'),
                    const SizedBox(height: 8),
                    _WeekBarChart(),
                    const SizedBox(height: 16),
                    const DfaSectionLabel('BOOKED OBLIGATIONS'),
                    const SizedBox(height: 8),
                    _ObligationsList(),
                    const SizedBox(height: 12),
                    _CashFlowWatchCard(),
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

class _ProjectedNetCard extends StatelessWidget {
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
                    dfaMonoLabel('PROJECTED NET · 30 DAYS'),
                    const SizedBox(height: 2),
                    dfaMonoBig(r'$4,120'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('+6.2%',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dfaGreen)),
                  const SizedBox(height: 2),
                  dfaMonoLabel('VS LAST 30', spacing: 0),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('After fuel, platform fees & estimated tax set-aside',
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 12, height: 1.4, color: AppColors.dfaInk3)),
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  static const _weeks = [
    ('W39', 1186.0, true),
    ('W40', 1240.0, true),
    ('W41', 1310.0, false),
    ('W42', 890.0, false),
    ('W43', 1180.0, false),
    ('W44', 1050.0, false),
  ];

  static const _max = 1400.0;

  @override
  Widget build(BuildContext context) {
    return DfaCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _weeks.map((w) {
              final isActual = w.$3;
              final frac = (w.$2 / _max).clamp(0.0, 1.0);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        '\$${(w.$2 / 1000).toStringAsFixed(1)}k',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 8, color: AppColors.dfaInk4),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          height: 72,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: frac,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isActual
                                      ? AppColors.dfaBlue
                                      : const Color(0xFF1B2C3A),
                                  border: isActual
                                      ? null
                                      : Border.all(
                                          color: AppColors.dfaBlue
                                              .withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(w.$1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 9, color: AppColors.dfaInk4)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LegendDot(color: AppColors.dfaBlue, label: 'ACTUAL'),
              SizedBox(width: 14),
              _LegendDot(color: Color(0xFF1B2C3A), label: 'PROJECTED'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.dfaLine),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.ibmPlexMono(
                fontSize: 9, color: AppColors.dfaInk4)),
      ],
    );
  }
}

class _ObligationsList extends StatelessWidget {
  static const _items = [
    ('Vehicle insurance', 'Oct 1', r'−$187.00'),
    ('Phone plan (biz)', 'Oct 5', r'−$65.00'),
    ('Q3 estimated tax', 'Oct 15', r'−$612.00'),
    ('Oil change (est.)', 'Oct 22', r'−$84.00'),
  ];

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
          for (var i = 0; i < _items.length; i++)
            _ObligationRow(
              label: _items[i].$1,
              date: _items[i].$2,
              amount: _items[i].$3,
              isLast: i == _items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ObligationRow extends StatelessWidget {
  const _ObligationRow(
      {required this.label,
      required this.date,
      required this.amount,
      required this.isLast});
  final String label, date, amount;
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
          Expanded(
            child: Text(label,
                style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dfaInk)),
          ),
          Text(date,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 10, color: AppColors.dfaInk4)),
          const SizedBox(width: 14),
          SizedBox(
            width: 72,
            child: Text(amount,
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dfaRed)),
          ),
        ],
      ),
    );
  }
}

class _CashFlowWatchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dfaRaised,
        border: const Border(
          top: BorderSide(color: AppColors.dfaLine),
          right: BorderSide(color: AppColors.dfaLine),
          bottom: BorderSide(color: AppColors.dfaLine),
          left: BorderSide(color: AppColors.dfaBlue, width: 2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI CASH-FLOW WATCH',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 9,
                  letterSpacing: 0.12,
                  color: AppColors.dfaBlue)),
          const SizedBox(height: 5),
          Text(
              'Oct 15 tax payment (\$612) lands the same week as insurance renewal (\$187). Your W41 projection covers both — but W42 shows a dip to \$890. Keep \$800+ in checking entering October.',
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 12, height: 1.5, color: AppColors.dfaInk2)),
        ],
      ),
    );
  }
}
