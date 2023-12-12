import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goal_quester/screens/change_password_screen.dart';
import 'package:goal_quester/screens/edit_profile_screen.dart';
import 'package:goal_quester/screens/starting_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({super.key, required this.userData});
  late Map<String, dynamic> userData = {};

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StartingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.7,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.userData['purl'] == ''
                        ? Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.white,
                                    width: 1.7,
                                    style: BorderStyle.solid),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: widget.userData['gender'] == 'Female'
                                  ? SvgPicture.asset(
                                      'assets/images/profile_female.svg',
                                      height: 85,
                                      width: 85,
                                    )
                                  : SvgPicture.asset(
                                      'assets/images/profile_male.svg',
                                      height: 85,
                                      width: 85,
                                    ),
                            ))
                        : Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.white,
                                    width: 1.7,
                                    style: BorderStyle.solid),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: widget.userData['purl'],
                                  height: 85,
                                  width: 85,
                                  placeholder: (context, url) =>
                                      const SpinKitPulse(
                                    color: Colors.purpleAccent,
                                    size: 50.0,
                                  ),
                                )),
                          ),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.userData['fname'] +
                              ' ' +
                              widget.userData['lname']),
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 17),
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                      ],
                    ),
                  ]),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userData: widget.userData)))
              },
            ),
            ListTile(
                leading: const Icon(Icons.password),
                title: const Text('Change Password'),
                onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage()))
                    }),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () => {logout()},
            ),
          ],
        ),
      ),
    );
  }
}
