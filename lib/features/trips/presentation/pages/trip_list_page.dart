import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  int _platform = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dfaBg,
      body: SafeArea(
        child: Column(
          children: [
            const DfaStatusBar(),
            const DfaHeader(
              kicker: '142 TRIPS · 7 DAYS',
              title: 'Trip log',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlatformFilters(
                      selected: _platform,
                      onSelect: (i) => setState(() => _platform = i),
                    ),
                    const SizedBox(height: 10),
                    DfaStatGrid(
                      items: dfaStats([
                        ('TRIPS', '12', null),
                        ('NET', r'$268', null),
                        ('MILES', '84', null),
                        (r'$/HR', r'$46', AppColors.dfaGreen),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    _TripTableHeader(),
                    const SizedBox(height: 6),
                    _TripTable(),
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

class _PlatformFilters extends StatelessWidget {
  const _PlatformFilters({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['ALL', 'UBER', 'LYFT', 'UBEREATS', 'DOORDASH'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF12261A)
                    : AppColors.dfaRaised,
                border: Border.all(
                  color: active ? AppColors.dfaGreen : const Color(0xFF232A32),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_labels[i],
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      letterSpacing: 0.06,
                      color: active
                          ? AppColors.dfaGreen2
                          : AppColors.dfaInk3)),
            ),
          );
        },
      ),
    );
  }
}

class _TripTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Text('TRIP',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 0.1,
                    color: AppColors.dfaInk5)),
          ),
          SizedBox(
            width: 60,
            child: Text('NET',
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 0.1,
                    color: AppColors.dfaInk5)),
          ),
          SizedBox(
            width: 62,
            child: Text('MI / MIN',
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 0.1,
                    color: AppColors.dfaInk5)),
          ),
          SizedBox(
            width: 56,
            child: Text(r'$/HR',
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 0.1,
                    color: AppColors.dfaInk5)),
          ),
        ],
      ),
    );
  }
}

class _TripTable extends StatelessWidget {
  static const _trips = [
    _TripRow('PDX Airport → Pearl District', 'UBER', '7:12a', r'$38.40',
        '14.2 / 31', r'$74/h', AppColors.dfaGreen),
    _TripRow('NW 23rd → OHSU Hill', 'UBER', '8:04a', r'$12.80', '3.1 / 11',
        r'$70/h', AppColors.dfaGreen),
    _TripRow('Lloyd Center → Convention Ctr', 'LYFT', '8:41a', r'$9.15',
        '1.8 / 7', r'$78/h', AppColors.dfaGreen),
    _TripRow('Sizzle Pie → Irvington (3 stops)', 'UBEREATS', '11:26a',
        r'$21.60', '5.4 / 34', r'$38/h', AppColors.dfaInk),
    _TripRow('Chipotle Burnside → Laurelhurst', 'DOORDASH', '12:10p',
        r'$8.95', '2.9 / 18', r'$30/h', AppColors.dfaRed),
    _TripRow('Hawthorne → PDX Airport', 'UBER', '1:48p', r'$41.20',
        '13.6 / 29', r'$85/h', AppColors.dfaGreen),
    _TripRow('Tin Shed → Alberta Arts', 'DOORDASH', '2:35p', r'$7.40',
        '1.6 / 15', r'$30/h', AppColors.dfaRed),
    _TripRow('Providence Park → Sellwood', 'LYFT', '4:02p', r'$24.70',
        '7.8 / 24', r'$62/h', AppColors.dfaGreen),
    _TripRow('Division St → Gresham', 'UBER', '5:19p', r'$33.05',
        '12.4 / 27', r'$73/h', AppColors.dfaGreen),
    _TripRow("Nong's → South Waterfront", 'UBEREATS', '6:44p', r'$14.25',
        '4.2 / 21', r'$41/h', AppColors.dfaInk),
    _TripRow('Moda Center → Beaverton', 'LYFT', '9:58p', r'$36.90',
        '11.1 / 26', r'$85/h', AppColors.dfaGreen),
    _TripRow('Old Town → Kenton', 'UBER', '11:22p', r'$19.80', '6.3 / 17',
        r'$70/h', AppColors.dfaGreen),
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
          for (var i = 0; i < _trips.length; i++)
            _trips[i]._build(context, i == _trips.length - 1),
        ],
      ),
    );
  }
}

class _TripRow {
  const _TripRow(this.title, this.platform, this.time, this.net, this.miMin,
      this.rate, this.rateColor);

  final String title, platform, time, net, miMin, rate;
  final Color rateColor;

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

  Widget _build(BuildContext context, bool isLast) {
    return GestureDetector(
      onTap: () => context.go('/app/trips/detail'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dfaRaised,
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(color: AppColors.dfaLine2),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dfaInk),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
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
                      Text(time,
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 9.5, color: AppColors.dfaInk4)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(net,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dfaInk)),
            ),
            SizedBox(
              width: 62,
              child: Text(miMin,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10.5, color: AppColors.dfaInk3)),
            ),
            SizedBox(
              width: 56,
              child: Text(rate,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: rateColor)),
            ),
          ],
        ),
      ),
    );
  }
}
