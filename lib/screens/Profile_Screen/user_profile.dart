import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/get_goals.dart';
import 'package:goal_quester/screens/Profile_Screen/user_profile_header.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.userId});
  final String userId;
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String fullName = '';

  String purl = '';

  String gender = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var user in snapshot.docs) {
      if (user.id == widget.userId) {
        setState(() {
          fullName = user['fname'] + ' ' + user['lname'];
          purl = user['purl'];
          gender = user['gender'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            UserProfileHeader(
              fullName: fullName,
              purl: purl,
              userId: widget.userId,
            ),
            const SizedBox(height: 20),
            GetGoals(
              type: 'Public',
              userId: widget.userId,
            ),
          ],
        ),
      ),
    );
  }
}
