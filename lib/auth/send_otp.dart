import 'package:chatter/utils/responsive.dart';
import 'package:flutter/material.dart';

class SendOtpPage extends StatelessWidget {
  const SendOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsiveWidth(20),
              vertical: getResponsiveWidth(40)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone number",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 25),
              ),
              Text("Enter your phone number to get started.",
                  style: Theme.of(context).textTheme.bodyMedium)
            ],
          ),
        ),
      ),
    );
  }
}
