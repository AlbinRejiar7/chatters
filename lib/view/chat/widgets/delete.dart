import 'package:chatter/services/local_chat.dart';
import 'package:chatter/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteMessageDialog(
    BuildContext context, String chatUsersId, String messageId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: <Widget>[
          CustomElevatedButton(
            text: "cancel",
            onPressed: () {
              Get.back();
            },
          ),
          CustomElevatedButton(
            text: "Delete",
            onPressed: () async {
              // Call the function to delete the message
              // await ChatStorageService.deleteMessage(chatUsersId, messageId);

              // Close the dialog after deletion
              Navigator.of(context).pop();

              // Show a snack bar for feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message deleted successfully.')),
              );
            },
          ),
        ],
      );
    },
  );
}
