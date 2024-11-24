import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/contacts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.put(ContactsController());
    return Scaffold(
        body: Column(
      children: [
        Text(" ${ctr.contacts.length} Contacts"),
        Expanded(
          child: ListView.builder(
            itemCount: ctr.contacts.length,
            itemBuilder: (BuildContext context, int index) {
              var contact = ctr.contacts[index];

              // Show the first letter of the display name as a header
              String displayNameFirstLetter = contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0 ||
                      ctr.contacts[index - 1].displayName[0].toUpperCase() !=
                          contact.displayName[0].toUpperCase())
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        displayNameFirstLetter,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      contact.phones.isNotEmpty
                          ? contact.phones
                              .map((e) => e.normalizedNumber)
                              .join(', ')
                          : 'No phone number',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}
