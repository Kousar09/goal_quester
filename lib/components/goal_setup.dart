import 'package:flutter/material.dart';

class GoalSetUp extends StatefulWidget {
  const GoalSetUp({super.key});

  @override
  State<GoalSetUp> createState() => _GoalSetUpState();
}

class _GoalSetUpState extends State<GoalSetUp> {
  List<Task> tasks = [const Task()];
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(title: const Text('Set up a goal')),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              autocorrect: true,
              decoration: InputDecoration(
                  hintText: 'Enter the title of the goal',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Add the corresponding tasks:"),
            const SizedBox(
              height: 10,
            ),
            Column(children: tasks),
            TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return Colors.transparent;
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.transparent;
                    }
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.transparent;
                    }
                    return null; // Defer to the widget's default.
                  }),
                ),
                onPressed: () {
                  setState(() {
                    tasks.add(const Task());
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(
                      width: 5,
                    ),
                    Text('add a new task'),
                  ],
                )),
            const Spacer(),
            Center(
                child: ElevatedButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size(width, 40),
                backgroundColor: Colors.purple,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ))
          ],
        ),
      ),
    );
  }
}

class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(value: false, onChanged: (val) => {}),
            const Expanded(
              child: TextField(
                decoration:
                    InputDecoration.collapsed(hintText: 'Enter the task'),
              ),
            )
          ]),
    );
  }
}
