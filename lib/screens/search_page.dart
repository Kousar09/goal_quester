import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goal_quester/screens/image_widget.dart';
import 'package:goal_quester/screens/user_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 10),
        _buildUserList(),
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
                hintText: 'Search users',
                border: InputBorder.none, // Remove default border
              ),
              onChanged: (val) {
                setState(() {
                  // Your search logic here
                });
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

  Widget _buildUserList() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('fname', isGreaterThanOrEqualTo: _searchController.text)
            .where('fname', isLessThan: _searchController.text + 'z')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildErrorWidget('No users found');
          }

          var data = snapshot.data!.docs;
          List<UserContainer> userWidgets = [];
          for (var user in data) {
            userWidgets.add(UserContainer(
              id: user.id,
              name: user['fname'] + user['lname'],
              purl: user['purl'],
              gender: user['gender'],
            ));
          }

          return Column(
            children: [
              Text(
                '${userWidgets.length} user${userWidgets.length == 1 ? '' : 's'} found',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: userWidgets,
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

class UserContainer extends StatelessWidget {
  const UserContainer({
    Key? key,
    required this.id,
    required this.name,
    required this.purl,
    required this.gender,
  }) : super(key: key);

  final String name;
  final String purl;
  final String id;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserProfile(userId: id)))
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            ProfileImage(
              purl: purl,
              gender: gender,
              height: 60,
              width: 60,
              borderRadius: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}
