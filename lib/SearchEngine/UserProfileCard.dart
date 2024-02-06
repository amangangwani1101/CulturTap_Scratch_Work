import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  final String username;
  final String profileImage;
  final String bio;

  UserProfileCard({
    required this.username,
    required this.profileImage,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Customize the appearance of the user profile card
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profileImage),
          radius: 25,
        ),
        title: Text(username),
        subtitle: Text(bio),
        // Add onTap handler if needed
      ),
    );
  }
}
