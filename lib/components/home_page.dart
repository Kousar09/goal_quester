import 'package:flutter/material.dart';
import 'package:goal_quester/components/goal_setup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Have a goal, set up and start working for it..",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Center(
            child: ElevatedButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GoalSetUp()))
                    },
                child: const Text("set up a goal"))),
        const SizedBox(
          height: 20,
        ),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            child: const Text(
              "Current Goals :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )),
        const GoalContainer()
      ],
    );
  }
}

class GoalContainer extends StatefulWidget {
  const GoalContainer({super.key});

  @override
  State<GoalContainer> createState() => _GoalContainerState();
}

class _GoalContainerState extends State<GoalContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: const BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5))),
        padding: const EdgeInsets.all(15),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title of the goal",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text("6 Tasks : 5 Pending, 1 Completed"),
                  ],
                ),
              ],
            ),
            Spacer(),
            Text("0%")
          ],
        ),
      ),
    );
  }
}
