import 'package:chatter/view/chat/widgets/test.dart';
import 'package:flutter/material.dart';

class MicTestPage extends StatelessWidget {
  const MicTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(50),
        child: MicAnimationWidget(),
      )),
    );
  }
}
