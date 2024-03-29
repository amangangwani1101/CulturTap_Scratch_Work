import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String userName = '';
String userID = '';
String userPhoneNumber = '';
String userToken = '';
String userFirebaseId = '';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

String extractFirstName(String username) {
  List<String> parts = username.split(' ');
  return parts.isNotEmpty ? parts[0] : username;
}

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
      String uToken = userData['token'];
      String userFireId = userData['uid'];

      userToken = uToken;

      print(uNumber);
      userPhoneNumber = uNumber;
      userName = (uName);
      userFirebaseId = userFireId;
      print('userNamewa: $userName');
      userID = uId;
      print('userIDmmmmm: $userID');
      print('user firebase id: $userFirebaseId');

    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}
