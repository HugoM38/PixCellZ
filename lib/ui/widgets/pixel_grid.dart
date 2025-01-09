import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixcellz/ui/pixcellz_creation/pixel_art_viewmodel.dart';

class PixelGrid extends StatefulWidget {
  const PixelGrid({super.key});

  @override
  State<PixelGrid> createState() => _PixelGridState();
}

class _PixelGridState extends State<PixelGrid> {
  Offset? _currentHoverPosition;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PixelArtViewModel>();
    const gridSize = 512.0;
    const pixelSize = gridSize / 32;

    return Center(
      child: Container(
        width: gridSize,
        height: gridSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              _currentHoverPosition = event.localPosition;
            });
          },
          onExit: (_) => setState(() => _currentHoverPosition = null),
          child: GestureDetector(
            onTapDown: (details) => _handleTap(details.localPosition, viewModel),
            onPanStart: (details) => _handleTap(details.localPosition, viewModel),
            onPanUpdate: (details) => _handleTap(details.localPosition, viewModel),
            child: CustomPaint(
              painter: PixelGridPainter(
                pixels: viewModel.pixels,
                hoverPosition: _currentHoverPosition,
                selectedColor: viewModel.selectedColor,
                pixelSize: pixelSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset localPosition, PixelArtViewModel viewModel) {
    final x = (localPosition.dx / (512.0 / 32)).floor();
    final y = (localPosition.dy / (512.0 / 32)).floor();
    
    if (x >= 0 && x < 32 && y >= 0 && y < 32) {
      viewModel.setPixel(x, y);
    }
  }
}

class PixelGridPainter extends CustomPainter {
  final List<List<Color>> pixels;
  final Offset? hoverPosition;
  final Color selectedColor;
  final double pixelSize;

  PixelGridPainter({
    required this.pixels,
    required this.hoverPosition,
    required this.selectedColor,
    required this.pixelSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int y = 0; y < 32; y++) {
      for (int x = 0; x < 32; x++) {
        final rect = Rect.fromLTWH(
          x * pixelSize,
          y * pixelSize,
          pixelSize,
          pixelSize,
        );

        paint.color = pixels[y][x];
        canvas.drawRect(rect, paint);

        paint.color = Colors.grey.withOpacity(0.3);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1;
        canvas.drawRect(rect, paint);
        paint.style = PaintingStyle.fill;
      }
    }

    if (hoverPosition != null) {
      final x = (hoverPosition!.dx / pixelSize).floor();
      final y = (hoverPosition!.dy / pixelSize).floor();

      if (x >= 0 && x < 32 && y >= 0 && y < 32) {
        final rect = Rect.fromLTWH(
          x * pixelSize,
          y * pixelSize,
          pixelSize,
          pixelSize,
        );

        paint.color = selectedColor.withOpacity(0.5);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}