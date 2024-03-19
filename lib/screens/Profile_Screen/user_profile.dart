import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/methods/myMethods.dart';
import 'package:goal_quester/screens/Profile_Screen/get_goals.dart';
import 'package:goal_quester/screens/Profile_Screen/profile_header.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.userId});
  final String userId;
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String fullName = '';
  List followers = [];
  List following = [];
  String purl = '';
  bool isLoading = true;
  String gender = '';
  int goalsCount = 0;
  String myuid = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          fullName = userSnapshot['fname'] + ' ' + userSnapshot['lname'];
          purl = userSnapshot['purl'];
          gender = userSnapshot['gender'];
          followers = List<String>.from(userSnapshot['followers'] ?? []);
          following = List<String>.from(userSnapshot['following'] ?? []);
        });

        goalsCount = await updateGoalsCount(widget.userId);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ProfileHeader(
                    profileImageUrl: purl,
                    id: widget.userId,
                    username: fullName,
                    postsCount: goalsCount,
                    followers: followers,
                    following: following,
                    followersCount: followers.length,
                    followingCount: following.length,
                    isFollowing: followers.contains(myuid),
                    isFollowedBy: following.contains(myuid),
                    isCurrentUser: myuid == widget.userId,
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
