import 'package:flutter/material.dart';

import '../design/taskflow_tokens.dart';

/// The 20×20 rounded-square checkbox that fronts every task row.
///
/// Unchecked is a 1.5px hairline square; checked fills with the accent and
/// draws a white tick.
class TfCheckbox extends StatelessWidget {
  const TfCheckbox({
    super.key,
    required this.checked,
    this.onTap,
    this.size = TaskFlowTokens.checkbox,
    this.borderColor,
  });

  final bool checked;
  final VoidCallback? onTap;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? palette.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusCheckbox),
        border: checked
            ? null
            : Border.all(
                color: borderColor ?? palette.controlBorder, width: 1.5),
      ),
      child: checked
          ? Icon(Icons.check_rounded, size: size * 0.6, color: Colors.white)
          : null,
    );

    final tap = onTap;
    if (tap == null) return box;
    return _TapTarget(onTap: tap, size: size, child: box);
  }
}

/// Grows a small control's hit area without growing the space it occupies, so
/// rows stay aligned to the gutter while still being comfortable to tap.
class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.onTap,
    required this.size,
    required this.child,
    this.slop = 10,
  });

  final VoidCallback onTap;
  final double size;
  final Widget child;
  final double slop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OverflowBox(
        maxWidth: size + slop * 2,
        maxHeight: size + slop * 2,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: size + slop * 2,
            height: size + slop * 2,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// A checklist bullet: a hollow accent circle while open, a grey tick once done.
class TfChecklistMark extends StatelessWidget {
  const TfChecklistMark({super.key, required this.checked, this.onTap});

  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final mark = SizedBox(
      width: 15,
      height: 15,
      child: checked
          ? Icon(Icons.check_rounded, size: 15, color: palette.textTertiary)
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.accent, width: 1.7),
              ),
            ),
    );
    final tap = onTap;
    if (tap == null) return mark;
    return _TapTarget(onTap: tap, size: 15, slop: 8, child: mark);
  }
}

/// A blue section header sitting over a hairline — the redesign's replacement
/// for card-per-section grouping.
class TfSectionHeader extends StatelessWidget {
  const TfSectionHeader({
    super.key,
    required this.title,
    this.onAdd,
    this.onOverflow,
    this.padding = const EdgeInsets.only(top: 24, bottom: 7),
  });

  final String title;
  final VoidCallback? onAdd;
  final VoidCallback? onOverflow;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TaskFlowText.sectionHeader(palette.accent)),
              ),
              if (onAdd != null)
                TfGlyphButton(
                  icon: Icons.add_rounded,
                  color: palette.accent,
                  size: 15,
                  onTap: onAdd!,
                ),
              if (onOverflow != null)
                TfGlyphButton(
                  icon: Icons.more_horiz_rounded,
                  color: palette.accent,
                  size: 18,
                  onTap: onOverflow!,
                ),
            ],
          ),
        ),
        Container(height: 1, color: palette.separator),
      ],
    );
  }
}

/// A bare icon with a comfortable tap target and no Material ink chrome.
class TfGlyphButton extends StatelessWidget {
  const TfGlyphButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 20,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Icon(icon, size: size, color: color ?? context.palette.accent),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The circular grey button used for the nav bar's overflow and for the
/// close affordance on sheets.
class TfCircleButton extends StatelessWidget {
  const TfCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.diameter = 30,
    this.iconSize = 16,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double diameter;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: palette.fill, shape: BoxShape.circle),
        child: Icon(icon, size: iconSize, color: palette.textSecondary),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Back chevron on the left, free-form middle, trailing actions on the right.
class TfNavBar extends StatelessWidget {
  const TfNavBar({
    super.key,
    this.onBack,
    this.middle,
    this.trailing = const [],
  });

  final VoidCallback? onBack;
  final Widget? middle;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: Row(
        children: [
          if (onBack != null)
            TfGlyphButton(
              icon: Icons.chevron_left_rounded,
              size: 28,
              color: palette.textPrimary,
              onTap: onBack!,
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 36),
          Expanded(
            child: middle == null
                ? const SizedBox.shrink()
                : Center(child: middle!),
          ),
          ...trailing,
        ],
      ),
    );
  }
}

/// Grey count pill — `2/5` checklist progress, tag counts.
class TfBadge extends StatelessWidget {
  const TfBadge({super.key, required this.label, this.fontSize = 12});

  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: palette.groupedFill,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusChip),
      ),
      child: Text(
        label,
        style: TaskFlowText.badge(palette.textTertiary)
            .copyWith(fontSize: fontSize),
      ),
    );
  }
}

/// The red "today" / deadline flag that trails an urgent row.
class TfFlag extends StatelessWidget {
  const TfFlag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_rounded, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// 29×29 solid rounded square with a white glyph — the Home list icons.
class TfSystemIcon extends StatelessWidget {
  const TfSystemIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 29,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: size * 0.58, color: Colors.white),
    );
  }
}

/// A project's completion ring, drawn as a thick pie wedge clipped to a circle
/// exactly as the design's stroke-dasharray trick renders it.
class TfProjectRing extends StatelessWidget {
  const TfProjectRing({super.key, required this.progress, this.size = 17});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProjectRingPainter(
          progress: progress.clamp(0.0, 1.0),
          ring: palette.controlBorder,
          fill: palette.textTertiary,
        ),
      ),
    );
  }
}

class _ProjectRingPainter extends CustomPainter {
  const _ProjectRingPainter({
    required this.progress,
    required this.ring,
    required this.fill,
  });

  final double progress;
  final Color ring;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 0.85;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5707963, // 12 o'clock
        progress * 6.2831853,
        true,
        Paint()..color = fill,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..color = ring,
    );
  }

  @override
  bool shouldRepaint(_ProjectRingPainter old) =>
      old.progress != progress || old.ring != ring || old.fill != fill;
}

/// The 58px blue action button, with the accent glow from the design.
class TfFab extends StatelessWidget {
  const TfFab({super.key, required this.onTap, this.icon = Icons.add_rounded});

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: 'New to-do',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: palette.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: palette.accent.withOpacity(0.55),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

/// Filled accent pill — Save, Done.
class TfPillButton extends StatelessWidget {
  const TfPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  final String label;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: palette.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: TaskFlowText.button(Colors.white)),
      ),
    );
  }
}
