import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFireStoreServices {
  // static User get user => FirebaseAuth.instance.currentUser!;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
 

}
