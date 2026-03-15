import 'package:flutter/material.dart';

/// Rounded wall mark for the Cypher feature.
///
/// Built as a native painter so it stays crisp at small icon sizes and can be
/// tinted with a single color for navigation usage.
class CypherLogo extends StatelessWidget {
  const CypherLogo({
    super.key,
    required this.color,
    this.size = 24,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CypherLogoPainter(color: color),
      ),
    );
  }
}

class _CypherLogoPainter extends CustomPainter {
  const _CypherLogoPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final ringRadius = size.width * 0.41;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      ringRadius,
      strokePaint,
    );

    final brickWidth = size.width * 0.22;
    final shortBrickWidth = size.width * 0.12;
    final brickHeight = size.height * 0.11;
    final brickRadius = Radius.circular(size.width * 0.025);
    final rowY = <double>[
      size.height * 0.25,
      size.height * 0.38,
      size.height * 0.51,
      size.height * 0.64,
      size.height * 0.77,
    ];
    final rows = <List<double>>[
      [size.width * 0.28, shortBrickWidth, size.width * 0.42, brickWidth, size.width * 0.67, shortBrickWidth],
      [size.width * 0.24, brickWidth, size.width * 0.49, brickWidth, size.width * 0.74, shortBrickWidth],
      [size.width * 0.28, shortBrickWidth, size.width * 0.42, brickWidth, size.width * 0.67, shortBrickWidth],
      [size.width * 0.24, brickWidth, size.width * 0.49, brickWidth, size.width * 0.74, shortBrickWidth],
      [size.width * 0.28, shortBrickWidth, size.width * 0.42, brickWidth, size.width * 0.67, shortBrickWidth],
    ];

    for (var row = 0; row < rows.length; row++) {
      final definition = rows[row];
      for (var i = 0; i < definition.length; i += 2) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              definition[i],
              rowY[row],
              definition[i + 1],
              brickHeight,
            ),
            brickRadius,
          ),
          fillPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CypherLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
