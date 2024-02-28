import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/screens/Profile_Screen/goal_container.dart';
import 'package:goal_quester/screens/Profile_Screen/shimmer_loading_container.dart';
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
        Expanded(child: SingleChildScrollView(child: GetGoals(userId: userId))),
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

class GetGoals extends StatelessWidget {
  final String userId;
  const GetGoals({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 8,
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('goals')
              .where("userId", isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                  children:
                      List.generate(4, (index) => const ShimmerLoadingContainer()));
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                margin: const EdgeInsets.all(8),
                child: Text(
                  "No goals found, Set up a goal and start working on it!",
                  style: GoogleFonts.notoSans(
                      fontSize: 18, color: Colors.red.shade300),
                ),
              );
            }
            var goals = snapshot.data!.docs.reversed;
            List<Widget> goalWidgets = [];
            for (var goal in goals) {
              Map<String, dynamic> goalData = goal.data();
              goalWidgets.add(GoalContainer(
                  userId: userId, goalId: goal.id, goalData: goalData));
            }

            return Column(children: goalWidgets);
          },
        )
      ],
    );
  }
}
