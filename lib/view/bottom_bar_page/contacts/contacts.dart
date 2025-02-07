import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/contacts.dart';
import 'package:chatter/utils/groupby.dart';
import 'package:chatter/view/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.put(ContactsController());
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
                          itemCount: ctr.listOfMyContacts
                              .groupBy((contact) =>
                                  contact.username[0].toUpperCase())
                              .keys
                              .toList()
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            // Group contacts by their first letter and sort keys alphabetically
                            var groupedContacts = ctr.listOfMyContacts.groupBy(
                                (contact) => contact.username[0].toUpperCase());
                            var sortedKeys = groupedContacts.keys.toList()
                              ..sort();

                            var groupKey = sortedKeys[
                                index]; // Alphabetically sorted first letter
                            var contactsInGroup = groupedContacts[groupKey]!
                              ..sort((a, b) => a.username.compareTo(
                                  b.username)); // Sort contacts in group

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Heading for the first letter
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0.h, horizontal: 15.w),
                                  child: Text(
                                    groupKey,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                // Nested ListView for contacts under this group
                                ListView.builder(
                                  physics:
                                      NeverScrollableScrollPhysics(), // Prevent scrolling inside
                                  shrinkWrap:
                                      true, // Allow ListView inside another ListView
                                  itemCount: contactsInGroup.length,
                                  itemBuilder:
                                      (BuildContext context, int contactIndex) {
                                    var contact = contactsInGroup[contactIndex];
                                    return ListTile(
                                      onTap: () async {
                                        // var chatRoomId = await ChatRoomService
                                        //     .createChatRoom(
                                        //   chatRoomImage:
                                        //       contact.profileImageUrl,
                                        //   chatRoomName: contact.username,
                                        //   description: '',
                                        //   receiverId:
                                        //       contact.phoneNumber.toString(),
                                        //   participants: [
                                        //     contact.phoneNumber.toString(),
                                        //     LocalService.userId.toString(),
                                        //   ],
                                        //   isGroup: false,
                                        // );
                                        Get.to(
                                          () => ChatPage(
                                            lastMessages: [],
                                            unreadCount: 0,
                                            receiverId: contact.id,
                                            name: contact.username,
                                          ),
                                          transition: Transition.cupertino,
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            contact.profileImageUrl ?? ""),
                                      ),
                                      title: Text(
                                        contact.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      subtitle: Text(
                                        contact.phoneNumber?.isNotEmpty ?? false
                                            ? contact.phoneNumber.toString()
                                            : 'No phone number',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    );
                                  },
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
