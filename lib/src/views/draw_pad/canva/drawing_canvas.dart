import 'package:flutter/material.dart';

import 'canva.dart';

const Color kCanvasColor = Color(0xfff2f3f7);

class DrawingCanvas extends StatefulWidget {
  final double height;
  final double width;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;

  const DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.selectedColor,
    required this.strokeSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
  }) : super(key: key);

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Stack(
        children: [
          buildAllSketches(context),
          buildCurrentPath(context),
        ],
      ),
    );
  }

  void onPointerDown(PointerDownEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    widget.currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: widget.strokeSize.value,
        color: widget.drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : widget.selectedColor.value,
      ),
      widget.drawingMode.value,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    final points = List<Offset>.from(widget.currentSketch.value?.points ?? [])
      ..add(offset);

    widget.currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: widget.strokeSize.value,
        color: widget.drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : widget.selectedColor.value,
      ),
      widget.drawingMode.value,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    widget.allSketches.value = List<Sketch>.from(widget.allSketches.value)
      ..add(widget.currentSketch.value!);
    widget.currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: widget.strokeSize.value,
        color: widget.drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : widget.selectedColor.value,
      ),
      widget.drawingMode.value,
    );
  }

  Widget buildAllSketches(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ValueListenableBuilder<List<Sketch>>(
        valueListenable: widget.allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: widget.canvasGlobalKey,
            child: Container(
              height: widget.height,
              width: widget.width,
              color: kCanvasColor,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp: onPointerUp,
      child: ValueListenableBuilder(
        valueListenable: widget.currentSketch,
        builder: (context, sketch, child) {
          return RepaintBoundary(
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketch == null ? [] : [sketch],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;

  const SketchPainter({
    Key? key,
    required this.sketches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (Sketch sketch in sketches) {
      final points = sketch.points;
      if (points.isEmpty) return;

      final path = Path();

      path.moveTo(points[0].dx, points[0].dy);
      if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      for (int i = 1; i < points.length - 1; ++i) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round;

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = sketch.size;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}
