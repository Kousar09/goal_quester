import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/goal_container.dart';
import 'package:goal_quester/screens/Profile_Screen/shimmer_loading_container.dart';

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
              .doc(userId)
              .collection('user_goals')
              .where('visibility', isEqualTo: type)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                  children:
                      List.generate(4, (index) => ShimmerLoadingContainer()));
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
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
