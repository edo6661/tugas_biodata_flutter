import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart' show ViewportOffset;

class CarouselFlowDelegate extends FlowDelegate {
  CarouselFlowDelegate({
    required this.viewportOffset,
    required this.filtersPerScreen,
  }) : super(repaint: viewportOffset);

  final ViewportOffset viewportOffset;
  final int filtersPerScreen;

  @override
  void paintChildren(FlowPaintingContext context) {
    final count = context.childCount;
    final size = context.size.width;
    final itemExtent = size / filtersPerScreen;
    final active = viewportOffset.pixels / itemExtent;
    final min = math.max(0, active.floor() - 3).toInt();
    final max = math.min(count - 1, active.ceil() + 3).toInt();

    // Offset for 3D effect
    final double perspective = 0.002;

    for (var index = min; index <= max; index++) {
      final itemXFromCenter = itemExtent * index - viewportOffset.pixels;
      final percentFromCenter = 1.0 - (itemXFromCenter / (size / 2)).abs();

      // Enhanced scaling and opacity
      final itemScale = 0.4 + (percentFromCenter * 0.6);
      final opacity = 0.3 + (percentFromCenter * 0.7);

      // Calculate vertical offset for arch effect
      final double verticalOffset =
          15.0 * (1.0 - percentFromCenter * percentFromCenter);

      final itemTransform = Matrix4.identity()
        ..translate((size - itemExtent) / 2)
        ..translate(itemXFromCenter)
        ..translate(itemExtent / 2, itemExtent / 2)
        // Add z-translation for depth
        ..setEntry(3, 2, perspective)
        ..rotateY(
            (1.0 - percentFromCenter) * (itemXFromCenter > 0 ? 0.2 : -0.2))
        // Translate vertically for arch effect
        ..translate(0.0, -verticalOffset)
        ..scale(itemScale, itemScale, 1.0)
        ..translate(-itemExtent / 2, -itemExtent / 2);

      context.paintChild(
        index,
        transform: itemTransform,
        opacity: opacity,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CarouselFlowDelegate oldDelegate) {
    return oldDelegate.viewportOffset != viewportOffset;
  }
}
