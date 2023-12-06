import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String userName = '';
String userID = '';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> fetchDataFromMongoDB() async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      var userQuery = await firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      var userData = userQuery.docs.first.data();
      String uName = userData['name'];
      String uId = userData['userMongoId'];
      userName = uName;
      print('userName: $userName');
      userID = uId;
      print('userID: $userID');
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}
