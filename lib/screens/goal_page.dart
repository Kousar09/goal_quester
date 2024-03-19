import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/screens/edit_goal_page.dart';
import 'package:goal_quester/services/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen(
      {super.key,
      required this.userId,
      required this.goalId,
      required this.goalData});
  final Map goalData;
  final String goalId;
  final String userId;

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class Task {
  String id = '';
  String title = '';
  bool isCompleted = false;
  Task(String id, String title, bool isCompleted) {
    id = this.id;
    title = this.title;
    isCompleted = this.isCompleted;
  }
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  List<TaskContainer> taskWidgets = [];
  Map taskState = {};

  bool isLoading = true;
  int completed = 0;
  int pending = 0;
  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  void deactivate() {
    super.deactivate();
    changeTasksState();
  }

  void changeTasksState() {
    final snapshot = FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.goalId)
        .collection('tasks');
    for (var task in taskState.entries) {
      snapshot.doc(task.key).update({'isCompleted': task.value});
    }
    FirebaseFirestore.instance.collection('goals').doc(widget.goalId).update({
      'completed': completed,
      'pending': pending,
    });
  }

  Future<void> fetchTasks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.goalId)
        .collection('tasks')
        .get();
    for (var element in snapshot.docs) {
      taskState[element.id] = element['isCompleted'];
      setState(() {
        if (element['isCompleted'] == true) {
          completed += 1;
        } else {
          pending += 1;
        }
      });
    }
    for (var element in snapshot.docs) {
      taskWidgets.add(TaskContainer(
        userId: widget.userId,
        taskId: element.id,
        taskTitle: element['taskTitle'],
        tasksState: taskState,
        onCompletionChanged: (isCompleted) {
          // Update the completion percentage when a task is completed or pending
          setState(() {
            if (isCompleted) {
              completed += 1;
              pending -= 1;
            } else {
              completed -= 1;
              pending += 1;
            }
          });
        },
      ));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Goal Details"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {
                'Set as ${widget.goalData['visibility'] == 'Public' ? 'Private' : 'Public'}',
                'Edit goal',
                'Delete goal'
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        backgroundColor: color_constants.primary,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goalData['title'],
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(widget.goalData['type']),
                          ],
                        ),
                      ),
                      _buildCompletionPercentage(context, completed, pending)
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: GoalStatusWidget(
                            startDate:
                                DateTime.parse(widget.goalData['startDate']),
                            endDate:
                                DateTime.parse(widget.goalData['endDate'])),
                      ),
                      PublicPrivateIndicator(
                          visibility: widget.goalData['visibility']),
                    ],
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: taskWidgets,
                  ),
                ],
              ),
            ),
    );
  }

  void handleClick(String value) {
    if (value == 'Set as Public') {
      FirebaseFirestore.instance
          .collection('goals')
          .doc(widget.goalId)
          .update({'visibility': 'Public'});
      setState(() {
        widget.goalData['visibility'] = 'Public';
      });
    } else if (value == 'Set as Private') {
      FirebaseFirestore.instance
          .collection('goals')
          .doc(widget.goalId)
          .update({'visibility': 'Private'});
      setState(() {
        widget.goalData['visibility'] = 'Private';
      });
    } else if (value == 'Delete goal') {
      _showDeleteConfirmationDialog(context);
    } else if (value == "Edit goal") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EditGoal(goalData: widget.goalData, goalId: widget.goalId)));
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: const Text('Are you sure you want to delete this goal?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                QuerySnapshot tasks = await FirebaseFirestore.instance
                    .collection('goals')
                    .doc(widget.goalId)
                    .collection('tasks')
                    .get();
                for (var task in tasks.docs) {
                  FirebaseFirestore.instance
                      .collection('goals')
                      .doc(widget.goalId)
                      .collection('tasks')
                      .doc(task.id)
                      .delete();
                }
                FirebaseFirestore.instance
                    .collection('goals')
                    .doc(widget.goalId)
                    .delete();
                final user = Provider.of<UserProvider>(context, listen: false);
                user.decrementGoalCOunt();
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class TaskContainer extends StatefulWidget {
  const TaskContainer(
      {super.key,
      required this.userId,
      required this.taskId,
      required this.taskTitle,
      required this.tasksState,
      required this.onCompletionChanged});

  final String userId;
  final String taskId;
  final String taskTitle;
  final Map tasksState;
  final Function(bool isCompleted) onCompletionChanged;

  @override
  State<TaskContainer> createState() => _TaskContainerState();
}

class _TaskContainerState extends State<TaskContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Checkbox(
            value: widget.tasksState[widget.taskId],
            onChanged: widget.userId != FirebaseAuth.instance.currentUser!.uid
                ? null
                : (val) {
                    setState(() {
                      widget.tasksState[widget.taskId] =
                          !widget.tasksState[widget.taskId];
                      widget.onCompletionChanged(
                          widget.tasksState[widget.taskId]);
                    });
                  },
          ),
          Text(
            widget.taskTitle,
            style: TextStyle(
              decoration: widget.tasksState[widget.taskId]
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

class PublicPrivateIndicator extends StatelessWidget {
  const PublicPrivateIndicator({Key? key, required this.visibility})
      : super(key: key);

  final String visibility;

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    Color TextColor;
    IconData indicatorIcon;

    // Set color and icon based on the visibility value
    if (visibility == 'Public') {
      indicatorColor = Colors.green.shade100;
      TextColor = Colors.green.shade300;
      indicatorIcon = Icons.public;
    } else {
      indicatorColor = Colors.red.shade100;
      TextColor = Colors.red.shade300;
      indicatorIcon = Icons.lock;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Adjust width to content
        children: [
          Text(
            visibility.toUpperCase(),
            style: TextStyle(
                color: TextColor,
                fontSize: 12), // Darker text color and reduced font size
          ),
          const SizedBox(width: 4),
          Icon(indicatorIcon,
              color: TextColor,
              size: 16), // Darker icon color and reduced icon size
        ],
      ),
    );
  }
}

Widget _buildCompletionPercentage(
    BuildContext context, int completed, int pending) {
  return RichText(
    text: TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: ((completed / (completed + pending)) * 100).toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color_constants.stage4,
          ),
        ),
        const TextSpan(
          text: '%',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
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
          fontSize: 18, color: statusColor, fontWeight: FontWeight.bold),
    );
  }
}
