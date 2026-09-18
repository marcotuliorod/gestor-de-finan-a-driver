// Shared low-level widgets for the DFA design system
import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DfaStatusBar extends StatelessWidget {
  const DfaStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 11, letterSpacing: 0.04, color: AppColors.dfaInk3)),
          Row(
            children: [
              Text('LTE',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 11, color: AppColors.dfaInk3)),
              const SizedBox(width: 8),
              Text('84%',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 11, color: AppColors.dfaInk3)),
            ],
          ),
        ],
      ),
    );
  }
}

class DfaHeader extends StatelessWidget {
  const DfaHeader({
    super.key,
    required this.kicker,
    required this.title,
    this.weekLabel = 'WK 38',
    this.weekRange = 'SEP 15–21',
    this.initials = 'MR',
  });

  final String kicker;
  final String title;
  final String weekLabel;
  final String weekRange;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.dfaLine2, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        letterSpacing: 0.18,
                        color: AppColors.dfaInk4)),
                const SizedBox(height: 3),
                Text(title,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01,
                        color: AppColors.dfaInk)),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(weekLabel,
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 10, color: AppColors.dfaInk3)),
                  Text(weekRange,
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 10, color: AppColors.dfaInk3)),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B2027),
                  border: Border.all(color: const Color(0xFF2A323B)),
                ),
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dfaGreen)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DfaStatGrid extends StatelessWidget {
  const DfaStatGrid({super.key, required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dfaLine),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.dfaLine,
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Container(width: 1, color: AppColors.dfaLine),
            Expanded(
              child: Container(
                color: AppColors.dfaRaised,
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(items[i].label,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 9,
                            letterSpacing: 0.1,
                            color: AppColors.dfaInk4)),
                    const SizedBox(height: 4),
                    Text(items[i].value,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: items[i].valueColor ?? AppColors.dfaInk)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;
}

List<_StatItem> dfaStats(List<(String, String, Color?)> data) =>
    data.map((e) => _StatItem(e.$1, e.$2, valueColor: e.$3)).toList();

class DfaInsightCard extends StatelessWidget {
  const DfaInsightCard({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.age,
    required this.title,
    required this.body,
    required this.actionLabel,
    this.onTap,
  });

  final String category;
  final Color categoryColor;
  final String age;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dfaRaised,
          border: Border(
            top: BorderSide(color: AppColors.dfaLine),
            right: BorderSide(color: AppColors.dfaLine),
            bottom: BorderSide(color: AppColors.dfaLine),
            left: BorderSide(color: categoryColor, width: 2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 9,
                        letterSpacing: 0.12,
                        color: categoryColor)),
                Text(age,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 9, color: AppColors.dfaInk5)),
              ],
            ),
            const SizedBox(height: 5),
            Text(title,
                style: GoogleFonts.ibmPlexSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.dfaInk)),
            const SizedBox(height: 4),
            Text(body,
                style: GoogleFonts.ibmPlexSans(
                    fontSize: 12, height: 1.45, color: AppColors.dfaInk2)),
            const SizedBox(height: 9),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A222C),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(actionLabel,
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dfaInk)),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    child: Text('Dismiss',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 10, color: AppColors.dfaInk5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DfaSectionLabel extends StatelessWidget {
  const DfaSectionLabel(this.text, {super.key, this.trailingLabel, this.onTrailingTap});
  final String text;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
            style: GoogleFonts.ibmPlexMono(
                fontSize: 10, letterSpacing: 0.16, color: AppColors.dfaInk3)),
        if (trailingLabel != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(trailingLabel!,
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 10, color: AppColors.dfaBlue)),
          ),
      ],
    );
  }
}

class DfaSegmentedControl extends StatelessWidget {
  const DfaSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelect,
  });

  final List<String> segments;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dfaLine),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.dfaLine,
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) Container(width: 1, color: AppColors.dfaLine),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: i == selected
                      ? const Color(0xFF1B2531)
                      : AppColors.dfaRaised,
                  child: Text(
                    segments[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        letterSpacing: 0.08,
                        color: i == selected
                            ? AppColors.dfaInk
                            : const Color(0xFF6B7785)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DfaListTile extends StatelessWidget {
  const DfaListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingSub,
    this.trailingColor,
    this.isLast = false,
    this.leftAccentColor,
    this.onTap,
    this.leading,
  });

  final String title;
  final Widget? subtitle;
  final String? trailing;
  final String? trailingSub;
  final Color? trailingColor;
  final bool isLast;
  final Color? leftAccentColor;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    Widget tile = Container(
      decoration: BoxDecoration(
        color: AppColors.dfaRaised,
        border: leftAccentColor != null
            ? Border(
                top: BorderSide(color: AppColors.dfaLine2),
                bottom: isLast
                    ? BorderSide.none
                    : BorderSide(color: AppColors.dfaLine2),
                left: BorderSide(color: leftAccentColor!, width: 2),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(trailing!,
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: trailingColor ?? AppColors.dfaInk)),
                if (trailingSub != null)
                  Text(trailingSub!,
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 10, color: AppColors.dfaInk4)),
              ],
            ),
        ],
      ),
    );

    if (onTap != null) {
      tile = GestureDetector(onTap: onTap, child: tile);
    }

    if (leftAccentColor == null) {
      tile = Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: AppColors.dfaLine2),
          ),
        ),
        child: tile,
      );
    }

    return tile;
  }
}

class DfaCard extends StatelessWidget {
  const DfaCard({super.key, required this.child, this.onTap, this.color});
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget w = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.dfaPanel,
        border: Border.all(color: AppColors.dfaLine),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
    if (onTap != null) w = GestureDetector(onTap: onTap, child: w);
    return w;
  }
}

Widget dfaMonoLabel(String text, {double size = 10, Color? color, double? spacing}) =>
    Text(text,
        style: GoogleFonts.ibmPlexMono(
            fontSize: size,
            letterSpacing: spacing ?? 0.14,
            color: color ?? AppColors.dfaInk4));

Widget dfaMonoBig(String text, {double size = 34, Color? color}) =>
    Text(text,
        style: GoogleFonts.ibmPlexMono(
            fontSize: size,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.02,
            color: color ?? AppColors.dfaInk));
