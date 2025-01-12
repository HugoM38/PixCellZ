import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixcellz/ui/pixcellz_modification/pixel_art_viewmodel_modification.dart';

class PixelGridModifier extends StatefulWidget {
  const PixelGridModifier({super.key});

  @override
  State<PixelGridModifier> createState() => _PixelGridModifierState();
}

class _PixelGridModifierState extends State<PixelGridModifier> {
  Offset? _currentHoverPosition;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PixelArtViewModelModification>();
    const gridSize = 512.0;
    const pixelSize = gridSize / 32;

    return Container(
      width: gridSize,
      height: gridSize,
      color: Colors.white,
      child: MouseRegion(
        onHover: (event) => setState(() => _currentHoverPosition = event.localPosition),
        onExit: (_) => setState(() => _currentHoverPosition = null),
        child: GestureDetector(
          onTapDown: (details) => _handleTap(details.localPosition, viewModel),
          onPanStart: (details) => _handleTap(details.localPosition, viewModel),
          onPanUpdate: (details) => _handleTap(details.localPosition, viewModel),
          child: CustomPaint(
            painter: PixelGridModifierPainter(
              pixels: viewModel.pixels,
              selectedColor: viewModel.selectedColor,
              hoverPosition: _currentHoverPosition,
              pixelSize: pixelSize,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset localPos, PixelArtViewModelModification viewModel) {
    final x = (localPos.dx / (512.0 / 32)).floor();
    final y = (localPos.dy / (512.0 / 32)).floor();
    if (x >= 0 && x < 32 && y >= 0 && y < 32) {
      viewModel.setPixel(x, y);
    }
  }
}

class PixelGridModifierPainter extends CustomPainter {
  final List<List<Color>> pixels;
  final Color selectedColor;
  final Offset? hoverPosition;
  final double pixelSize;

  PixelGridModifierPainter({
    required this.pixels,
    required this.selectedColor,
    required this.hoverPosition,
    required this.pixelSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int y = 0; y < pixels.length; y++) {
      for (int x = 0; x < pixels[y].length; x++) {
        paint.color = pixels[y][x];
        final rect = Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
        canvas.drawRect(rect, paint);

        paint.color = Colors.grey.withOpacity(0.3);
        paint.style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        paint.style = PaintingStyle.fill;
      }
    }

    if (hoverPosition != null) {
      final x = (hoverPosition!.dx / pixelSize).floor();
      final y = (hoverPosition!.dy / pixelSize).floor();
      if (x >= 0 && x < 32 && y >= 0 && y < 32) {
        final rect = Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
        paint.color = selectedColor.withOpacity(0.5);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
