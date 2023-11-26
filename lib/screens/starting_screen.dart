import 'package:flutter/material.dart';
import 'package:goal_quester/screens/login_screen.dart';
import 'package:goal_quester/screens/register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Goal",
                      style: GoogleFonts.aBeeZee(
                          fontWeight: FontWeight.bold, fontSize: 60),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Quester",
                      style: GoogleFonts.aBeeZee(
                          fontWeight: FontWeight.bold, fontSize: 60),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(width - 30, 50),
                        shadowColor: Colors.transparent,
                        backgroundColor: const Color(0xFFA155B9),
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'notoSans',
                        )),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    )),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(width - 30, 50),
                        shadowColor: Colors.transparent,
                        backgroundColor: const Color(0xFFF765A3),
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'notoSans',
                        )),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ));
  }
}
