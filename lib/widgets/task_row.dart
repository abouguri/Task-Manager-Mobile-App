import 'package:flutter/material.dart';

import '../design/taskflow_tokens.dart';
import 'tf_widgets.dart';

/// One task, one line.
///
/// The row stays collapsed no matter how much the task carries — notes,
/// checklist and tags are reduced to the small trailing glyphs, and the full
/// content only appears when the row is opened in place.
class TfTaskRow extends StatelessWidget {
  const TfTaskRow({
    super.key,
    required this.title,
    this.subtitle,
    this.checked = false,
    this.onToggle,
    this.onTap,
    this.onLongPress,
    this.inlineBadge,
    this.trailing = const [],
    this.dense = false,
  });

  final String title;

  /// The project or area the task belongs to; omitted when it adds nothing.
  final String? subtitle;

  final bool checked;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Pill rendered immediately after the title (checklist progress in Upcoming).
  final String? inlineBadge;

  /// Glyphs pinned to the right edge — note marker, badge, tag, deadline.
  final List<Widget> trailing;

  /// Single-line layout used by Project detail, where rows carry no subtitle.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    final titleLine = inlineBadge == null
        ? Text(title,
            style: TaskFlowText.taskTitle(palette.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis)
        : Row(
            children: [
              Flexible(
                child: Text(title,
                    style: TaskFlowText.taskTitle(palette.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 6),
              TfBadge(label: inlineBadge!, fontSize: 11.5),
            ],
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment:
              dense ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Padding(
              // Nudges the box onto the title's cap height.
              padding: EdgeInsets.only(top: dense ? 0 : 1),
              child: TfCheckbox(checked: checked, onTap: onToggle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleLine,
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TaskFlowText.meta(palette.textQuaternary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            for (final glyph in trailing)
              Padding(
                padding: EdgeInsets.only(left: 8, top: dense ? 0 : 2),
                child: glyph,
              ),
          ],
        ),
      ),
    );
  }
}

/// The multi-select presentation of a row: a tinted band with a radio on the
/// right. The checkbox stays visible but inert — completion is not what a tap
/// means in this mode.
class TfSelectableTaskRow extends StatelessWidget {
  const TfSelectableTaskRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelect,
    this.subtitle,
    this.checked = false,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool checked;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        // The band bleeds 8px past the text gutter; the list compensates by
        // narrowing its own padding while selection is active.
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? palette.selectionFill : Colors.transparent,
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusChip),
        ),
        child: Row(
          children: [
            TfCheckbox(
              checked: checked,
              borderColor: selected ? palette.selectionBorder : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TaskFlowText.taskTitle(palette.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TaskFlowText.meta(selected
                          ? palette.selectionSubtitle
                          : palette.textQuaternary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _SelectionRadio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectionRadio extends StatelessWidget {
  const _SelectionRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? palette.accent : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: palette.controlBorder, width: 1.5),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

/// Trailing glyphs a collapsed row can carry.
class TfRowGlyphs {
  const TfRowGlyphs._();

  /// Marks that the task has notes attached.
  static Widget note(BuildContext context) => Icon(Icons.description_outlined,
      size: 14, color: context.palette.controlBorder);

  /// Marks that the task carries tags.
  static Widget tag(BuildContext context) =>
      Icon(Icons.sell_outlined, size: 14, color: context.palette.accent);

  /// A deadline, shown quietly unless it lands today.
  static Widget deadline(BuildContext context, String label,
      {bool urgent = false}) {
    final palette = context.palette;
    final color = urgent ? palette.danger : palette.textQuaternary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_rounded, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              height: 1,
              fontWeight: urgent ? FontWeight.w600 : FontWeight.w400,
            )),
      ],
    );
  }
}
