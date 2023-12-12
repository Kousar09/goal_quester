import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/image_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfile extends StatefulWidget {
  UserProfile({super.key, required this.userId});
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.purple,
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: purl,
                        height: 80,
                        width: 80,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(fullName),
              ],
            ),
            const SizedBox(height: 20),
            GoalSection(title: 'Public Goals'),
            GoalSection(title: 'Private Goals'),
          ],
        ),
      ),
    );
  }
}

class GoalSection extends StatelessWidget {
  final String title;

  GoalSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Goal ${index + 1}'),
            );
          },
        ),
      ],
    );
  }
}
