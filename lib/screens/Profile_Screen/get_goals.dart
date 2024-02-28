import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/goal_container.dart';
import 'package:goal_quester/screens/Profile_Screen/shimmer_loading_container.dart';
import 'package:google_fonts/google_fonts.dart';

class GetGoals extends StatelessWidget {
  final String type;
  final String userId;
  const GetGoals({super.key, required this.type, required this.userId});

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
              .where('visibility',
                  isEqualTo: type == 'P&P' ? ['Public', 'Private'] : type)
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
                  "No goals found.",
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
            return ListView(
              shrinkWrap: true,
              children: goalWidgets,
            );
          },
        )
      ],
    );
  }
}
