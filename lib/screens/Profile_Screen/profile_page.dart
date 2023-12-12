import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/get_goals.dart';
import 'package:goal_quester/screens/Profile_Screen/user_profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String fullName = '';
  String purl = '';
  String gender = '';
  String myUserId = FirebaseAuth.instance.currentUser!.uid;

  late TabController _tabController;

  Future<void> fetchUserData() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var user in snapshot.docs) {
        if (user.id == myUserId) {
          fullName = user['fname'] + ' ' + user['lname'];
          purl = user['purl'];
          gender = user['gender'];
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                UserProfileHeader(
                  fullName: fullName,
                  purl: purl,
                  userId: myUserId,
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Public Goals'),
                    Tab(text: 'Private Goals'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      GetGoals(
                        type: 'Public',
                        userId: myUserId,
                      ),
                      GetGoals(
                        type: 'Private',
                        userId: myUserId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
