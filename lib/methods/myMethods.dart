import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:logger/logger.dart';

Future<int> updateGoalsCount(String uid) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int goalsCount = 0;

  CollectionReference goalsCollection = _firestore.collection('goals');

  QuerySnapshot querySnapshot = await goalsCollection.get();

  for (var doc in querySnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    if (doc.exists && data['userId'] == uid) {
      goalsCount++;
    }
  }
  // Logger().d(goalsCount);
  return goalsCount;
}
