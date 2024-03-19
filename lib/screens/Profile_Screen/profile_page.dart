import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/get_goals.dart';
import 'package:goal_quester/screens/Profile_Screen/profile_header.dart';
import 'package:goal_quester/services/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final myUserId = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, _) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ProfileHeader(
                profileImageUrl: user.profileUrl,
                username: '${user.firstName} ${user.lastName}',
                postsCount: user.goalsCount,
                followersCount: user.followers.length,
                followingCount: user.following.length,
                isFollowing: false,
                isFollowedBy: false,
                isCurrentUser: true,
                followers: user.followers,
                following: user.following,
                id: myUserId,
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
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
      },
    );
  }
}
