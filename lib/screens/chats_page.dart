import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/image_widget.dart';
import 'package:goal_quester/screens/one_ot_one_chat.dart';
import 'package:intl/intl.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var users = snapshot.data!.docs;

        List<Widget> userWidgets = [];
        Map data = {};
        for (var user in users) {
          if (user.id == FirebaseAuth.instance.currentUser!.uid) {
            data = user.data();
          }
        }
        for (var user in data.keys) {
          userWidgets.add(UserContainer(
            id: user,
            data: data[user],
          ));
        }
        return ListView(
          children: userWidgets,
        );
      },
    );
  }
}

class UserContainer extends StatefulWidget {
  const UserContainer({super.key, required this.id, required this.data});
  final String id;
  final Map data;

  @override
  State<UserContainer> createState() => _UserContainerState();
}

class _UserContainerState extends State<UserContainer> {
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
      if (user.id == widget.id) {
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
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OneToOneChat(
                      userId: widget.id,
                      userData: {
                        'name': fullName,
                        'purl': purl,
                      },
                    )));
        FirebaseFirestore.instance
            .collection('messages')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          widget.id: {
            'lastmessage': widget.data['lastmessage'],
            'timeStamp': widget.data['timeStamp'],
            'unseen': 0
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  ProfileImage(
                      purl: purl,
                      gender: gender,
                      height: 60,
                      width: 60,
                      borderRadius: 30),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.data['lastmessage'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(DateFormat('dd/MM')
                    .format(DateTime.parse(widget.data['timeStamp']))),
                const SizedBox(
                  height: 6,
                ),
                (widget.data['unseen'] > 0)
                    ? Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            widget.data['unseen']
                                .toString(), // Convert to string
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : const Text(''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
