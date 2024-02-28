import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Profile_Screen/goal_container.dart';

class GoalSearch extends StatefulWidget {
  const GoalSearch({super.key});

  @override
  State<GoalSearch> createState() => _GoalSearchState();
}

class _GoalSearchState extends State<GoalSearch> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 10),
        _buildGoalList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Colors.grey,
            size: 25,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                hintText: 'Search Goal',
                border: InputBorder.none, // Remove default border
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear(); // Clear the text
                });
              },
              child: const Icon(
                Icons.clear,
                color: Colors.grey,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalList() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('goals')
            .where('titleWords',
                arrayContainsAny:
                    _searchController.text.toLowerCase().split(' '))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildErrorWidget('No Goals found, \n Enter any keyword');
          }

          var data = snapshot.data!.docs;
          List<GoalContainer> goalWidgets = [];
          for (var goal in data) {
            Map<String, dynamic> goalData = goal.data();
            if (goalData['visibility'] == 'Public') {
              goalWidgets.add(GoalContainer(
                  userId: goal['userId'], goalId: goal.id, goalData: goalData));
            }
          }

          return Column(
            children: [
              _searchController.text.isNotEmpty
                  ? Text(
                      '${goalWidgets.length} goals${goalWidgets.length == 1 ? '' : 's'} found',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : const SizedBox.shrink(),
              Expanded(
                child: ListView(
                  children: goalWidgets,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the TextEditingController
    super.dispose();
  }
}
