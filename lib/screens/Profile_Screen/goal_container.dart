import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/screens/goal_page.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalContainer extends StatelessWidget {
  const GoalContainer(
      {super.key,
      required this.userId,
      required this.goalId,
      required this.goalData});
  final String userId;
  final String goalId;
  final Map<dynamic, dynamic> goalData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => GoalDetailsScreen(
              userId: userId,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoalDetails(context),
              _buildCompletionPercentage(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalDetails(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goalData["title"],
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          GoalStatusWidget(
              startDate: DateTime.parse(goalData['startDate']),
              endDate: DateTime.parse(goalData['endDate'])),
          _buildTaskDetails(context),
        ],
      ),
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

class GoalStatusWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const GoalStatusWidget(
      {super.key, required this.startDate, required this.endDate});

  String calculateGoalStatus() {
    DateTime currentDate = DateTime.now();

    if (currentDate.isBefore(startDate)) {
      // Calculate days to start the goal
      int daysToStart = startDate.difference(currentDate).inDays;
      return '$daysToStart days to start the goal';
    } else if (currentDate.isBefore(endDate)) {
      // Calculate days remaining
      int daysRemaining = endDate.difference(currentDate).inDays;
      return '$daysRemaining days remaining';
    } else {
      return 'Goal time ended';
    }
  }

  @override
  Widget build(BuildContext context) {
    String goalStatus = calculateGoalStatus();
    Color statusColor = Colors.black; // Default color

    // Set color based on goal status
    if (goalStatus.contains('to start')) {
      statusColor = Colors.blue; // Choose a color for days to start
    } else if (goalStatus.contains('remaining')) {
      statusColor = Colors.green; // Choose a color for days remaining
    } else {
      statusColor = Colors.red; // Choose a color for goal time ended
    }

    return Text(
      goalStatus,
      style: TextStyle(
          fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
    );
  }
}
