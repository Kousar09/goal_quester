import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/image_widget.dart';
import 'package:goal_quester/screens/one_ot_one_chat.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var users = snapshot.data!.docs;

        List<Widget> userWidgets = [];
        for (var user in users) {
          if (user.id == FirebaseAuth.instance.currentUser!.uid) {
            continue;
          }
          var name = user['fname'] + ' ' + user['lname'];
          var purl = user['purl'];
          userWidgets.add(UserContainer(
              id: user.id, name: name, purl: purl, gender: user['gender']));
        }
        return ListView(
          children: userWidgets,
        );
      },
    );
  }
}

class UserContainer extends StatelessWidget {
  const UserContainer(
      {super.key,
      required this.id,
      required this.name,
      required this.purl,
      required this.gender});
  final String name;
  final String purl;
  final String id;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OneToOneChat(
                    userId: id, userData: {'name': name, 'purl': purl})))
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ProfileImage(
                purl: purl,
                gender: gender,
                height: 60,
                width: 60,
                borderRadius: 30),
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
