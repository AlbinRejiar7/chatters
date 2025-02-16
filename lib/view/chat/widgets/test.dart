import 'dart:math';

import 'package:chatter/view/chat/widgets/plus_icon.dart' show MicDeleteButton;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MicAnimationWidget extends StatefulWidget {
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressRelease;
  final VoidCallback? onSlideToCancel;
  final bool isMic;
  final VoidCallback? onSendTap;

  const MicAnimationWidget({
    super.key,
    this.onLongPressStart,
    this.onLongPressRelease,
    this.onSlideToCancel,
    this.isMic = true,
    this.onSendTap,
  });

  @override
  State<MicAnimationWidget> createState() => _MicAnimationWidgetState();
}

class _MicAnimationWidgetState extends State<MicAnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticInOut,
  );
  bool longpressHappend = false;
  bool _isLongPressTriggered = false;
  late Ticker? _ticker;
  bool _isWobbling = false;
  double _micPositionX = 0.0;
  bool _isCancelled = false;
  double _startPosition = 0.0;
  final double _dragThreshold = 150.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!_isWobbling) return;
      _controller.isCompleted ? _controller.reverse() : _controller.forward();
    });
  }

  void _startLongPress() {
    if (!widget.isMic) return;
    _isLongPressTriggered = false;
    widget.onLongPressStart?.call();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isLongPressTriggered) {
        _controller.forward();
        _isLongPressTriggered = true;

        _startWobble();
        setState(() {});
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
    widget.onLongPressRelease?.call();
  }

  void _startWobble() {
    _isWobbling = true;
    _ticker?.start();
  }

  void _stopWobble() {
    _isWobbling = false;
    _ticker?.stop();
    _controller.reverse();
  }

  void _onDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    double dragDistance = details.globalPosition.dx - _startPosition;

    if (dragDistance < 0) {
      setState(() {
        _micPositionX = dragDistance.abs();
        if (_micPositionX > _dragThreshold / 2) {
          _isCancelled = true;
        }
      });

      if (_micPositionX > _dragThreshold &&
          details.globalPosition.dx < MediaQuery.of(context).size.width / 2) {
        if (!_isCancelled) {
          setState(() {
            _isCancelled = true;
          });
          print("onslide cacel called----------");
          widget.onSlideToCancel?.call(); // Call slide cancel function
          Future.delayed(const Duration(milliseconds: 100), _resetMicPosition);
        }
      }
    }
  }

  void _onDragEnd(DragEndDetails details) {
    widget.onSlideToCancel?.call();
    if (_isCancelled) {
      _resetMicPosition(); // Reset position without calling onLongPressRelease
    } else {
      setState(() {
        _micPositionX = 0;
      });
    }
  }

  void _resetMicPosition() {
    _controller.reverse();
    _stopWobble();
    setState(() {
      _micPositionX = 0;
      _isCancelled = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _isLongPressTriggered ? _onDragStart : null,
      onHorizontalDragUpdate: _isLongPressTriggered ? _onDragUpdate : null,
      onHorizontalDragEnd: _isLongPressTriggered ? _onDragEnd : null,
      onTapDown: (_) => _startLongPress(),
      onTapUp: (_) => _cancelLongPress(),
      onTapCancel: () => _cancelLongPress(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Align(
            child: FractionalTranslation(
              translation: Offset(-_micPositionX / 100, 0),
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
                      child: GestureDetector(
                        onTap: widget.isMic ? null : widget.onSendTap,
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: MicDeleteButton(
                            isSend: !widget.isMic,
                            isDelete: _isCancelled,
                          ),
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
// class MicAnimationWidget extends StatefulWidget {
//   const MicAnimationWidget({super.key});

//   @override
//   State<MicAnimationWidget> createState() =>
//       _MicAnimationWidgetState();
// }

// class _MicAnimationWidgetState
//     extends State<MicAnimationWidget> with TickerProviderStateMixin {
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
