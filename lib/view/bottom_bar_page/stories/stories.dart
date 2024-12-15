import 'package:chatter/view/chat/widgets/mic_drag.dart';
import 'package:flutter/material.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: MicIconWobbleAndDrag()),
    );
  }
}
