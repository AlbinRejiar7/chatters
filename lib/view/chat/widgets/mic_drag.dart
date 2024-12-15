import 'package:flutter/material.dart';

class MicIconWobbleAndDrag extends StatefulWidget {
  @override
  _MicIconWobbleAndDragState createState() => _MicIconWobbleAndDragState();
}

class _MicIconWobbleAndDragState extends State<MicIconWobbleAndDrag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _wobbleAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  double _dragOffset = 0.0; // To track the position during dragging.

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _wobbleAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        if (_controller.status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (_controller.status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetPosition() {
    // Animates back to the initial position
    setState(() {
      _dragOffset = 0.0; // Reset the drag offset
    });
    _controller.forward(); // Restart the wobble animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onLongPressStart: (_) {
            _controller.forward(); // Start wobble and scale animation
          },
          onLongPressEnd: (_) {
            _controller.stop(); // Stop wobble animation
            _controller.reset();
          },
          onPanUpdate: (details) {
            // Update the widget's horizontal position based on the drag
            setState(() {
              _dragOffset += details.delta.dx;
            });
          },
          onPanEnd: (_) {
            // When the drag ends, animate back to the initial position
            _resetPosition();
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_dragOffset, 0), // Apply the drag offset
                child: Transform(
                  transform: Matrix4.rotationZ(_wobbleAnimation.value),
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.mic,
              size: 100,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
