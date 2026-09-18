import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: SafeArea(
        child: Column(
          children: [
            const DfaStatusBar(),
            const DfaHeader(kicker: 'TRIP DETAIL', title: 'Breakdown'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/app/trips'),
                      child: Text('← TRIP LOG',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 10, color: AppColors.dfaBlue)),
                    ),
                    const SizedBox(height: 10),
                    DfaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C232B),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text('UBER',
                                    style: GoogleFonts.ibmPlexMono(
                                        fontSize: 9,
                                        color: const Color(0xFFD7E1EC))),
                              ),
                              const SizedBox(width: 7),
                              Text('Thu Sep 18 · 7:12a',
                                  style: GoogleFonts.ibmPlexMono(
                                      fontSize: 10,
                                      color: AppColors.dfaInk4)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('PDX Airport → Pearl District',
                              style: GoogleFonts.ibmPlexSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: AppColors.dfaInk)),
                          const SizedBox(height: 10),
                          dfaMonoBig(r'$38.40'),
                          const SizedBox(height: 3),
                          dfaMonoLabel(r'NET PAYOUT · $74/h EFFECTIVE',
                              spacing: 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dfaLine),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: const Column(
                        children: [
                          _FareLine('Base fare', r'$30.46', null, false),
                          _FareLine('Surge / promo', r'$10.32',
                              AppColors.dfaGreen, false),
                          _FareLine('Customer tip', r'$8.35',
                              AppColors.dfaGreen, false),
                          _FareLine(
                              'Platform fee', r'−$8.63', AppColors.dfaRed, false),
                          _FareLine(
                              'Est. fuel cost', r'−$2.10', AppColors.dfaRed, false),
                          _FareLine('Deductible miles (14.2)', r'$9.94',
                              AppColors.dfaAmber, true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.dfaRaised,
                        border: const Border(
                          top: BorderSide(color: AppColors.dfaLine),
                          right: BorderSide(color: AppColors.dfaLine),
                          bottom: BorderSide(color: AppColors.dfaLine),
                          left: BorderSide(
                              color: AppColors.dfaGreen, width: 2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI READ',
                              style: GoogleFonts.ibmPlexMono(
                                  fontSize: 9,
                                  letterSpacing: 0.12,
                                  color: AppColors.dfaGreen)),
                          const SizedBox(height: 5),
                          Text(
                              'This one beat your daily average by 34%. The 14.2 deductible miles are worth \$9.94 against income — logged automatically from the trip GPS trace.',
                              style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: AppColors.dfaInk2)),
                        ],
                      ),
                    ),
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

class _FareLine extends StatelessWidget {
  const _FareLine(this.label, this.value, this.valueColor, this.isLast);
  final String label, value;
  final Color? valueColor;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 12, color: AppColors.dfaInk2)),
          Text(value,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.dfaInk)),
        ],
      ),
    );
  }
}
