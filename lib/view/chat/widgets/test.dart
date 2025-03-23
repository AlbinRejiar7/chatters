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

    Future.delayed(const Duration(milliseconds: 100), () {
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
    });

    if (_isCancelled) {
      widget.onSlideToCancel?.call(); // Notify parent widget
    } else {
      widget.onLongPressRelease?.call(); // Only call if NOT cancelled
    }
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
      // Only react if dragging left
      setState(() {
        _micPositionX = dragDistance.abs();

        // Ensure _isCancelled is set once the threshold is exceeded
        if (_micPositionX > _dragThreshold) {
          if (!_isCancelled) {
            _isCancelled = true;
            widget.onSlideToCancel?.call(); // Notify parent widget
            _cancelLongPress(); // Stop recording and cancel
          }
        }
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isCancelled) {
      _resetMicPosition(); // Reset position without sending the message
    } else {
      widget.onLongPressRelease?.call(); // Only release if NOT cancelled
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
      onLongPress: _startLongPress, // Start recording only on long press
      onLongPressUp:
          _cancelLongPress, // Stop recording when the press is released
      onHorizontalDragStart: _isLongPressTriggered ? _onDragStart : null,
      onHorizontalDragUpdate: _isLongPressTriggered ? _onDragUpdate : null,
      onHorizontalDragEnd: _isLongPressTriggered ? _onDragEnd : null,
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
