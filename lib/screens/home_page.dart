import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goal_quester/screens/goal_page.dart';
import 'package:goal_quester/screens/goal_setup.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopContainer(context),
        const SizedBox(height: 20),
        _buildCurrentGoalsText(context),
        _buildGoalsList(),
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

  Widget _buildGoalsList() {
    return StreamBuilder(
      stream: _firestore
          .collection('goals')
          .doc(userId)
          .collection('user_goals')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
              children: List.generate(4, (index) => ShimmerLoadingContainer()));
        }
        if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        }
        var goals = snapshot.data!.docs.reversed;
        List<Widget> goalWidgets = [];
        for (var goal in goals) {
          Map<String, dynamic> goalData = goal.data() as Map<String, dynamic>;
          print(goalData);
          goalWidgets.add(GoalContainer(goalId: goal.id, goalData: goalData));
        }
        return Expanded(
          child: ListView(
            children: goalWidgets,
          ),
        );
      },
    );
  }
}

class GoalContainer extends StatelessWidget {
  GoalContainer({Key? key, required this.goalId, required this.goalData});
  String goalId;
  Map<dynamic, dynamic> goalData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => GoalDetailsScreen(
              goalData: goalData,
              goalId: goalId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGoalDetails(context),
              const Spacer(),
              _buildCompletionPercentage(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          goalData["title"],
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildTaskDetails(context),
      ],
    );
  }

  Widget _buildTaskDetails(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: '${goalData['totalTasks']} Tasks : ',
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: '${goalData['pending']} Pending, ',
            style: const TextStyle(
              color: Colors.orange,
            ),
          ),
          TextSpan(
            text: '${goalData['completed']} Completed',
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPercentage(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text:
                '${((goalData['completed'] / goalData['totalTasks']) * 100).toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color_constants.stage4,
            ),
          ),
          const TextSpan(
            text: '%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerLoadingContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        // Handle the tap event if needed
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerContainer(width * 0.3, 12.0),
                  const SizedBox(height: 8.0),
                  _buildShimmerContainer(100.0, 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(double containerWidth, double containerHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: containerWidth,
        height: containerHeight,
        color: Colors.white,
      ),
    );
  }
}
