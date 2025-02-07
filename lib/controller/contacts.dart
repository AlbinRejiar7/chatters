import 'package:chatter/model/user.dart';
import 'package:chatter/services/firebase_auth.dart';
import 'package:chatter/services/firebase_services.dart';
import 'package:chatter/services/local_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactsController extends GetxController {
  List<String> contactNumbers = []; // Normalized phone numbers from contacts
  RxList<Contact> matchingContacts = <Contact>[].obs; // Matching contacts
  var isLoading = false.obs;
  var listOfMyContacts = <UserModel>[].obs;
  List<Contact> contacts = []; // All contacts fetched from the device
  Future fetchContacts() async {
    final hasPermission = await FlutterContacts.requestPermission();

    if (hasPermission) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);

      // Normalize and extract phone numbers
      contactNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) => contact.phones.first.normalizedNumber)
          .toList();
    } else {
      Get.snackbar("PERMISSION", "Permission Denied");
    }
  }

  Future<void> fetchMatchingContacts() async {
    if (contactNumbers.isEmpty) {
      Get.snackbar("INFO", "No contacts available to match");
      return;
    }

    const batchSize = 10;

    // Split phone numbers into batches of 10 for Firestore queries
    List<List<String>> batches = [
      for (int i = 0; i < contactNumbers.length; i += batchSize)
        contactNumbers.sublist(
            i, (i + batchSize).clamp(0, contactNumbers.length))
    ];

    try {
      // 🔹 Debug: Print batches being sent to Firestore
      if (kDebugMode) {
        print("🔍 Batches for Firestore Query: $batches");
      }

      // Query Firestore in parallel for all batches
      List<QuerySnapshot> results = await Future.wait(
        batches.map((batch) {
          return FirebaseFireStoreServices.firestore
              .collection('users')
              .where('id', whereIn: batch)
              .get();
        }),
      );

      // Collect matching phone numbers from Firestore
      List<String> matchingNumbers = results
          .expand((snapshot) => snapshot.docs.map((doc) => doc['id'] as String))
          .toList();

      // 🔹 Debug: Print matching numbers from Firestore
      if (kDebugMode) {
        print("✅ Matching Numbers from Firestore: $matchingNumbers");
      }

      // Filter contacts by matching numbers
      matchingContacts.value = contacts.where((contact) {
        if (contact.phones.isEmpty) return false;
        String contactNumber = contact.phones.first.normalizedNumber.trim();

        // 🔹 Debug: Print contact number being checked
        if (kDebugMode) {
          print("📞 Checking Contact: $contactNumber");
        }

        return matchingNumbers.contains(contactNumber);
      }).toList();

      // 🔹 Debug: Print matched contacts
      if (kDebugMode) {
        print("👥 Matched Contacts: ${matchingContacts.length}");
      }

      // Fetch user details concurrently for matching contacts
      List<Future<UserModel?>> userFutures =
          matchingContacts.map((contact) async {
        var phone = contact.phones.first.normalizedNumber;
        var userDetails =
            await FirebaseAuthServices.getUserDetailsBydocId(phone);

        if (userDetails != null && userDetails.id != LocalService.userId) {
          userDetails.username = contact.displayName; // Update username
          return userDetails;
        }
        return null;
      }).toList();

      // Wait for all user details to be fetched
      List<UserModel?> users = await Future.wait(userFutures);

      // Add valid users to the list
      listOfMyContacts.addAll(users.whereType<UserModel>());

      // 🔹 Debug: Print final list of contacts
      if (kDebugMode) {
        print("📲 Final Contact List: ${listOfMyContacts.length}");
      }
    } catch (e) {
      Get.snackbar("ERROR", "Failed to fetch matching contacts: $e");

      if (kDebugMode) {
        print("❌ Error fetching contacts: $e");
      }
    }
  }

  // Future fetchMatchingContacts() async {
  //   if (contactNumbers.isEmpty) {
  //     Get.snackbar("INFO", "No contacts available to match");
  //     return;
  //   }

  //   try {
  //     const batchSize = 10;

  //     // Avoid duplicate queries by using a Set
  //     final uniqueNumbers = contactNumbers.toSet().toList();

  //     // Break contacts into batches of 10 for Firestore query
  //     List<List<String>> batches = [
  //       for (int i = 0; i < uniqueNumbers.length; i += batchSize)
  //         uniqueNumbers.sublist(
  //             i, (i + batchSize).clamp(0, uniqueNumbers.length))
  //     ];

  //     List<UserModel> matchedUsers = [];

  //     // Query Firestore in parallel batches
  //     await Future.wait(
  //       batches.map((batch) async {
  //         final querySnapshot = await FirebaseFireStoreServices.firestore
  //             .collection('users')
  //             .where('phoneNumber', whereIn: batch)
  //             .get();

  //         // Convert Firestore documents to UserModel
  //         matchedUsers.addAll(querySnapshot.docs.map((doc) {
  //           return UserModel.fromMap(doc.data());
  //         }));
  //       }),
  //     );

  //     // Filter and update the list of matching contacts
  //     matchingContacts.value = contacts.where((contact) {
  //       final phone = contact.phones.isNotEmpty
  //           ? contact.phones.first.normalizedNumber
  //           : null;
  //       return phone != null &&
  //           matchedUsers.any((user) => user.phoneNumber == phone);
  //     }).toList();

  //     // Update listOfMyContacts with user details
  //     listOfMyContacts.value = matchingContacts
  //         .map((contact) {
  //           final phone = contact.phones.first.normalizedNumber;

  //           // Check if this phone number already exists in the list
  //           if (listOfMyContacts.value
  //               .any((user) => user.phoneNumber == phone)) {
  //             return null; // Skip duplicates
  //           }

  //           final user = matchedUsers.firstWhere(
  //             (user) => user.phoneNumber == phone,
  //             orElse: () => UserModel(
  //               id: 'id',
  //               username: 'username',
  //               isOnline: true,
  //               lastSeen: DateTime.now(),
  //               createdAt: DateTime.now(),
  //               updatedAt: DateTime.now(),
  //             ),
  //           );

  //           if (user.id != LocalService.userId) {
  //             user.username = contact.displayName; // Update with contact name
  //             return user;
  //           }
  //           return null;
  //         })
  //         .whereType<UserModel>() // Remove nulls
  //         .toList()
  //         .toSet()
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar("ERROR", "Failed to fetch matching contacts: $e");
  //   }
  // }

  @override
  void onInit() async {
    super.onInit();
    await FlutterContacts.requestPermission();

    isLoading.value = true;
    await fetchContacts();
    await fetchMatchingContacts();
    isLoading.value = false;
  }
}
