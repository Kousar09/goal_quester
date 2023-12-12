import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/screens/one_ot_one_chat.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    Key? key,
    required this.fullName,
    required this.purl,
    required this.userId,
  }) : super(key: key);

  final String fullName;
  final String purl;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        UserProfileImage(purl: purl),
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
                : Text(''),
          ],
        )
      ],
    );
  }
}

class UserProfileImage extends StatelessWidget {
  const UserProfileImage({Key? key, required this.purl}) : super(key: key);

  final String purl;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
