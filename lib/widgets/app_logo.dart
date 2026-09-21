import 'package:flutter/material.dart';

import '../branding.dart';

/// One toe of the paw, in a normalised 1x1 box.
class _Toe {
  const _Toe(this.cx, this.cy, this.rx, this.ry, this.rotation);
  final double cx, cy, rx, ry, rotation;
}

const List<_Toe> _toes = [
  _Toe(0.175, 0.385, 0.098, 0.128, -0.45),
  _Toe(0.385, 0.265, 0.105, 0.140, -0.16),
  _Toe(0.615, 0.265, 0.105, 0.140, 0.16),
  _Toe(0.825, 0.385, 0.098, 0.128, 0.45),
];

/// Paw glyph drawn from vectors so it stays crisp at any size and recolours
/// with the theme. The same geometry is mirrored in `assets/icon/app_icon.svg`,
/// which is what generates the launcher icons -- change both together.
class PawMark extends StatelessWidget {
  const PawMark({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PawPainter(color)),
    );
  }
}

class _PawPainter extends CustomPainter {
  const _PawPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    for (final toe in _toes) {
      canvas.save();
      canvas.translate(toe.cx * s, toe.cy * s);
      canvas.rotate(toe.rotation);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: toe.rx * 2 * s,
          height: toe.ry * 2 * s,
        ),
        paint,
      );
      canvas.restore();
    }

    canvas.drawPath(
      Path()
        ..moveTo(0.500 * s, 0.455 * s)
        ..cubicTo(0.660 * s, 0.455 * s, 0.815 * s, 0.575 * s, 0.815 * s, 0.705 * s)
        ..cubicTo(0.815 * s, 0.845 * s, 0.685 * s, 0.925 * s, 0.500 * s, 0.925 * s)
        ..cubicTo(0.315 * s, 0.925 * s, 0.185 * s, 0.845 * s, 0.185 * s, 0.705 * s)
        ..cubicTo(0.185 * s, 0.575 * s, 0.340 * s, 0.455 * s, 0.500 * s, 0.455 * s)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PawPainter oldDelegate) => oldDelegate.color != color;
}

/// The paw on a rounded tile, for places that need a self-contained mark.
class PawBadge extends StatelessWidget {
  const PawBadge({
    super.key,
    required this.size,
    required this.background,
    required this.foreground,
  });

  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Center(child: PawMark(size: size * 0.78, color: foreground)),
    );
  }
}

/// App bar mark: the brand pack's square icon, or the drawn paw.
class BrandAppBarIcon extends StatelessWidget {
  const BrandAppBarIcon({super.key, required this.brand, this.size = 28});

  final Brand brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = brand.iconAsset;
    final fallback = PawMark(size: size, color: Colors.white);
    if (icon == null) return Center(child: fallback);
    return Center(
      child: Image.asset(
        icon,
        height: size,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

/// Header logo: the brand pack's wordmark image, or the drawn paw plus the
/// app title set in the app's own type.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.brand, this.height = 44});

  final Brand brand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final wordmark = brand.wordmarkAsset;
    if (wordmark == null) return _drawn(context);
    return Image.asset(
      wordmark,
      height: height,
      errorBuilder: (context, error, stackTrace) => _drawn(context),
    );
  }

  Widget _drawn(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PawBadge(
          size: height,
          background: scheme.primary,
          foreground: Colors.white,
        ),
        SizedBox(width: height * 0.34),
        Text(
          brand.appTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.primary,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }
}
