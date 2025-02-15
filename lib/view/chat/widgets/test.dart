import 'dart:math';

import 'package:chatter/view/chat/widgets/plus_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PositionedTransitionExample extends StatefulWidget {
  const PositionedTransitionExample({super.key});

  @override
  State<PositionedTransitionExample> createState() =>
      _PositionedTransitionExampleState();
}

class _PositionedTransitionExampleState
    extends State<PositionedTransitionExample> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticInOut,
  );

  bool _isLongPressTriggered = false;
  late Ticker? _ticker; // ✅ Changed from `late Ticker` to `late Ticker?`
  bool _isWobbling = false;
  double _micPositionX = 0.0;
  bool _isCancelled = false;
  double _startPosition = 0.0;

  final double _dragThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!_isWobbling) return;
      _controller.isCompleted ? _controller.reverse() : _controller.forward();
    });
  }

  void _startLongPress() {
    _isLongPressTriggered = false;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_isLongPressTriggered) {
        _controller.forward();
        _isLongPressTriggered = true;
        _startWobble();
      }
    });
  }

  void _cancelLongPress() {
    if (!_isLongPressTriggered) {
      _isLongPressTriggered = true;
    }
    _controller.reverse();
    _stopWobble();
    setState(() {
      _micPositionX = 0;
      _isCancelled = false;
    });
  }

  void _startWobble() {
    _isWobbling = true;
    _ticker?.start(); // ✅ Safe start without errors
  }

  void _stopWobble() {
    _isWobbling = false;
    _ticker?.stop(); // ✅ Safe stop (avoids error)
    _controller.reverse();
  }

  void _onDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    double dragDistance = details.globalPosition.dx - _startPosition;

    if (dragDistance < 0) {
      setState(() {
        _micPositionX = dragDistance.abs(); // Move mic left
      });

      if (_micPositionX > _dragThreshold) {
        setState(() {
          _isCancelled = true;
        });
      }
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isCancelled) {
      _cancelLongPress();
    } else {
      setState(() {
        _micPositionX = 0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker?.dispose(); // ✅ Safe disposal (avoids error)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTapDown: (_) => _startLongPress(),
      onTapUp: (_) => _cancelLongPress(),
      onTapCancel: () => _cancelLongPress(),
      child: Stack(
        clipBehavior: Clip.none, // ✅ Ensures no clipping
        alignment: Alignment.centerLeft,
        children: [
          if (_isLongPressTriggered)
            Text(
              "<< Slide to cancel",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

          // ✅ Use Align with FractionalTranslation for smooth positioning
          Align(
            alignment: Alignment(0.5, 0), // ✅ Start mic from the right
            child: FractionalTranslation(
              translation: Offset(
                  -_micPositionX / 100, 0), // ✅ Move mic left dynamically
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double width = 50.0 + (_animation.value * 16.0);
                  double height = 70.0 + (_animation.value * 16.0);
                  double rotation = sin(_animation.value * pi * 2) * 0.1;

                  return Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity: _isCancelled ? 0.5 : 1,
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: SendMicButton(
                          isSend: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// //can be used to reply widget
// class PositionedTransitionExample extends StatefulWidget {
//   const PositionedTransitionExample({super.key});

//   @override
//   State<PositionedTransitionExample> createState() =>
//       _PositionedTransitionExampleState();
// }

// class _PositionedTransitionExampleState
//     extends State<PositionedTransitionExample> with TickerProviderStateMixin {
//   late final AnimationController _controller = AnimationController(
//     duration: const Duration(milliseconds: 400),
//     vsync: this,
//   );

//   late final Animation<double> _animation = CurvedAnimation(
//     parent: _controller,
//     curve: Curves.elasticInOut,
//   );

//   bool _isLongPressTriggered = false;
//   late Ticker _ticker;
//   bool _isWobbling = false;
//   double _micPositionX = 0.0; // Track mic position
//   bool _isCancelled = false;

//   void _startLongPress() {
//     _isLongPressTriggered = false;
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted && !_isLongPressTriggered) {
//         _controller.forward();
//         _isLongPressTriggered = true;
//         _startWobble();
//       }
//     });
//   }

//   void _cancelLongPress() {
//     if (!_isLongPressTriggered) {
//       _isLongPressTriggered = true;
//     }
//     _controller.reverse();
//     _stopWobble();
//   }

//   void _startWobble() {
//     _isWobbling = true;
//     _ticker = createTicker((elapsed) {
//       if (!_isWobbling) return;
//       _controller.isCompleted ? _controller.reverse() : _controller.forward();
//     });
//     _ticker.start();
//   }

//   void _stopWobble() {
//     _isWobbling = false;
//     _ticker.stop();
//     _controller.reverse();
//   }

//   void _onDragUpdate(DragUpdateDetails details) {
//     setState(() {
//       _micPositionX += details.primaryDelta ?? 0.0; // Move mic left or right
//     });

//     if (_micPositionX < -100) {
//       // If dragged far enough left, cancel the action
//       setState(() {
//         _isCancelled = true;
//       });
//     }
//   }

//   void _onDragEnd(DragEndDetails details) {
//     if (_isCancelled) {
//       _cancelLongPress(); // Cancel if dragged past threshold
//     } else {
//       setState(() {
//         _micPositionX = 0; // Reset position
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _ticker.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragUpdate: _onDragUpdate,
//       onHorizontalDragEnd: _onDragEnd,
//       onTapDown: (_) => _startLongPress(),
//       onTapUp: (_) => _cancelLongPress(),
//       onTapCancel: () => _cancelLongPress(),
//       child: Stack(
//         alignment: Alignment.centerLeft,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(left: 20.0), // Text fixed in position
//             child: Text(
//               "<< Slide to cancel",
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           ),
//           AnimatedPositioned(
//             duration: Duration(milliseconds: 100),
//             left: _micPositionX, // Mic follows slide
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 double size = 44.0 + (_animation.value * 16.0);
//                 double rotation =
//                     sin(_animation.value * pi * 2) * 0.1; // Wobble effect
//                 return Transform.rotate(
//                   angle: rotation,
//                   child: Opacity(
//                     opacity: _isCancelled ? 0.5 : 1, // Fade out on cancel
//                     child: SizedBox(
//                       width: size,
//                       height: size,
//                       child: SendMicButton(
//                         isSend: false, // Update UI on cancel
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
