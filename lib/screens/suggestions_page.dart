import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goal_quester/screens/Profile_Screen/user_profile.dart';
import 'package:goal_quester/screens/image_widget.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      future: fetchSuggestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching suggestions'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No suggestions available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final suggestion = snapshot.data![index];
              return SuggestionCard(
                title: 'You and ${suggestion.name} have similar goals',
                body: 'Matched words: ${suggestion.matchedWords}',
                purl: suggestion.purl,
                userId: suggestion.userId,
                goalId: suggestion.goalId,
              );
            },
          );
        }
      },
    );
  }

  Future<List<Suggestion>> fetchSuggestions() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    List<Suggestion> suggestions = [];

    try {
      QuerySnapshot suggestionsSnapshot = await firestore
          .collection('suggestions')
          .doc(myUid)
          .collection("withUsers")
          .get();

      for (var doc in suggestionsSnapshot.docs) {
        String userId = doc['userId'];
        String goalId = doc['goalId'];
        List<dynamic> matchedWords = doc['matchedWords'];

        // Fetch user details from users collection
        DocumentSnapshot userDoc =
            await firestore.collection('users').doc(userId).get();
        String name = userDoc['fname'] + ' ' + userDoc['lname'];
        String purl = userDoc['purl'];

        suggestions.add(Suggestion(
          userId: userId,
          goalId: goalId,
          name: name,
          purl: purl,
          matchedWords: matchedWords.join(', '),
        ));
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }

    return suggestions;
  }
}

class SuggestionCard extends StatelessWidget {
  final String title;
  final String body;
  final String purl;
  final String goalId;
  final String userId;

  const SuggestionCard({
    Key? key,
    required this.title,
    required this.body,
    required this.purl,
    required this.goalId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => UserProfile(
                    userId: userId,
                  )),
            ),
          );
        },
        child: Container(
          child: Row(
            children: [
              ProfileImage(
                  purl: purl,
                  gender: "male",
                  height: 60,
                  width: 60,
                  borderRadius: 30),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Suggestion {
  final String userId;
  final String goalId;
  final String name;
  final String purl;
  final String matchedWords;

  Suggestion({
    required this.userId,
    required this.goalId,
    required this.name,
    required this.purl,
    required this.matchedWords,
  });
}
