import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

class EditGoal extends StatefulWidget {
  const EditGoal({Key? key, required this.goalData, required this.goalId})
      : super(key: key);
  final Map goalData;
  final String goalId;

  @override
  State<EditGoal> createState() => _EditGoalState();
}

class _EditGoalState extends State<EditGoal> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late String goalTitle;
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
  Map taskState = {};
  Map taskTitles = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      goalTitle = widget.goalData['title'];
      startDate = widget.goalData['startDate'];
      endDate = widget.goalData['endDate'];
      goalType = widget.goalData['type'];
    });
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.goalId)
        .collection('tasks')
        .get();
    for (var element in snapshot.docs) {
      taskState[element.id] = element['isCompleted'];
      taskTitles[element.id] = element['taskTitle'];
    }
    setState(() {
      isLoading = false;
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      startDate = args.value.startDate.toString();
      endDate = args.value.endDate.toString();
    });
  }

  Future<void> saveGoal() async {
    try {
      if (_formKey.currentState!.validate()) {
        if (goalTitle == '' ||
            goalType == '' ||
            startDate == '' ||
            endDate == '') {
          // Show an error message if any required field is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in all the required fields"),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        setState(() {
          isLoading = true;
        });
        final CollectionReference goalsCollection =
            FirebaseFirestore.instance.collection('goals');

        final DocumentReference goalDocRef = goalsCollection.doc(widget.goalId);
        List<String> titleWords =
            removeStopWords(goalTitle).toLowerCase().split(' ');
        titleWords = titleWords + removeStopWords(goalType).split(" ");
        await goalDocRef.update({
          "title": goalTitle,
          "titleWords": titleWords,
          "type": goalType,
          "startDate": startDate,
          "endDate": endDate,
        });

// Save individual tasks
        taskTitles.forEach((key, value) async {
          {
            titleWords = titleWords + removeStopWords(value).split(" ");
            await goalDocRef.collection('tasks').doc(key).update({
              "taskTitle": value,
              "isCompleted": taskState[key],
            });
          }
        });

        goalDocRef.update({'titleWords': titleWords});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Goal Updated successfully")));
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (error) {
      // Handle errors here
      setState(() {
        isLoading = false;
      });
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error Updating goal. Please try again.")),
      );
    }
  }

  String removeStopWords(String text) {
    // Define a list of stop words
    List<String> stopWords = [
      'i',
      'me',
      'my',
      'myself',
      'we',
      'our',
      'ours',
      'ourselves',
      'you',
      'your',
      'yours',
      'yourself',
      'yourselves',
      'he',
      'him',
      'his',
      'himself',
      'she',
      'her',
      'hers',
      'herself',
      'it',
      'its',
      'itself',
      'they',
      'them',
      'their',
      'theirs',
      'themselves',
      'what',
      'which',
      'who',
      'whom',
      'this',
      'that',
      'these',
      'those',
      'am',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'having',
      'do',
      'does',
      'did',
      'doing',
      'a',
      'an',
      'the',
      'and',
      'but',
      'if',
      'or',
      'because',
      'as',
      'until',
      'while',
      'of',
      'at',
      'by',
      'for',
      'with',
      'about',
      'against',
      'between',
      'into',
      'through',
      'during',
      'before',
      'after',
      'above',
      'below',
      'to',
      'from',
      'up',
      'down',
      'in',
      'out',
      'on',
      'off',
      'over',
      'under',
      'again',
      'further',
      'then',
      'once',
      'here',
      'there',
      'when',
      'where',
      'why',
      'how',
      'all',
      'any',
      'both',
      'each',
      'few',
      'more',
      'most',
      'other',
      'some',
      'such',
      'no',
      'nor',
      'not',
      'only',
      'own',
      'same',
      'so',
      'than',
      'too',
      'very',
      's',
      't',
      'can',
      'will',
      'just',
      'don',
      'should',
      'now',
      'd',
      'll',
      'm',
      'o',
      're',
      've',
      'y',
      'ain',
      'aren',
      'couldn',
      'didn',
      'doesn',
      'hadn',
      'hasn',
      'haven',
      'isn',
      'ma',
      'mightn',
      'mustn',
      'needn',
      'shan',
      'shouldn',
      'wasn',
      'weren',
      'won',
      'wouldn',
      'related'
    ];

    // Split the text into words
    List<String> words = text.toLowerCase().split(' ');

    // Remove stop words
    List<String> filteredWords =
        words.where((word) => !stopWords.contains(word)).toList();

    // Join the filtered words back into a sentence
    String result = filteredWords.join(' ');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Update goal')),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildGoalTitleTextField(),
                      const SizedBox(height: 20),
                      Text(
                        "Select start and end Date",
                        style: GoogleFonts.notoSans(
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DateInputField(
                              date: DateTime.parse(startDate),
                              onDateSelected: (date) {
                                setState(() {
                                  startDate = date.toString();
                                });
                              }),
                          DateInputField(
                              date: DateTime.parse(endDate),
                              onDateSelected: (date) {
                                setState(() {
                                  endDate = date.toString();
                                });
                              }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildGoalTypeDropDown(),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Tasks",
                        style: GoogleFonts.notoSans(
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('goals')
                              .doc(widget.goalId)
                              .collection('tasks')
                              .orderBy('createdAt')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var tasks = snapshot.data!.docs;
                              List<TaskContainer> taskWidgets = [];
                              for (var task in tasks) {
                                taskWidgets.add(TaskContainer(
                                    goalId: widget.goalId,
                                    taskId: task.id,
                                    tasksState: taskState,
                                    taskTitles: taskTitles));
                              }
                              return Column(
                                children: taskWidgets,
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                      buildAddTaskButton()
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

  Widget buildAddTaskButton() {
    return TextButton(
      onPressed: () {
        String taskId = const Uuid().v1();
        setState(() {
          taskState[taskId] = false;
          taskTitles[taskId] = '';
        });
        FirebaseFirestore.instance
            .collection('goals')
            .doc(widget.goalId)
            .collection('tasks')
            .doc(taskId)
            .set({
          'taskTitle': '',
          'isCompleted': false,
          'createdAt': DateTime.now()
        });
        FirebaseFirestore.instance
            .collection('goals')
            .doc(widget.goalId)
            .update({
          "totalTasks": FieldValue.increment(1),
          "pending": FieldValue.increment(1),
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
            initialSelectedRange: PickerDateRange(
                DateTime.parse(startDate), DateTime.parse(endDate)),
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
            initialValue: goalTitle,
            textCapitalization: TextCapitalization.sentences,
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
                    const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
  }
}

class DateInputField extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onDateSelected;

  const DateInputField({super.key, 
    required this.date,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          padding: const EdgeInsets.all(8),
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: SfDateRangePicker(
            initialSelectedDates: [date],
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              Navigator.pop(context, args.value);
            },
            selectionMode: DateRangePickerSelectionMode.single,
          ),
        );
      },
    );

    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 246, 237, 237)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskContainer extends StatefulWidget {
  const TaskContainer(
      {super.key,
      required this.goalId,
      required this.taskId,
      required this.tasksState,
      required this.taskTitles});

  final String goalId;
  final String taskId;
  final Map tasksState;
  final Map taskTitles;

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
              value: widget.tasksState[widget.taskId] ?? false,
              onChanged: (val) {}),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                initialValue: widget.taskTitles[widget.taskId],
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Enter Task title'),
                onChanged: (val) {
                  setState(() {
                    widget.taskTitles[widget.taskId] = val;
                  });
                },
              ),
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red.shade300,
              ))
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                FirebaseFirestore.instance
                    .collection('goals')
                    .doc(widget.goalId)
                    .collection('tasks')
                    .doc(widget.taskId)
                    .delete();
                FirebaseFirestore.instance
                    .collection('goals')
                    .doc(widget.goalId)
                    .update({'totalTasks': FieldValue.increment(-1)});
                if (widget.tasksState[widget.taskId] == true) {
                  FirebaseFirestore.instance
                      .collection('goals')
                      .doc(widget.goalId)
                      .update({'completed': FieldValue.increment(-1)});
                } else {
                  FirebaseFirestore.instance
                      .collection('goals')
                      .doc(widget.goalId)
                      .update({'pending': FieldValue.increment(-1)});
                }
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
