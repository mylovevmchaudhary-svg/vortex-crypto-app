import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Glassmorphic dark Web3 card with subtle highlight border and optional glow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.borderColor,
    this.gradient,
    this.glowColor,
    this.borderRadius = 20,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? borderColor;
  final Gradient? gradient;
  final Color? glowColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient == null ? AppColors.surfaceCard : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.borderSubtle,
        width: 1.1,
      ),
      boxShadow: glowColor != null
          ? <BoxShadow>[
              BoxShadow(
                color: glowColor!.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
          : const <BoxShadow>[
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Padding(
      padding: margin,
      child: Semantics(
        button: true,
        container: true,
        label: semanticLabel,
        child: MergeSemantics(
          child: Container(
            decoration: decoration,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(borderRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                focusColor: AppColors.cyan.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(borderRadius),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// High-contrast metallic gold CTA button for primary crypto actions.
class GoldGradientButton extends StatelessWidget {
  const GoldGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.gradient,
    this.textColor = const Color(0xFF1A1100),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final Gradient? gradient;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final effectiveMinHeight = math.max(48.0, height);
    final effectiveTextColor =
        (enabled || isLoading) ? textColor : AppColors.textSecondary;

    return Semantics(
      button: true,
      enabled: enabled,
      label: isLoading ? '$label, loading' : label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: effectiveMinHeight),
        child: Container(
          decoration: BoxDecoration(
            color: (enabled || isLoading) ? null : AppColors.surfaceElevated,
            gradient: (enabled || isLoading)
                ? (gradient ?? AppColors.goldGradient)
                : null,
            borderRadius: BorderRadius.circular(16),
            border: (enabled || isLoading)
                ? null
                : Border.all(color: AppColors.borderHighlight),
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: enabled ? onPressed : null,
              focusColor: AppColors.cyan.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: textColor,
                            semanticsLabel: '$label loading',
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (icon != null) ...<Widget>[
                              Icon(icon, color: effectiveTextColor, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: effectiveTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined translucent action button for secondary Web3 controls.
class CyberOutlineButton extends StatelessWidget {
  const CyberOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.accentColor = AppColors.cyan,
    this.height = 48,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color accentColor;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final minHeight = math.max(48.0, height);
    final button = ConstrainedBox(
      constraints: BoxConstraints(minWidth: 48, minHeight: minHeight),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(48, minHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: accentColor,
          backgroundColor: accentColor.withValues(alpha: 0.08),
          side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    if (semanticLabel == null) return button;

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: button,
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

/// Custom-painted metallic 3D Vortex Coin emblem.
class VortexCoinEmblem extends StatelessWidget {
  const VortexCoinEmblem({
    super.key,
    this.size = 44,
    this.showGlow = true,
  });

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: showGlow
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: size * 0.45,
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          size: Size.square(size),
          painter: _VortexCoinPainter(),
        ),
      ),
    );
  }
}

class _VortexCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rimPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.35),
        colors: <Color>[
          AppColors.goldBright,
          AppColors.gold,
          AppColors.goldDeep,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, rimPaint);

    final innerPaint = Paint()..color = const Color(0xFF141008);
    canvas.drawCircle(center, radius * 0.78, innerPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..color = AppColors.gold.withValues(alpha: 0.55);
    canvas.drawCircle(center, radius * 0.68, ringPaint);

    final vPath = Path()
      ..moveTo(center.dx - radius * 0.34, center.dy - radius * 0.24)
      ..lineTo(center.dx, center.dy + radius * 0.34)
      ..lineTo(center.dx + radius * 0.34, center.dy - radius * 0.24)
      ..lineTo(center.dx + radius * 0.17, center.dy - radius * 0.24)
      ..lineTo(center.dx, center.dy + radius * 0.08)
      ..lineTo(center.dx - radius * 0.17, center.dy - radius * 0.24)
      ..close();

    final crestPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[AppColors.goldBright, AppColors.gold],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(vPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TokenomicsSlice {
  const TokenomicsSlice({
    required this.label,
    required this.percent,
    required this.amountLabel,
    required this.color,
  });

  final String label;
  final double percent;
  final String amountLabel;
  final Color color;
}

class TokenomicsDonutChart extends StatelessWidget {
  const TokenomicsDonutChart({
    super.key,
    required this.slices,
    this.size = 150,
  });

  final List<TokenomicsSlice> slices;
  final double size;

  @override
  Widget build(BuildContext context) {
    final summary = slices
        .map((s) => '${s.label}: ${s.percent.toInt()}%')
        .join(', ');
    return Semantics(
      image: true,
      label: 'Tokenomics 2 billion total supply breakdown: $summary',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DonutChartPainter(slices: slices),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '2.0B',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'TOTAL SUPPLY',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.slices});

  final List<TokenomicsSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.16;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var startAngle = -math.pi / 2;
    const gap = 0.04;

    for (final slice in slices) {
      final sweep = (2 * math.pi * (slice.percent / 100)) - gap;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = slice.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => false;
}
