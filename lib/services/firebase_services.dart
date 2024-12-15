import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFireStoreServices {
  // static User get user => FirebaseAuth.instance.currentUser!;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

//  static Future<DateTime> getServerTimestamp() async {
//     try {
//       // Add a temporary document to Firestore
//       DocumentReference tempDoc = firestore.collection('temp').doc();
//       await tempDoc.set({
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Retrieve the server timestamp from the document
//       DocumentSnapshot snapshot = await tempDoc.get();
//       Timestamp serverTimestamp = snapshot.get('timestamp');

//       // Delete the temporary document
//       await tempDoc.delete();

//       // Convert the server timestamp to DateTime and return it
//       return serverTimestamp.toDate();
//     } catch (e) {
//       print('Error fetching server timestamp: $e');
//       // Fallback to local DateTime if server timestamp fails
//       return DateTime.now();
//     }
//   }
}
