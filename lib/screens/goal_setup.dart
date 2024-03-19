import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:goal_quester/services/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    'Job Related',
    'Others'
  ];
  String startDate = DateTime.now().toString();
  String endDate = DateTime.now().toString();
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
        if (goalTitle == '' || goalType == 'Select an Option') {
          // Show an error message if any required field is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in all the required fields"),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        if (DateTime.parse(startDate).isAfter(DateTime.parse(endDate))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Enter valid start and end Dates "),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        setState(() {
          isLoading = true;
        });
        final String userId = FirebaseAuth.instance.currentUser!.uid;
        final String goalId = const Uuid().v1();
        final CollectionReference goalsCollection =
            FirebaseFirestore.instance.collection('goals');

        final DocumentReference goalDocRef = goalsCollection.doc(goalId);
        List<String> titleWords =
            removeStopWords(goalTitle).toLowerCase().split(' ');
// Save goal data
        await goalDocRef.set({
          "userId": userId,
          "title": goalTitle,
          "titleWords": titleWords,
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
          titleWords = titleWords + removeStopWords(task).split(" ");
          await goalDocRef.collection('tasks').doc(taskId).set({
            "taskTitle": task,
            "isCompleted": false,
            'createdAt': DateTime.now()
          });
        }

        goalDocRef.update({'titleWords': titleWords});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Goal added successfully")));
        final user = Provider.of<UserProvider>(context, listen: false);
        user.incrementGoalCount();
        Navigator.pop(context);
        List<MatchedGoal> matchedGoals =
            await compareAndGenerateList(titleWords, goalId);
        for (MatchedGoal goal in matchedGoals) {
          final suggestionId = const Uuid().v1();
          FirebaseFirestore.instance
              .collection("suggestions")
              .doc(userId)
              .collection('withUsers')
              .doc(suggestionId)
              .set({
            "goalId": goal.goalId,
            "userId": goal.userId,
            "matchedWords": goal.matchedWords
          });
          FirebaseFirestore.instance
              .collection("suggestions")
              .doc(goal.userId)
              .collection('withUsers')
              .doc(suggestionId)
              .set({
            "goalId": goal.goalId,
            "userId": userId,
            "matchedWords": goal.matchedWords
          });
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding goal. Please try again.")),
      );
    }
  }

  Future<List<MatchedGoal>> compareAndGenerateList(
      List<String> myTitleWords, String currentgoalId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<MatchedGoal> matchedGoals = [];

    try {
      QuerySnapshot goalsSnapshot = await firestore.collection('goals').get();

      goalsSnapshot.docs.forEach((DocumentSnapshot document) {
        String goalId = document.id;
        if (goalId == currentgoalId) {
          return;
        }
        String visibility =
            (document.data() as Map<String, dynamic>?)?['visibility'] as String;
        if (visibility == 'private') {
          return;
        }
        String userId = (document.data() as Map<String, dynamic>?)?['userId'];
        List<String> titleWords = List<String>.from((document.data()
                as Map<String, dynamic>?)?['titleWords'] as List<dynamic>? ??
            []);

        List<String> matchedWords = [];

        for (String word in titleWords) {
          if (myTitleWords.contains(word)) {
            matchedWords.add(word);
          }
        }

        if (matchedWords.isNotEmpty) {
          matchedGoals.add(MatchedGoal(
            goalId: goalId,
            userId: userId,
            matchedWords: matchedWords,
          ));
        }
      });
    } catch (e) {
      print('Error: $e');
    }

    return matchedGoals;
  }

  String removeStopWords(String text) {
    // Define a list of stop words
    List<String> stopWords = [
      '',
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
                      const SizedBox(
                        height: 5,
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
                          Text(
                            'To',
                            style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.w500),
                          ),
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
                      goalType == "Others"
                          ? buildOthersTextField()
                          : SizedBox.shrink(),
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
        ),
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

  Widget buildOthersTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter goal Type",
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
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Goal Type should not be empty";
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                goalType = value;
              });
            },
            autocorrect: true,
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: "Enter Goal Type"),
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
  const Task({Key? key, required this.taskTitles, required this.index})
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
              textCapitalization: TextCapitalization.sentences,
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

class DateInputField extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onDateSelected;

  const DateInputField({
    super.key,
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

class MatchedGoal {
  String goalId;
  String userId;
  List<String> matchedWords;

  MatchedGoal({
    required this.goalId,
    required this.userId,
    required this.matchedWords,
  });

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'userId': userId,
      'matchedWords': matchedWords,
    };
  }
}
