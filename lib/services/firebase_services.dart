import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFireStoreServices {
  // static User get user => FirebaseAuth.instance.currentUser!;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
