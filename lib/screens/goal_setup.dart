import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
  String goalVisibility = 'Public';
  String goalType = 'Select an Option';
  final List goalCategories = [
    'Select an Option',
    'Study Related',
    'Excersise Related',
    'Job Related',
    'Short Term',
    'Others'
  ];
  String startDate = '';
  String endDate = '';
  bool isLoading = false;

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      startDate = args.value.startDate.toString();
      endDate = args.value.endDate.toString();
    });
  }

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
        setState(() {
          isLoading = true;
        });
        final String userId = FirebaseAuth.instance.currentUser!.uid;
        final String goalId = const Uuid().v1();
        final CollectionReference goalsCollection = FirebaseFirestore.instance
            .collection('goals')
            .doc(userId)
            .collection('user_goals');
        final DocumentReference goalDocRef = goalsCollection.doc(goalId);

// Save goal data
        await goalDocRef.set({
          "title": goalTitle,
          "totalTasks": tasks.length,
          "completed": 0,
          "pending": tasks.length,
          "type": goalType,
          "visibility": goalVisibility,
          "startDate": startDate,
          "endDate": endDate,
          "createdAt": DateTime.now(),
        });

// Save individual tasks
        for (final String task in taskTitles) {
          final String taskId = const Uuid().v1();
          await goalDocRef
              .collection('tasks')
              .doc(taskId)
              .set({"taskTitle": task, "isCompleted": false});
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Goal added successfully")));
        Navigator.pop(context);
      }
    } catch (error) {
      // Handle errors here
      setState(() {
        isLoading = false;
      });
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding goal. Please try again.")),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildGoalTitleTextField(),
                      const SizedBox(height: 20),
                      buildDatePicker(),
                      const SizedBox(height: 20),
                      buildGoalTypeDropDown(),
                      buildGoalVisibilityDropDown(),
                      buildTasksListView(),
                      buildAddTaskButton(),
                    ],
                  ),
                ),
              ),
              buildSaveButton(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select start and end Date",
          style: GoogleFonts.notoSans(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 17),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 246, 237, 237)),
          child: SfDateRangePicker(
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.range,
          ),
        ),
      ],
    );
  }

  Widget buildGoalTypeDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Goal Type",
          style: GoogleFonts.notoSans(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 17),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 246, 237, 237)),
          child: DropdownButton(
            isExpanded: true,

            borderRadius: const BorderRadius.all(Radius.circular(5)),
            hint: const Text(
                'Select Your Goal Type'), // Not necessary for Option 1
            value: goalType,
            onChanged: (newValue) {
              setState(() {
                goalType = newValue.toString();
              });
            },
            items: goalCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }

  Widget buildGoalVisibilityDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Goal Visibility",
          style: GoogleFonts.notoSans(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 17),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 246, 237, 237)),
          child: DropdownButton(
            isExpanded: true,

            borderRadius: const BorderRadius.all(Radius.circular(5)),
            hint: const Text(
                'Select Your Goal Type'), // Not necessary for Option 1
            value: goalVisibility,
            onChanged: (newValue) {
              setState(() {
                goalVisibility = newValue.toString();
              });
            },
            items: ['Public', 'Private'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }

  Widget buildGoalTitleTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Goal Title",
          style: GoogleFonts.notoSans(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 17),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 246, 237, 237)),
          child: TextFormField(
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
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: "Enter Goal Title"),
          ),
        ),
      ],
    );
  }

  Widget buildTasksListView() {
    // return ListView(
    //   shrinkWrap: true,
    //   children: tasks,
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Add Corresponding Tasks:",
          style: GoogleFonts.notoSans(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return tasks[index];
            },
          ),
        ),
      ],
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
      child: const Row(
        children: [
          Icon(Icons.add),
          SizedBox(width: 5),
          Text('add a new task'),
        ],
      ),
    );
  }

  Widget buildSaveButton(double width) {
    return isLoading
        ? SpinKitThreeInOut(
            color: color_constants.stage4,
            size: 30.0,
          )
        : Center(
            child: SizedBox(
              width: width - 40,
              child: ElevatedButton(
                onPressed: saveGoal,
                style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: color_constants.stage4,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'notoSans',
                    )),
                child:
                    const Text('Save', style: TextStyle(color: Colors.white)),
              ),
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
