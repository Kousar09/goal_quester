import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  String myuid = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      setState(() {
        isLoading = true; // Set isLoading to true before fetching data
      });

      var snapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var user in snapshot.docs) {
        if (user.id == widget.userId) {
          setState(() {
            fullName = user['fname'] + ' ' + user['lname'];
            purl = user['purl'];
            gender = user['gender'];
            followers = List<String>.from(user['followers'] ?? []);
            following = List<String>.from(user['following'] ?? []);
            isLoading = false; // Set isLoading to false after fetching data
          });
          return; // Exit loop once user data is found
        }
      }

      // If the loop completes without finding user data, handle appropriately
      // For example, show a message indicating user data was not found
    } catch (e) {
      // Handle any errors that occurred during the data fetching process
      setState(() {
        // Update state to reflect error condition
        isLoading = false; // Set isLoading to false to stop loading indicator
        // You might want to display an error message to the user or handle the error in another way
      });
      print('Error fetching user data: $e');
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
                    postsCount: 5,
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
