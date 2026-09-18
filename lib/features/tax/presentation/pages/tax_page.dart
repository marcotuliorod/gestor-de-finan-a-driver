import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaxPage extends StatefulWidget {
  const TaxPage({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<TaxPage> createState() => _TaxPageState();
}

class _TaxPageState extends State<TaxPage> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: SafeArea(
        child: Column(
          children: [
            const DfaStatusBar(),
            const DfaHeader(
                kicker: 'SELF-EMPLOYED · SCH. C', title: 'Taxes'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DfaSegmentedControl(
                      segments: const ['SET-ASIDE', 'QUARTERLY', 'RECONCILE'],
                      selected: _tab,
                      onSelect: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 14),
                    if (_tab == 0) const _SetAsideTab(),
                    if (_tab == 1) const _QuarterlyTab(),
                    if (_tab == 2) const _ReconcileTab(),
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

class _SetAsideTab extends StatelessWidget {
  const _SetAsideTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DfaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dfaMonoLabel('HELD FOR TAX · 2026'),
              const SizedBox(height: 2),
              Text(r'$2,410',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.02,
                      color: AppColors.dfaAmber)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 6,
                  color: const Color(0xFF1B2430),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.86,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFB07E12), AppColors.dfaAmber],
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
                  dfaMonoLabel(r'86% OF $2,800 NEEDED', spacing: 0),
                  Text(r'$390 SHORT',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 10, color: AppColors.dfaRed)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dfaRaised,
            border: const Border(
              top: BorderSide(color: AppColors.dfaLine),
              right: BorderSide(color: AppColors.dfaLine),
              bottom: BorderSide(color: AppColors.dfaLine),
              left: BorderSide(color: AppColors.dfaAmber, width: 2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI RECOMMENDATION',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      letterSpacing: 0.12,
                      color: AppColors.dfaAmber)),
              const SizedBox(height: 5),
              Text(
                  'At 27% effective, auto-sweep \$32 per payout to close the gap before the Jan 15 deadline. Your last three weeks averaged \$1,186 net.',
                  style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.dfaInk2)),
              const SizedBox(height: 9),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dfaAmber,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('TURN ON AUTO-SWEEP',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B0E11))),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: Text('Adjust rate',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 10,
                            color: const Color(0xFF6B7785))),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const DfaSectionLabel('SCHEDULE C PREVIEW'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: const Column(
            children: [
              _SchedLine('Gross platform income', r'$52,840', AppColors.dfaInk,
                  AppColors.dfaRaised, false),
              _SchedLine('Standard mileage deduction', r'−$19,891',
                  AppColors.dfaGreen, AppColors.dfaRaised, false),
              _SchedLine('Other business expenses', r'−$4,120',
                  AppColors.dfaGreen, AppColors.dfaRaised, false),
              _SchedLine('Net profit (Sch. C line 31)', r'$28,829',
                  AppColors.dfaInk, AppColors.dfaPanel, false),
              _SchedLine('Self-employment tax (15.3%)', r'$4,073',
                  AppColors.dfaAmber, AppColors.dfaRaised, false),
              _SchedLine('Est. total liability', r'$7,784', AppColors.dfaAmber,
                  AppColors.dfaPanel, true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SchedLine extends StatelessWidget {
  const _SchedLine(
      this.label, this.value, this.valueColor, this.bg, this.isLast);
  final String label, value;
  final Color valueColor, bg;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.dfaLine2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 12, color: AppColors.dfaInk2)),
          Text(value,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }
}

class _QuarterlyTab extends StatelessWidget {
  const _QuarterlyTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.dfaPanel,
            border: Border.all(color: const Color(0xFF2A2213)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Q3 2026 · DUE SEP 15',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 10,
                          letterSpacing: 0.14,
                          color: AppColors.dfaAmber)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A2F10),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('OVERDUE',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 9, color: AppColors.dfaAmber)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(r'$1,284',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dfaInk)),
              const SizedBox(height: 4),
              Text('Estimated payment · IRS 1040-ES + state',
                  style: GoogleFonts.ibmPlexSans(
                      fontSize: 11.5, color: AppColors.dfaInk3)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.dfaGreen,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('PAY NOW',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF06210F))),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A222C),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('Remind me',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 10, color: AppColors.dfaInk)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: const Column(
            children: [
              _QRow('Q1 2026', 'JAN–MAR · PAID APR 15', r'$1,105', 'PAID',
                  Color(0xFF12261A), AppColors.dfaGreen2, false),
              _QRow('Q2 2026', 'APR–JUN · PAID JUN 16', r'$1,240', 'PAID',
                  Color(0xFF12261A), AppColors.dfaGreen2, false),
              _QRow('Q3 2026', 'JUL–SEP · DUE SEP 15', r'$1,284', 'DUE',
                  Color(0xFF3A2F10), AppColors.dfaAmber, false),
              _QRow('Q4 2026', 'OCT–DEC · DUE JAN 15', r'$1,310', 'EST',
                  Color(0xFF1A222C), AppColors.dfaInk3, true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.dfaRaised,
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dfaMonoLabel('EFFECTIVE RATE BUILD-UP', spacing: 0.12),
              const SizedBox(height: 8),
              ...[
                ('Federal marginal', '12%'),
                ('Self-employment', '15.3%'),
                ('Oregon state', '8.75%'),
                ('Blended effective (after QBI)', '27%'),
              ].map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.$1,
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 11.5, color: AppColors.dfaInk2)),
                        Text(r.$2,
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: r.$1.startsWith('Blended')
                                    ? AppColors.dfaAmber
                                    : AppColors.dfaInk)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _QRow extends StatelessWidget {
  const _QRow(this.q, this.sub, this.amount, this.status, this.statusBg,
      this.statusFg, this.isLast);
  final String q, sub, amount, status;
  final Color statusBg, statusFg;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dfaInk)),
                const SizedBox(height: 3),
                Text(sub,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 9.5, color: AppColors.dfaInk4)),
              ],
            ),
          ),
          Text(amount,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dfaInk)),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(status,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9, color: statusFg)),
          ),
        ],
      ),
    );
  }
}

class _ReconcileTab extends StatelessWidget {
  const _ReconcileTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DfaCard(
                color: AppColors.dfaRaised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dfaMonoLabel('SETTLEMENTS', spacing: 0.12),
                    const SizedBox(height: 4),
                    dfaMonoBig(r'$3,412.80', size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dfaRaised,
                  border: Border.all(color: const Color(0xFF3A1A1A)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dfaMonoLabel('VARIANCE', spacing: 0.12),
                    const SizedBox(height: 4),
                    dfaMonoBig(r'−$41.15', size: 20, color: AppColors.dfaRed),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const DfaSectionLabel('PAYOUT VS BANK DEPOSIT'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: const Column(
            children: [
              _RecRow('UBER', 'SEP 16', r'EXP $742.10 · GOT $742.10',
                  r'$0.00', null, 'MATCH', Color(0xFF12261A),
                  AppColors.dfaGreen2, false),
              _RecRow('DOORDASH', 'SEP 16',
                  r'EXP $318.40 · GOT $294.15', r'−$24.25',
                  AppColors.dfaRed, 'SHORT', Color(0xFF3A1A1A),
                  Color(0xFFFF9A9A), false),
              _RecRow('LYFT', 'SEP 15', r'EXP $486.20 · GOT $486.20',
                  r'$0.00', null, 'MATCH', Color(0xFF12261A),
                  AppColors.dfaGreen2, false),
              _RecRow('DOORDASH', 'SEP 09',
                  r'EXP $271.05 · GOT $254.15', r'−$16.90',
                  AppColors.dfaRed, 'SHORT', Color(0xFF3A1A1A),
                  Color(0xFFFF9A9A), false),
              _RecRow('UBEREATS', 'SEP 09',
                  r'EXP $212.80 · GOT $212.80', r'$0.00', null, 'MATCH',
                  Color(0xFF12261A), AppColors.dfaGreen2, true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dfaRaised,
            border: const Border(
              top: BorderSide(color: AppColors.dfaLine),
              right: BorderSide(color: AppColors.dfaLine),
              bottom: BorderSide(color: AppColors.dfaLine),
              left: BorderSide(color: AppColors.dfaRed, width: 2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DISPUTE READY',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      letterSpacing: 0.12,
                      color: AppColors.dfaRed)),
              const SizedBox(height: 5),
              Text(
                  'Two DoorDash payouts landed \$41.15 under the trip-level total. I drafted a claim with the 7 affected order IDs attached.',
                  style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.dfaInk2)),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A222C),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('REVIEW CLAIM',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dfaInk)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecRow extends StatelessWidget {
  const _RecRow(this.platform, this.date, this.detail, this.variance,
      this.varianceColor, this.status, this.statusBg, this.statusFg,
      this.isLast);
  final String platform, date, detail, variance, status;
  final Color? varianceColor;
  final Color statusBg, statusFg;
  final bool isLast;

  Color get _platformBg {
    switch (platform) {
      case 'LYFT':
        return const Color(0xFF2A1630);
      case 'UBEREATS':
        return const Color(0xFF12261A);
      case 'DOORDASH':
        return const Color(0xFF2C1714);
      default:
        return const Color(0xFF1C232B);
    }
  }

  Color get _platformFg {
    switch (platform) {
      case 'LYFT':
        return const Color(0xFFE8A5FF);
      case 'UBEREATS':
        return AppColors.dfaGreen2;
      case 'DOORDASH':
        return const Color(0xFFFF9A7A);
      default:
        return const Color(0xFFD7E1EC);
    }
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _platformBg,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(platform,
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 9, color: _platformFg)),
                    ),
                    const SizedBox(width: 6),
                    Text(date,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 9.5, color: AppColors.dfaInk4)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(detail,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10, color: const Color(0xFF6B7785))),
              ],
            ),
          ),
          Text(variance,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: varianceColor ?? const Color(0xFF6B7785))),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(status,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9, color: statusFg)),
          ),
        ],
      ),
    );
  }
}
