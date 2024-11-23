import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactsController extends GetxController {
  List<Contact> contacts = [];
  Future fetchContacts() async {
    final hasPermission = await FlutterContacts.requestPermission();

    if (hasPermission) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
    } else {
      Get.snackbar("PERMISSION", "Permission Denied");
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await fetchContacts();
  }
}
