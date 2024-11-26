import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/contacts.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/view/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.find<ContactsController>();
    return Scaffold(body: Obx(() {
      return ctr.isLoading.value
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: AppColors.primaryColor,
                strokeCap: StrokeCap.round,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ctr.listOfMyContacts.isEmpty
                    ? const Center(
                        child: Text(
                            textAlign: TextAlign.center,
                            "ADD CONTACTS THAT ARE USING THE CHATTER APP (ONLY USERS THAT ARE REGISTERED WITH CHATTER WILL BE DISPLAYED HERE!)"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: ctr.listOfMyContacts.length,
                          itemBuilder: (BuildContext context, int index) {
                            var contact = ctr.listOfMyContacts[index];

                            // Show the first letter of the display name as a header
                            String displayNameFirstLetter =
                                contact.username.isNotEmpty
                                    ? contact.username[0].toUpperCase()
                                    : '';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0 ||
                                    ctr.contacts[index - 1].displayName[0]
                                            .toUpperCase() !=
                                        contact.username[0].toUpperCase())
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0.h, horizontal: 15.w),
                                    child: Text(
                                      displayNameFirstLetter,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ListTile(
                                  onTap: () async {
                                    var chatRoomId =
                                        await ChatRoomService.createChatRoom(
                                            chatRoomImage:
                                                contact.profileImageUrl,
                                            chatRoomName: contact.username,
                                            description: '',
                                            receiverId:
                                                contact.phoneNumber.toString(),
                                            participants: [
                                              contact.phoneNumber.toString(),
                                              LocalService.userId.toString(),
                                            ],
                                            isGroup: false);
                                    Get.to(
                                        () => ChatPage(receiverId: contact.id,
                                              name: contact.username,
                                              chatRoomId: chatRoomId,
                                            ),
                                        transition: Transition.cupertino);
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        contact.profileImageUrl ?? ""),
                                  ),
                                  title: Text(
                                    contact.username,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    contact.phoneNumber!.isNotEmpty
                                        ? contact.phoneNumber.toString()
                                        : 'No phone number',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
              ],
            );
    }));
  }
}
