import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/ui/widgets/dfa_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
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
                kicker: 'DEDUCTIONS & COSTS', title: 'Money out'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DfaSegmentedControl(
                      segments: const ['EXPENSES', 'MILEAGE', 'VEHICLE'],
                      selected: _tab,
                      onSelect: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 14),
                    if (_tab == 0) const _ExpensesTab(),
                    if (_tab == 1) const _MileageTab(),
                    if (_tab == 2) const _VehicleTab(),
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

class _ExpensesTab extends StatelessWidget {
  const _ExpensesTab();

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
                    dfaMonoLabel('SEPT SPEND', spacing: 0.12),
                    const SizedBox(height: 4),
                    dfaMonoBig(r'$1,042', size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DfaCard(
                color: AppColors.dfaRaised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dfaMonoLabel('DEDUCTIBLE', spacing: 0.12),
                    const SizedBox(height: 4),
                    dfaMonoBig(r'$918', size: 22, color: AppColors.dfaGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CategoryBars(),
        const SizedBox(height: 16),
        _PendingBanner(),
        const SizedBox(height: 12),
        _ExpenseList(),
      ],
    );
  }
}

class _CategoryBars extends StatelessWidget {
  static const _cats = [
    ('Fuel', r'$486', 47, AppColors.dfaGreen),
    ('Maintenance & repair', r'$212', 20, AppColors.dfaBlue),
    ('Insurance', r'$164', 16, AppColors.dfaViolet),
    ('Phone & data', r'$78', 7, AppColors.dfaAmber),
    ('Supplies & car wash', r'$102', 10, Color(0xFF6B7785)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final c in _cats) ...[
          Row(
            children: [
              Expanded(
                child: Text(c.$1,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10.5, color: AppColors.dfaInk2)),
              ),
              Text('${c.$2} ',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dfaInk)),
              Text('${c.$3}%',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10.5, color: AppColors.dfaInk4)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              color: const Color(0xFF1B2430),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: c.$3 / 100.0,
                child: Container(color: c.$4),
              ),
            ),
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _PendingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1508),
        border: Border.all(color: const Color(0xFF3A2F10)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('3 receipts need a category',
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 12, color: AppColors.dfaAmber)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.dfaAmber,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('REVIEW',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B0E11))),
          ),
        ],
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  static const _items = [
    ('Costco Gas · Halsey', 'SEP 18', 'FUEL', 'AI', r'$41.80', '100% DED'),
    ('Les Schwab · rotate + balance', 'SEP 16', 'MAINT', 'AI', r'$64.00',
        '100% DED'),
    ('Progressive · commercial rider', 'SEP 15', 'INSURANCE', 'RULE',
        r'$164.00', '100% DED'),
    ('Shell · Airport Blvd', 'SEP 14', 'FUEL', 'AI', r'$52.15', '100% DED'),
    ('Verizon · unlimited plan', 'SEP 12', 'PHONE', 'SPLIT', r'$92.00',
        '85% DED'),
    ('Target · phone mount, wipes', 'SEP 11', 'SUPPLIES', 'AI', r'$38.42',
        '100% DED'),
    ('Chevron · I-84 exit 6', 'SEP 09', 'FUEL', 'AI', r'$47.90', '100% DED'),
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
            _ExpenseLine(
              title: _items[i].$1,
              date: _items[i].$2,
              cat: _items[i].$3,
              badge: _items[i].$4,
              amount: _items[i].$5,
              ded: _items[i].$6,
              isLast: i == _items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ExpenseLine extends StatelessWidget {
  const _ExpenseLine({
    required this.title,
    required this.date,
    required this.cat,
    required this.badge,
    required this.amount,
    required this.ded,
    required this.isLast,
  });

  final String title, date, cat, badge, amount, ded;
  final bool isLast;

  Color get _badgeColor {
    switch (badge) {
      case 'SPLIT':
        return AppColors.dfaAmber;
      case 'RULE':
        return AppColors.dfaBlue;
      default:
        return AppColors.dfaGreen;
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
                Text(title,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dfaInk),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(date,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 9, color: AppColors.dfaInk4)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A222C),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(cat,
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 9, color: AppColors.dfaInk3)),
                    ),
                    const SizedBox(width: 6),
                    Text(badge,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 9, color: _badgeColor)),
                  ],
                ),
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
              Text(ded,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 9.5, color: AppColors.dfaInk4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MileageTab extends StatelessWidget {
  const _MileageTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DfaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dfaMonoLabel('YTD DEDUCTIBLE MILES'),
              const SizedBox(height: 2),
              dfaMonoBig('28,416'),
              const SizedBox(height: 12),
              const Divider(color: AppColors.dfaLine, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dfaMonoLabel('IRS RATE'),
                      const SizedBox(height: 3),
                      Text(r'$0.70/mi',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dfaInk)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      dfaMonoLabel('DEDUCTION VALUE'),
                      const SizedBox(height: 3),
                      Text(r'$19,891',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dfaGreen)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _MileageBarChart(),
        const SizedBox(height: 14),
        const DfaSectionLabel('AUTO-TRACKED · TODAY'),
        const SizedBox(height: 8),
        _MileageSegments(),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.dfaRaised,
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IRS-compliant log · 1,412 entries',
                  style: GoogleFonts.ibmPlexSans(
                      fontSize: 12, color: AppColors.dfaInk2)),
              Text('EXPORT CSV',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dfaBlue)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MileageBarChart extends StatelessWidget {
  static const _months = [
    ('J', 44, false),
    ('F', 38, false),
    ('M', 52, false),
    ('A', 46, false),
    ('M', 58, false),
    ('J', 49, false),
    ('J', 62, true),
    ('A', 55, true),
    ('S', 34, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dfaRaised,
        border: Border.all(color: AppColors.dfaLine),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final m in _months)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: m.$2 / 70.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: m.$3
                                ? (m.$1 == 'S'
                                    ? AppColors.dfaGreen
                                    : const Color(0xFF256B47))
                                : const Color(0xFF1F3A2C),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(m.$1,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 8.5, color: AppColors.dfaInk5)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MileageSegments extends StatelessWidget {
  static const _segs = [
    ('Home → PDX staging lot', '6:28a · Business', '11.4', true),
    ('PDX → Pearl District', '7:12a · On trip', '14.2', true),
    ('Pearl → NW 23rd (deadhead)', '7:51a · Between trips', '2.6', true),
    ('Fred Meyer → Home', '3:10p · Personal', '4.1', false),
    ('Home → Moda Center', '9:22p · Business', '8.9', true),
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
          for (var i = 0; i < _segs.length; i++)
            _SegRow(
              title: _segs[i].$1,
              sub: _segs[i].$2,
              miles: _segs[i].$3,
              isDed: _segs[i].$4,
              isLast: i == _segs.length - 1,
            ),
        ],
      ),
    );
  }
}

class _SegRow extends StatelessWidget {
  const _SegRow(
      {required this.title,
      required this.sub,
      required this.miles,
      required this.isDed,
      required this.isLast});
  final String title, sub, miles;
  final bool isDed, isLast;

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
                Text(title,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dfaInk),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(sub,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 9.5, color: AppColors.dfaInk4)),
              ],
            ),
          ),
          Text(miles,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dfaInk)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isDed
                  ? const Color(0xFF12261A)
                  : const Color(0xFF1A222C),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(isDed ? 'DED' : 'PERS',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    color: isDed ? AppColors.dfaGreen2 : AppColors.dfaInk3)),
          ),
        ],
      ),
    );
  }
}

class _VehicleTab extends StatelessWidget {
  const _VehicleTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DfaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2019 Toyota Camry LE',
                          style: GoogleFonts.ibmPlexSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dfaInk)),
                      const SizedBox(height: 3),
                      dfaMonoLabel('ODO 187,402 mi · 4 yrs in service',
                          spacing: 0),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      dfaMonoLabel('COST / MILE'),
                      const SizedBox(height: 2),
                      Text(r'$0.214',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dfaAmber)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.dfaLine, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dfaMonoLabel('YTD SERVICE'),
                        const SizedBox(height: 3),
                        Text(r'$2,184',
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dfaInk)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dfaMonoLabel('YTD FUEL'),
                        const SizedBox(height: 3),
                        Text(r'$4,910',
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dfaInk)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dfaMonoLabel('DEPREC.'),
                        const SizedBox(height: 3),
                        Text(r'$1,640',
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dfaInk)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const DfaSectionLabel('UPCOMING'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: const Column(
            children: [
              _MaintRow('Front brake pads & rotors', 'DUE IN ~1,200 MI · EST OCT 4',
                  r'$310', AppColors.dfaRed, false),
              _MaintRow('Synthetic oil change', 'DUE IN ~2,600 MI · EST OCT 21',
                  r'$78', AppColors.dfaAmber, false),
              _MaintRow('State safety inspection', 'DUE DEC 01', r'$45',
                  Color(0xFF2E3946), true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const DfaSectionLabel('HISTORY'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dfaLine),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: const Column(
            children: [
              _HistoryRow('Tire rotation & balance', 'SEP 16 · 186,940 mi',
                  r'$64.00', false),
              _HistoryRow('Cabin + engine air filter', 'AUG 28 · 185,510 mi',
                  r'$52.40', false),
              _HistoryRow('Rear shocks', 'JUL 09 · 181,220 mi', r'$612.00',
                  false),
              _HistoryRow('Synthetic oil change', 'JUN 14 · 179,060 mi',
                  r'$78.00', true),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaintRow extends StatelessWidget {
  const _MaintRow(this.title, this.sub, this.est, this.accentColor, this.isLast);
  final String title, sub, est;
  final Color accentColor;
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
          left: BorderSide(color: accentColor, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        color: AppColors.dfaInk)),
                const SizedBox(height: 3),
                Text(sub,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 9.5, color: AppColors.dfaInk4)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(est,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dfaInk)),
              const SizedBox(height: 2),
              Text('EST',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 9, color: AppColors.dfaInk4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow(this.title, this.sub, this.amount, this.isLast);
  final String title, sub, amount;
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
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
          Text(amount,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dfaInk)),
        ],
      ),
    );
  }
}
