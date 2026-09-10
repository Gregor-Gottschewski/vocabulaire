import 'package:flutter/material.dart';

const double _edgeWidth = 24.0;
const double _distanceThreshold = 80.0;
const double _velocityThreshold = 300.0;

/// Strip along the left screen edge that triggers [onSwipeBack] on a
/// left-to-right / back swipe.
class EdgeSwipeBackArea extends StatefulWidget {
  final VoidCallback onSwipeBack;
  final Widget child;

  const EdgeSwipeBackArea({
    super.key,
    required this.onSwipeBack,
    required this.child,
  });

  @override
  State<EdgeSwipeBackArea> createState() => _EdgeSwipeBackAreaState();
}

class _EdgeSwipeBackAreaState extends State<EdgeSwipeBackArea> {
  double _dragExtent = 0;
  bool _triggered = false;

  void _onDragUpdate(DragUpdateDetails details) {
    if (_triggered) return;
    _dragExtent += details.delta.dx;
    if (_dragExtent >= _distanceThreshold) {
      _triggered = true;
      widget.onSwipeBack();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_triggered && (details.primaryVelocity ?? 0) >= _velocityThreshold) {
      widget.onSwipeBack();
    }
    _dragExtent = 0;
    _triggered = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
          ),
        ),
      ],
    );
  }
}
