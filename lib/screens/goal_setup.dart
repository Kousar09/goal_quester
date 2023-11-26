import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GoalSetUp extends StatefulWidget {
  const GoalSetUp({Key? key}) : super(key: key);

  @override
  State<GoalSetUp> createState() => _GoalSetUpState();
}

class _GoalSetUpState extends State<GoalSetUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<Task> tasks = [];
  final List<String> taskTitles = [];
  late String goalTitle;

  @override
  void initState() {
    super.initState();
    clearTaskData();
  }

  void clearTaskData() {
    tasks.clear();
    taskTitles.clear();
  }

  Future<void> saveGoal() async {
    try {
      if (_formKey.currentState!.validate()) {
        final String userId = FirebaseAuth.instance.currentUser!.uid;
        final String goalId = const Uuid().v1();
        final DatabaseReference ref = FirebaseDatabase.instance
            .ref('myapp/users/$userId/all_goals/$goalId');

        // Save goal data
        await ref.set({
          "title": goalTitle,
          "totalTasks": tasks.length,
          "completed": 0,
          "pending": tasks.length,
          "createdAt": DateTime.now().toString(),
        });

        // Save individual tasks
        for (final String task in taskTitles) {
          final String taskId = const Uuid().v1();
          await ref
              .child('tasks/$taskId')
              .set({"taskTitle": task, "isCompleted": false});
        }

        // Show success message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Goal added successfully")));
        Navigator.pop(context);
      }
    } catch (error) {
      // Handle errors here
      print("Error saving goal: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding goal. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Set up a goal')),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildGoalTitleTextField(),
              const SizedBox(height: 10),
              const Text("Add the corresponding tasks:"),
              const SizedBox(height: 10),
              buildTasksListView(),
              buildAddTaskButton(),
              const Spacer(),
              buildSaveButton(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGoalTitleTextField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Goal title should not be empty";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          goalTitle = value;
        });
      },
      autocorrect: true,
      decoration: InputDecoration(
        hintText: 'Enter the title of the goal',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget buildTasksListView() {
    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return tasks[index];
        },
      ),
    );
  }

  Widget buildAddTaskButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          taskTitles.add('');
          tasks.add(Task(index: tasks.length, taskTitles: taskTitles));
        });
      },
      child: Row(
        children: [
          Icon(Icons.add),
          SizedBox(width: 5),
          Text('add a new task'),
        ],
      ),
    );
  }

  Widget buildSaveButton(double width) {
    return Center(
      child: ElevatedButton(
        onPressed: saveGoal,
        style: TextButton.styleFrom(
          minimumSize: Size(width, 40),
          backgroundColor: Colors.purple,
        ),
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class Task extends StatefulWidget {
  Task({Key? key, required this.taskTitles, required this.index})
      : super(key: key);

  final List<String> taskTitles;
  final int index;

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(value: false, onChanged: (val) => {}),
          Expanded(
            child: TextFormField(
              initialValue: widget.taskTitles[widget.index],
              onChanged: (value) {
                widget.taskTitles[widget.index] = value;
              },
              decoration:
                  const InputDecoration.collapsed(hintText: 'Enter the task'),
            ),
          ),
        ],
      ),
    );
  }
}
