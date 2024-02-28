import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goal_quester/main.dart';
import 'package:goal_quester/screens/register_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/color_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var email = '';
  var password = '';
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;

      if (authResult.additionalUserInfo!.isNewUser) {
        if (user != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MyHomePage()));
        }
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyHomePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Login Account",
                        style: GoogleFonts.notoSans(
                            textStyle: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Please login with registered account",
                        style:
                            GoogleFonts.notoSans(textStyle: const TextStyle()),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Email",
                    style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        filled: true,
                        fillColor: Color.fromARGB(255, 246, 237, 237),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide.none),
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Color(0xFFA155B9),
                        ),
                        hintText: "Enter Your E-Mail"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Password",
                    style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    //height: 60,
                    width: width - width * 0.1,
                    child: TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          filled: true,
                          fillColor: Color.fromARGB(255, 246, 237, 237),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            Icons.key,
                            color: Color(0xFFA155B9),
                          ),
                          hintText: "Enter Password"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forget Password?",
                        style: GoogleFonts.notoSans(
                            textStyle: TextStyle(
                                color: color_constants.stage3,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _isLoading
                      ? SpinKitThreeInOut(
                          color: color_constants.stage3,
                          size: 30.0,
                        )
                      : SizedBox(
                          width: width - 40,
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await _auth.signInWithEmailAndPassword(
                                        email: email.trim(),
                                        password: password);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MyApp()));
                                  } catch (e) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Error'),
                                            content: Text(e.toString()),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  }),
                                            ],
                                          );
                                        });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.transparent,
                                  backgroundColor: color_constants.stage3,
                                  padding: const EdgeInsets.all(15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'notoSans',
                                  )),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                  const SizedBox(height: 15),
                  const Center(child: Text('Or')),
                  const SizedBox(height: 15),
                  Container(
                    width: double.maxFinite,
                    height: 56,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(16)),
                    child: ElevatedButton(
                      onPressed: () {
                        signUpWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/ic_googleLogo.svg',
                            height: 24.0, // Adjust the height as needed
                            width: 24.0, // Adjust the width as needed
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'Sign In with Google',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?  ",
                        style:
                            GoogleFonts.notoSans(textStyle: const TextStyle()),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen()));
                        },
                        child: Text(
                          "Create Account",
                          style: GoogleFonts.notoSans(
                              color: color_constants.stage3,
                              fontWeight: FontWeight.bold,
                              textStyle: const TextStyle()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
