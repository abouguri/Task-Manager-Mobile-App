import 'package:flutter/material.dart';

/// Palette and type scale for the list-first redesign.
///
/// Values are lifted from `TaskFlow Redesign.dc.html`: the app moves off the
/// old sage set onto iOS system colours, with blue as the single accent.
class TaskFlowTokens {
  // ---- Accents (shared across brightnesses) -------------------------------
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryPressed = Color(0xFF0A84FF);
  static const Color primarySoft = Color(0x29007AFF); // 16% blue
  static const Color danger = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFC008);

  /// System-list accents, in Home order.
  static const Color inboxAccent = Color(0xFF007AFF);
  static const Color todayAccent = Color(0xFFFFC008);
  static const Color upcomingAccent = Color(0xFFFF3B5C);
  static const Color anytimeAccent = Color(0xFF30B0A0);
  static const Color somedayAccent = Color(0xFFC8A96A);
  static const Color logbookAccent = Color(0xFF34C759);
  static const Color eveningAccent = Color(0xFF5A7DFF);

  // ---- Light neutrals -----------------------------------------------------
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2F2F7);
  static const Color fill = Color(0xFFE9E9EB);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF3A3A3C);
  static const Color textTertiary = Color(0xFF8A8A8E);
  static const Color textQuaternary = Color(0xFFA1A1A6);
  static const Color border = Color(0xFFE5E5EA);
  static const Color hairline = Color(0xFFEFEFF2);
  static const Color controlBorder = Color(0xFFC7C7CC);

  // ---- Multi-select -------------------------------------------------------
  static const Color selectionFill = Color(0xFFD8E6FB);
  static const Color selectionBorder = Color(0xFF9DB6D6);
  static const Color selectionSubtitle = Color(0xFF7C8CA1);

  // ---- Radii --------------------------------------------------------------
  static const double radiusCheckbox = 6;
  static const double radiusChip = 9;
  static const double radiusSm = 11;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusToolbar = 22;

  // ---- Spacing ------------------------------------------------------------
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space22 = 22;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;

  /// Horizontal gutter used by every list screen.
  static const double gutter = 22;

  /// Checkbox / open-circle hit size.
  static const double checkbox = 20;
}

/// Brightness-resolved surface colours. Screens read these through
/// `context.palette` rather than reaching for [TaskFlowTokens] directly, so the
/// same layout code renders correctly in dark mode.
@immutable
class TaskFlowPalette extends ThemeExtension<TaskFlowPalette> {
  const TaskFlowPalette({
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.groupedFill,
    required this.fill,
    required this.footerFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
    required this.separator,
    required this.hairline,
    required this.controlBorder,
    required this.accent,
    required this.danger,
    required this.success,
    required this.scrim,
    required this.toolbar,
    required this.selectionFill,
    required this.selectionBorder,
    required this.selectionSubtitle,
  });

  final Color background;
  final Color surface;

  /// Background behind an inline-expanded task, one step off [surface].
  final Color elevatedSurface;

  /// Filled blocks inside a screen — the Today agenda card, badges, headings.
  final Color groupedFill;

  /// Interactive greys — search pill, round icon buttons.
  final Color fill;

  /// Footer strip of the quick-capture sheet.
  final Color footerFill;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textQuaternary;

  /// Hairline under a section header.
  final Color separator;

  /// Lighter hairline used inside cards.
  final Color hairline;

  /// Unchecked checkbox stroke.
  final Color controlBorder;

  final Color accent;
  final Color danger;
  final Color success;

  /// Dim behind quick capture / quick find.
  final Color scrim;

  /// Floating dark toolbar in multi-select.
  final Color toolbar;

  final Color selectionFill;
  final Color selectionBorder;
  final Color selectionSubtitle;

  static const TaskFlowPalette light = TaskFlowPalette(
    background: TaskFlowTokens.background,
    surface: TaskFlowTokens.surface,
    elevatedSurface: Color(0xFFFBFBFD),
    groupedFill: TaskFlowTokens.surfaceMuted,
    fill: TaskFlowTokens.fill,
    footerFill: Color(0xFFF7F7F9),
    textPrimary: TaskFlowTokens.textPrimary,
    textSecondary: TaskFlowTokens.textSecondary,
    textTertiary: TaskFlowTokens.textTertiary,
    textQuaternary: TaskFlowTokens.textQuaternary,
    separator: TaskFlowTokens.border,
    hairline: TaskFlowTokens.hairline,
    controlBorder: TaskFlowTokens.controlBorder,
    accent: TaskFlowTokens.primary,
    danger: TaskFlowTokens.danger,
    success: TaskFlowTokens.success,
    scrim: Color(0x471C1C1E),
    toolbar: Color(0xEB26262A),
    selectionFill: TaskFlowTokens.selectionFill,
    selectionBorder: TaskFlowTokens.selectionBorder,
    selectionSubtitle: TaskFlowTokens.selectionSubtitle,
  );

  static const TaskFlowPalette dark = TaskFlowPalette(
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    elevatedSurface: Color(0xFF141416),
    groupedFill: Color(0xFF1C1C1E),
    fill: Color(0xFF2C2C2E),
    footerFill: Color(0xFF242426),
    textPrimary: Color(0xFFF2F2F7),
    textSecondary: Color(0xFFD1D1D6),
    textTertiary: Color(0xFF8E8E93),
    textQuaternary: Color(0xFF6C6C70),
    separator: Color(0xFF38383A),
    hairline: Color(0xFF2C2C2E),
    controlBorder: Color(0xFF48484A),
    accent: Color(0xFF0A84FF),
    danger: Color(0xFFFF453A),
    success: Color(0xFF32D74B),
    scrim: Color(0x8A000000),
    toolbar: Color(0xEB3A3A3C),
    selectionFill: Color(0xFF1B3358),
    selectionBorder: Color(0xFF3F5B7E),
    selectionSubtitle: Color(0xFF8FA4BD),
  );

  @override
  TaskFlowPalette copyWith({
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? groupedFill,
    Color? fill,
    Color? footerFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textQuaternary,
    Color? separator,
    Color? hairline,
    Color? controlBorder,
    Color? accent,
    Color? danger,
    Color? success,
    Color? scrim,
    Color? toolbar,
    Color? selectionFill,
    Color? selectionBorder,
    Color? selectionSubtitle,
  }) {
    return TaskFlowPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      groupedFill: groupedFill ?? this.groupedFill,
      fill: fill ?? this.fill,
      footerFill: footerFill ?? this.footerFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textQuaternary: textQuaternary ?? this.textQuaternary,
      separator: separator ?? this.separator,
      hairline: hairline ?? this.hairline,
      controlBorder: controlBorder ?? this.controlBorder,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      scrim: scrim ?? this.scrim,
      toolbar: toolbar ?? this.toolbar,
      selectionFill: selectionFill ?? this.selectionFill,
      selectionBorder: selectionBorder ?? this.selectionBorder,
      selectionSubtitle: selectionSubtitle ?? this.selectionSubtitle,
    );
  }

  @override
  TaskFlowPalette lerp(ThemeExtension<TaskFlowPalette>? other, double t) {
    if (other is! TaskFlowPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return TaskFlowPalette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      elevatedSurface: mix(elevatedSurface, other.elevatedSurface),
      groupedFill: mix(groupedFill, other.groupedFill),
      fill: mix(fill, other.fill),
      footerFill: mix(footerFill, other.footerFill),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      textQuaternary: mix(textQuaternary, other.textQuaternary),
      separator: mix(separator, other.separator),
      hairline: mix(hairline, other.hairline),
      controlBorder: mix(controlBorder, other.controlBorder),
      accent: mix(accent, other.accent),
      danger: mix(danger, other.danger),
      success: mix(success, other.success),
      scrim: mix(scrim, other.scrim),
      toolbar: mix(toolbar, other.toolbar),
      selectionFill: mix(selectionFill, other.selectionFill),
      selectionBorder: mix(selectionBorder, other.selectionBorder),
      selectionSubtitle: mix(selectionSubtitle, other.selectionSubtitle),
    );
  }
}

extension TaskFlowPaletteX on BuildContext {
  TaskFlowPalette get palette =>
      Theme.of(this).extension<TaskFlowPalette>() ?? TaskFlowPalette.light;
}

/// The type scale from the design doc. CSS `em` letter-spacing is converted to
/// logical pixels at each size (Flutter's `letterSpacing` is absolute).
class TaskFlowText {
  const TaskFlowText._();

  /// 700 · 27/1.1 · -0.03em — screen titles (Today, Inbox…).
  static TextStyle largeTitle(Color color) => TextStyle(
      color: color,
      fontSize: 27,
      height: 1.1,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.81);

  /// 700 · 24/1.15 · -0.03em — project title, upcoming day number.
  static TextStyle title1(Color color) => TextStyle(
      color: color,
      fontSize: 24,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.72);

  /// 600 · 17/1.2 · -0.02em — nav bar title.
  static TextStyle navTitle(Color color) => TextStyle(
      color: color,
      fontSize: 17,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.34);

  /// 600 · 17/1.25 · -0.01em — Home system-list rows.
  static TextStyle listTitle(Color color) => TextStyle(
      color: color,
      fontSize: 17,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.17);

  /// 600 · 16/1.25 — area name.
  static TextStyle areaTitle(Color color) => TextStyle(
      color: color, fontSize: 16, height: 1.25, fontWeight: FontWeight.w600);

  /// 600 · 15/1.2 · -0.01em — blue section headers.
  static TextStyle sectionHeader(Color color) => TextStyle(
      color: color,
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15);

  /// 400 · 16/1.25 · -0.01em — a task row's one line.
  static TextStyle taskTitle(Color color) => TextStyle(
      color: color,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.16);

  /// 400 · 17/1.25 · -0.01em — the title of an opened task.
  static TextStyle openTaskTitle(Color color) => TextStyle(
      color: color,
      fontSize: 17,
      height: 1.25,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.17);

  /// 400 · 16/1.3 — project row under an area.
  static TextStyle projectTitle(Color color) =>
      TextStyle(color: color, fontSize: 16, height: 1.3);

  /// 400 · 12.5/1.35 — the project/area line under a task title.
  static TextStyle meta(Color color) =>
      TextStyle(color: color, fontSize: 12.5, height: 1.35);

  /// 600 · 12.5/1.4 — calendar event time.
  static TextStyle eventTime(Color color) => TextStyle(
      color: color, fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600);

  /// 400 · 13.5/1.4 — calendar event title.
  static TextStyle eventTitle(Color color) =>
      TextStyle(color: color, fontSize: 13.5, height: 1.4);

  /// 600 · 14/1 — the weekday beside an Upcoming day number.
  static TextStyle dayLabel(Color color) => TextStyle(
      color: color, fontSize: 14, height: 1, fontWeight: FontWeight.w600);

  /// 500 · 12/1.4 — checklist / tag-count pills.
  static TextStyle badge(Color color) => TextStyle(
      color: color, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500);

  /// 400 · 14.5/1.5 — notes body inside an opened task.
  static TextStyle notes(Color color) =>
      TextStyle(color: color, fontSize: 14.5, height: 1.5);

  /// 400 · 15/1.3 — checklist item.
  static TextStyle checklistItem(Color color) =>
      TextStyle(color: color, fontSize: 15, height: 1.3);

  /// 500 · 12.5/1.3 — tag chip.
  static TextStyle tag(Color color) => TextStyle(
      color: color, fontSize: 12.5, height: 1.3, fontWeight: FontWeight.w500);

  /// 600 · 15/1 — filled buttons (Save, Done).
  static TextStyle button(Color color) => TextStyle(
      color: color, fontSize: 15, height: 1, fontWeight: FontWeight.w600);

  /// 500 · 15/1 — multi-select toolbar actions.
  static TextStyle toolbarAction(Color color) => TextStyle(
      color: color, fontSize: 15, height: 1, fontWeight: FontWeight.w500);

  /// 400 · 16/1 — plain blue text actions.
  static TextStyle textAction(Color color) =>
      TextStyle(color: color, fontSize: 16, height: 1);

  /// 400 · 15.5/1.25 — quick-find result.
  static TextStyle resultTitle(Color color) =>
      TextStyle(color: color, fontSize: 15.5, height: 1.25);
}
