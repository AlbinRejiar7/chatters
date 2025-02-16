import 'package:chatter/view/audio/audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Text("slide to cancel"),
          ElevatedButton(
              onPressed: () {
                Get.to(() => AudioRecorderScreen());
              },
              child: Text("audio"))
        ],
      ),
    );
  }
}
