import 'package:flutter/material.dart';

class CustomTrackShape extends RoundedRectSliderTrackShape {
  final double progress;
  final Color color;

  const CustomTrackShape({required this.progress, required this.color});

}

class CustomThumbShape extends RoundSliderThumbShape {
  final Color color;

  const CustomThumbShape({required this.color})
      : super(enabledThumbRadius: 12, pressedElevation: 8, elevation: 4);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer shadow
    final Path path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: enabledThumbRadius));
    canvas.drawShadow(path, Colors.black, elevation, true);

    // Inner white circle
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);

    // Outer teal border stroke
    final Paint strokePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, enabledThumbRadius - 1.5, strokePaint);
  }
}
