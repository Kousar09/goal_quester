import 'package:flutter/material.dart';
import 'package:goal_quester/screens/edit_profile_screen.dart';
import 'package:goal_quester/screens/list_users.dart';
import 'package:goal_quester/screens/one_ot_one_chat.dart';
import 'package:goal_quester/services/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatefulWidget {
  final String profileImageUrl;
  final String id;
  final String username;
  final int postsCount;
  final List followers;
  final List following;
  final int followersCount;
  final int followingCount;
  bool? isFollowing;
  final bool isFollowedBy;
  final bool isCurrentUser;

  ProfileHeader({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.isFollowing,
    required this.isFollowedBy,
    required this.isCurrentUser,
    required this.followers,
    required this.following,
    required this.id,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 45.0,
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to posts
                        },
                        child: Column(
                          children: [
                            Text(
                              '${widget.postsCount}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Goals'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ListUsers(users: widget.followers)));
                        },
                        child: Column(
                          children: [
                            Text(
                              '${widget.followersCount}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Followers'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ListUsers(users: widget.following)));
                        },
                        child: Column(
                          children: [
                            Text(
                              '${widget.followingCount}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Following'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          widget.isCurrentUser
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(120, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    if (widget.isFollowing!) {
                      user.removeFollowing(widget.id);
                      setState(() {
                        widget.isFollowing = false;
                      });
                    } else {
                      user.addFollowing(widget.id);
                      setState(() {
                        widget.isFollowing = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isFollowing! ? Colors.red : Colors.blue,
                    minimumSize: const Size(100, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    widget.isFollowing! ? 'Unfollow' : 'Follow',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
          const SizedBox(height: 10.0),
          !widget.isCurrentUser && widget.isFollowedBy && widget.isFollowing!
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OneToOneChat(
                                  userId: widget.id,
                                  userData: {
                                    'name': widget.username,
                                    'purl': widget.profileImageUrl,
                                  },
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(100, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
