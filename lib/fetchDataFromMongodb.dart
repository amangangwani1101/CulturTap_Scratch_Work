import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String userName = '';
String userID = '';
String userPhoneNumber = '';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> fetchDataFromMongoDB() async {
  try {

    User? user = _auth.currentUser;
    print('yeah rha user yha');
    print(user);
    if (user != null) {
      print('yeah rha user yha jadfhalksdf');

      var userQuery = await firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();


      var userData = userQuery.docs.first.data();

      print('abababa');
      print(userData);
      String uName = userData['name'];
      String uId = userData['userMongoId'];
      String uNumber = (userData['phoneNo'].toString());
      print(uNumber);
      // userPhoneNumber = uNumber;
      // userName = uName;
      print('userNamewa: $uName');
      userID = uId;
      print('userIDmmmmm: $userID');
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}
