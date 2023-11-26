import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class GoalDetailsScreen extends StatefulWidget {
  GoalDetailsScreen({Key? key, required this.goalId, required this.goalData});
  final Map goalData;
  final String goalId;

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  List<String> taskTitles = [];
  List<dynamic> taskIds = [];
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List percentage = [0.0];

  @override
  Widget build(BuildContext context) {
    List tasks = (widget.goalData['tasks'] as Map).values.toList();
    taskIds = (widget.goalData['tasks'] as Map).keys.toList();
    for (Map task in tasks) {
      taskTitles.add(task['taskTitle']);
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Goal Details"),
        backgroundColor: color_constants.primary,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.goalData['title'],
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: taskIds.length,
                itemBuilder: (context, index) {
                  return TaskContainer(
                    userId: userId,
                    goalId: widget.goalId,
                    taskId: taskIds[index],
                    taskTitle: taskTitles[index],
                    percentage: percentage,
                  );
                },
              ),
            ),
            const Spacer(),
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 6.0,
              animation: true,
              percent: percentage[0],
              center: Text(
                "${(percentage[0] * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

}

class TaskContainer extends StatefulWidget {
  TaskContainer({
    Key? key,
    required this.userId,
    required this.goalId,
    required this.taskId,
    required this.taskTitle,
    required this.percentage,
  });

  final String userId;
  final String goalId;
  final String taskId;
  final String taskTitle;
  final List percentage;

  @override
  State<TaskContainer> createState() => _TaskContainerState();
}

class _TaskContainerState extends State<TaskContainer> {
  bool isCompleted = false;
  bool isLoading = true;
  late DatabaseReference taskRef;
  late DatabaseReference goalRef;

  @override
  void initState() {
    super.initState();
    taskRef = FirebaseDatabase.instance.ref(
        'myapp/users/${widget.userId}/all_goals/${widget.goalId}/tasks/${widget.taskId}');
    goalRef = FirebaseDatabase.instance
        .ref('myapp/users/${widget.userId}/all_goals/${widget.goalId}');
    taskRef.child('isCompleted').onValue.listen((event) {
      isCompleted = event.snapshot.value as bool;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: SpinKitCircle(
              color: color_constants.primary,
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (val) {
                    setState(() {
                      isCompleted = !isCompleted;
                    });
                    taskRef.update({"isCompleted": isCompleted});

                    if (isCompleted) {
                      goalRef.update({
                        "completed": ServerValue.increment(1),
                        "pending": ServerValue.increment(-1),
                      });
                    } else {
                      goalRef.update({
                        "completed": ServerValue.increment(-1),
                        "pending": ServerValue.increment(1),
                      });
                    }
                    var completed =
                        (goalRef.child('completed').get() as DataSnapshot)
                            .value;
                    var pending =
                        (goalRef.child('pending').get() as DataSnapshot).value;
                    setState(() {
                      widget.percentage[0] = int.parse(completed.toString()) /
                              int.parse(completed.toString()) +
                          int.parse(pending.toString());
                    });
                  },
                ),
                Text(
                  widget.taskTitle,
                  style: TextStyle(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                )
              ],
            ),
          );
  }
}
