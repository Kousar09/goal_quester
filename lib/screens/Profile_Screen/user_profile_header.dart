import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/screens/image_widget.dart';
import 'package:goal_quester/screens/one_ot_one_chat.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    Key? key,
    required this.fullName,
    required this.purl,
    required this.gender,
    required this.userId,
  }) : super(key: key);

  final String fullName;
  final String purl;
  final String userId;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10),
          child: ProfileImage(
              purl: purl,
              gender: gender,
              height: 80,
              width: 80,
              borderRadius: 40),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Text(
              fullName,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            (userId != FirebaseAuth.instance.currentUser!.uid)
                ? _buildMessageButton(
                    context, userId, {'name': fullName, 'purl': purl})
                : const Text(''),
          ],
        )
      ],
    );
  }
}

Widget _buildMessageButton(BuildContext context, String userId, Map userData) {
  return Center(
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OneToOneChat(userId: userId, userData: userData),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color_constants.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        "Message",
        style: GoogleFonts.notoSans(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ),
  );
}
