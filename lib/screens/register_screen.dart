import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goal_quester/screens/collect_profile_details.dart';
import 'package:goal_quester/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var email = '';
  var password = '';
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;

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
                        "Create Account",
                        style: GoogleFonts.notoSans(
                            textStyle: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Create your account with email id",
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
                          color: Color(0xFFF765A3),
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
                            color: Color(0xFFF765A3),
                          ),
                          hintText: "Enter Password"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _isLoading
                      ? const SpinKitThreeInOut(
                          color: Color(0xFFF765A3),
                          size: 30.0,
                        )
                      : SizedBox(
                          width: width - 40,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileDetails(
                                            email: email, pass: password)));
                              },
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.transparent,
                                  backgroundColor: const Color(0xFFF765A3),
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
                                "Sign Up",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?  ",
                        style:
                            GoogleFonts.notoSans(textStyle: const TextStyle()),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.notoSans(
                              color: const Color(0xFFF765A3),
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
