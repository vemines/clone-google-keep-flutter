import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../shared/shared.dart';
import 'canva/canva.dart';

class DrawPadView extends StatefulHookWidget {
  const DrawPadView({Key? key, this.bytesPaint}) : super(key: key);

  final List<Uint8List>? bytesPaint;

  @override
  State<DrawPadView> createState() => _DrawPadViewState();
}

class _DrawPadViewState extends State<DrawPadView> {
  final canvasGlobalKey = GlobalKey();
  Uint8List bytes = Uint8List(0);
  bool canPop = false;

  @override
  void initState() {
    super.initState();
    if (widget.bytesPaint != null && widget.bytesPaint!.isNotEmpty) {
      paintCanvas(canvasGlobalKey, widget.bytesPaint!);
    }
  }

  Future<void> paintCanvas(GlobalKey key, List<Uint8List> imageData) async {
    // For simplicity, use the first image (assuming single image)
    if (imageData.isNotEmpty) {
      final ui.Image image = await decodeImageFromList(imageData[0]);
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      canvas.drawImage(image, Offset.zero, Paint());

      // Trigger a repaint with the drawn image
      (key.currentContext?.findRenderObject() as RenderBox?)?.markNeedsPaint();
    }
  }

  Future<Uint8List?> getBytes() async {
    Uint8List? bytes;
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = byteData?.buffer.asUint8List();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final drawingMode = useState(DrawingMode.pencil);
    final currentSketch = useState<Sketch?>(null);
    final allSketches = useState<List<Sketch>>([]);

    return PopScope(
      canPop: canPop,
      onPopInvoked: (_) async {
        if (bytes.isNotEmpty) {
          context.pop(bytes);
          return;
        }
        bytes = await getBytes() ?? Uint8List(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved! Press back again to exit.'),
            duration: Duration(seconds: 3),
          ),
        );
      },
      child: Scaffold(
        body: Container(
          color: kCanvasColor,
          width: double.maxFinite,
          height: double.maxFinite,
          child: DrawingCanvas(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            drawingMode: drawingMode,
            selectedColor: selectedColor,
            strokeSize: strokeSize,
            currentSketch: currentSketch,
            allSketches: allSketches,
            canvasGlobalKey: canvasGlobalKey,
          ),
        ),
        bottomNavigationBar: _BottomBarSection(
          allSketches: allSketches,
          currentSketch: currentSketch,
          drawingMode: drawingMode,
          selectedColor: selectedColor,
          strokeSize: strokeSize,
          canvasGlobalKey: canvasGlobalKey,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            bytes = await getBytes() ?? Uint8List(0);
            context.pop(bytes);
          },
          child: Icon(Icons.save_outlined),
        ),
      ),
    );
  }
}

List<double> _strokeSize = [7, 8, 10, 12, 14, 16, 18, 20, 24];
List<Color> _colors = [
  Colors.black,
  ...Colors.primaries,
];

class _BottomBarSection extends HookWidget {
  const _BottomBarSection({
    required this.selectedColor,
    required this.strokeSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
  });

  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;

  @override
  Widget build(BuildContext context) {
    final undoRedoStack = useState(
      _UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        iconBox(
          onTap: () => drawingMode.value = DrawingMode.pencil,
          iconData: Icons.edit_outlined,
        ),
        iconBox(
          onTap: () => drawingMode.value = DrawingMode.eraser,
          iconData: Icons.cleaning_services_outlined,
        ),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Choose a Color'),
                content: Wrap(
                  spacing: Dimensions.small,
                  runSpacing: Dimensions.small,
                  children: _colors
                      .map((color) => InkWell(
                          onTap: () {
                            selectedColor.value = color;
                          },
                          child: CircleAvatar(backgroundColor: color)))
                      .toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorName.white,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
              color: selectedColor.value,
            ),
          ),
        ),
        DropdownButton<double>(
          value: strokeSize.value, // init value
          elevation: 10,
          iconSize: 0.0,
          style: context.textTheme.bodyLarge,
          underline: Container(
            height: 0,
            color: Colors.transparent, // Set color to transparent
          ),
          padding: EdgeInsets.all(Dimensions.normal),
          onChanged: (size) {
            if (size != null) {
              strokeSize.value = size;
            }
          }, // Disable onChanged for static value
          items: _strokeSize
              .map((size) => DropdownMenuItem<double>(
                    value: size,
                    child: Text('$size'),
                  ))
              .toList(),
        ),
        iconBox(
          onTap: allSketches.value.isNotEmpty
              ? () => undoRedoStack.value.undo()
              : null,
          iconData: Icons.undo,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: undoRedoStack.value._canRedo,
          builder: (_, canRedo, __) {
            return iconBox(
              onTap: canRedo ? () => undoRedoStack.value.redo() : null,
              iconData: Icons.redo,
              disableColor: context.theme.disabledColor,
            );
          },
        ),
        iconBox(
            onTap: () => undoRedoStack.value.clear(), iconData: Icons.close),
      ].separateCenter(),
    );
  }
}

class _UndoRedoStack {
  _UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
