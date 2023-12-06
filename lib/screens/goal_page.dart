import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder(
                stream: _firestore
                    .collection('goals')
                    .doc(userId)
                    .collection('user_goals')
                    .doc(widget.goalId)
                    .collection('tasks')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('');
                  }
                  if (snapshot.hasError) {
                    // Handle error
                    return Text('Error: ${snapshot.error}');
                  }
                  var tasks = snapshot.data!.docs.reversed;
                  print(tasks);
                  List<Widget> compTasks = [];
                  List<Widget> pendTasks = [];

                  for (var task in tasks) {
                    if (task['isCompleted']) {
                      compTasks.add(TaskContainer(
                          userId: userId,
                          goalId: widget.goalId,
                          taskId: task.id,
                          taskTitle: task['taskTitle']));
                    } else {
                      pendTasks.add(TaskContainer(
                          userId: userId,
                          goalId: widget.goalId,
                          taskId: task.id,
                          taskTitle: task['taskTitle']));
                    }
                  }
                  return Column(
                    children: [
                      Text('Pending Tasks'),
                      Expanded(
                        child: ListView(
                          children: pendTasks,
                        ),
                      ),
                      Text('Completed Tasks'),
                      Expanded(
                        child: ListView(
                          children: compTasks,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 6.0,
              animation: true,
              percent: 0,
              center: Text(
                "${0.toStringAsFixed(1)}%",
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
  });

  final String userId;
  final String goalId;
  final String taskId;
  final String taskTitle;

  @override
  State<TaskContainer> createState() => _TaskContainerState();
}

class _TaskContainerState extends State<TaskContainer> {
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('goals')
          .doc(widget.userId)
          .collection('user_goals')
          .doc(widget.goalId)
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (snapshot.exists) {
        // Document exists, update the state with the value of isCompleted
        setState(() {
          isCompleted = snapshot.data()?['isCompleted'] ?? false;
        });
      } else {
        // Document does not exist, handle accordingly
        setState(() {
          isCompleted = false; // or another default value
        });
      }
    } catch (error) {
      // Handle errors
      print('Error fetching data: $error');
      setState(() {
        isCompleted = false; // or another default value
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference taskRef = FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.userId)
        .collection('user_goals')
        .doc(widget.goalId)
        .collection('tasks')
        .doc(widget.taskId);
    DocumentReference goalRef = FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.userId)
        .collection('user_goals')
        .doc(widget.goalId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (val) async {
              try {
                final snapshot = await taskRef.get();

                if (snapshot.exists) {
                  // Document exists, update the 'isCompleted' field
                  await taskRef.update({
                    'isCompleted': !(snapshot.data() as Map)['isCompleted']
                  });
                  setState(() {
                    isCompleted = !(snapshot.data() as Map)['isCompleted'];
                  });
                  if (isCompleted) {
                    await goalRef.update({
                      'completed': FieldValue.increment(1),
                      'pending': FieldValue.increment(-1),
                    });
                  } else {
                    await goalRef.update({
                      'completed': FieldValue.increment(-1),
                      'pending': FieldValue.increment(1),
                    });
                  }
                } else {
                  print('Document does not exist.');
                }
              } catch (error) {
                // Handle errors
                print('Error updating data: $error');
              }
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
