import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class ListUsers extends StatelessWidget {
  final List<dynamic> users;
  const ListUsers({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Users'),
      ),
      body: FutureBuilder<List<User>>(
        future: fetchUsers(users),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<User> userList = snapshot.data ?? [];
            // Logger().d(userList);
            return ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                User user = userList[index];
                return UserContainer(
                  id: user.id,
                  name: user.fullName,
                  purl: user.purl,
                  gender: user.gender,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<User>> fetchUsers(List<dynamic> userIds) async {
    List<User> userList = [];
    try {
      for (var element in userIds) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(element)
            .get();
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        userList.add(User(
            id: element,
            fullName: data['fname'] + ' ' + data['lname'],
            purl: data['purl'],
            gender: data['gender']));
      }
      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      return []; // Return an empty list in case of error
    }
  }
}

class User {
  final String id;
  final String fullName;
  final String purl;
  final String gender;

  User({
    required this.id,
    required this.fullName,
    required this.purl,
    required this.gender,
  });
}

class UserContainer extends StatelessWidget {
  const UserContainer({
    Key? key,
    required this.id,
    required this.name,
    required this.purl,
    required this.gender,
  }) : super(key: key);

  final String name;
  final String purl;
  final String id;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserProfile(userId: id)))
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(purl),
              radius: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}
