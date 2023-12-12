import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/screens/Profile_Screen/get_goals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goal_quester/screens/goal_setup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String userId = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopContainer(context),
        const SizedBox(height: 20),
        _buildCurrentGoalsText(context),
        SingleChildScrollView(
          child: Column(
            children: [
              GetGoals(type: 'Public', userId: userId),
              GetGoals(type: 'Private', userId: userId),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTopContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color_constants.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60.0),
          bottomRight: Radius.circular(60.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTopText(),
          const SizedBox(height: 16.0),
          _buildSetUpGoalButton(context),
        ],
      ),
    );
  }

  Widget _buildTopText() {
    return Text(
      "Have a goal, set up and start working for it..",
      style: GoogleFonts.notoSans(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSetUpGoalButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GoalSetUp(),
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
          "Set up a goal",
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentGoalsText(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Text(
        "Current Goals:",
        style: GoogleFonts.notoSans(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }
}
