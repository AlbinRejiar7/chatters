import 'package:flutter/material.dart';

class WobbleAvatar extends StatefulWidget {
  const WobbleAvatar({super.key});

  @override
  State<WobbleAvatar> createState() => _WobbleAvatarState();
}

class _WobbleAvatarState extends State<WobbleAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _positionController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
    lowerBound: 1.0,
    upperBound: 1.3,
  );

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size biggest = constraints.biggest;
        return GestureDetector(
          onLongPress: () => _scaleController.forward(),
          onLongPressUp: () => _scaleController.reverse(),
          child: ScaleTransition(
            scale: _scaleController,
            child: PositionedTransition(
              rect: RelativeRectTween(
                begin: RelativeRect.fromSize(
                  Rect.fromLTWH(
                    biggest.width / 2 - 30,
                    biggest.height / 2 - 30,
                    60,
                    60,
                  ),
                  biggest,
                ),
                end: RelativeRect.fromSize(
                  Rect.fromLTWH(
                    biggest.width / 2 - 30,
                    biggest.height / 2 - 50,
                    60,
                    60,
                  ),
                  biggest,
                ),
              ).animate(CurvedAnimation(
                parent: _positionController,
                curve: Curves.elasticInOut,
              )),
              child: const CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
              ),
            ),
          ),
        );
      },
    );
  }
}
