import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? _oldPassword;
  String? _newPassword;
  String? _confirmPassword;
  bool isloading = false;

  Future<void> _changePassword() async {
    setState(() {
      isloading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email.toString(),
        password: _oldPassword!,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPassword!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password has been successfully changed"),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "An error occurred"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: GoogleFonts.notoSans(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 25,
                ),
                Text(
                  "Old Password",
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 237, 237),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        LineIcons.key,
                        color: Color.fromARGB(255, 214, 56, 185),
                      ),
                      hintText: "Old Password"),
                  obscureText: true,
                  onSaved: (value) => _oldPassword = value,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "New Password",
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 237, 237),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        LineIcons.key,
                        color: Color.fromARGB(255, 214, 56, 185),
                      ),
                      hintText: "New Password"),
                  obscureText: true,
                  onChanged: (value) => _newPassword = value,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Confirm Password",
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 237, 237),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        LineIcons.key,
                        color: Color.fromARGB(255, 214, 56, 185),
                      ),
                      hintText: "Confirm Password"),
                  obscureText: true,
                  onChanged: (value) => _confirmPassword = value,
                  validator: (value) {
                    if (value != _newPassword) {
                      return "Confirm password does not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                isloading
                    ? SpinKitThreeInOut(
                        color: color_constants.secondary,
                        size: 30.0,
                      )
                    : SizedBox(
                        width: width - 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              await _showConfirmationDialog();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              backgroundColor:
                                  const Color.fromARGB(255, 214, 56, 185),
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'notoSans',
                              )),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Password Change"),
          content: const Text("Are you sure you want to change your password?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _changePassword();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
