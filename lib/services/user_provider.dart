import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goal_quester/methods/myMethods.dart';
import 'package:logger/logger.dart';

class UserProvider with ChangeNotifier {
  late String _userId;
  late String _userName;
  late String _rollNo;
  late String _lastName;
  late String _firstName;
  late String _gender;
  late String _profileUrl;
  late List<String> _followers;
  late List<String> _following;
  bool _isLoading = false;
  int _goalsCount = 0;
  int get goalsCount => _goalsCount;

  UserProvider() {
    // Call _loadUserData() method when an instance of UserProvider is created.
    _userId = FirebaseAuth.instance.currentUser!.uid.toString();
    Logger().d(_userId);
    _loadUserData();
  }
  incrementGoalCount() {
    _goalsCount++;
    notifyListeners();
  }

  decrementGoalCOunt() {
    _goalsCount--;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    try {
      // Set isLoading to true when starting to load data
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      Logger().d(data);

      // Update private variables with the loaded data
      _userName = data['name'] ?? '';
      _rollNo = data['rollno'] ?? '';
      _lastName = data['lname'] ?? '';
      _firstName = data['fname'] ?? '';
      _gender = data['gender'] ?? '';
      _profileUrl = data['purl'] ?? '';

      // Load followers and following lists
      _followers = List<String>.from(data['followers'] ?? []);
      _following = List<String>.from(data['following'] ?? []);

      // Update goals count
      _goalsCount = await updateGoalsCount(_userId);

      // Set isLoading to false after loading data
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      // Handle errors appropriately
      print("Error loading user data: $error");
      // Set isLoading to false in case of error
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile(
      String firstName, String lastName, String gender, String profileUrl) {
    _firstName = firstName;
    _lastName = lastName;
    _gender = gender;
    _profileUrl = profileUrl;
    notifyListeners();
  }

  void addFollower(String followerId) {
    if (!_followers.contains(followerId)) {
      _followers.add(followerId);
      // Update followers list in Firestore
      FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'followers': _followers,
      });
      notifyListeners();
    }
  }

  void removeFollower(String followerId) {
    if (_followers.contains(followerId)) {
      _followers.remove(followerId);
      // Update followers list in Firestore
      FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'followers': _followers,
      });
      notifyListeners();
    }
  }

  void addFollowing(String followingId) async {
    if (!_following.contains(followingId)) {
      _following.add(followingId);

      // Update following list in Firestore
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'following': _following,
      });

      // Update follower list of followed user in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followingId)
          .update({
        'followers': FieldValue.arrayUnion([_userId]),
      });

      notifyListeners();
    }
  }

  void removeFollowing(String followingId) async {
    if (_following.contains(followingId)) {
      _following.remove(followingId);

      // Update following list in Firestore
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'following': _following,
      });

      // Update follower list of the unfollowed user in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followingId)
          .update({
        'followers': FieldValue.arrayRemove([_userId]),
      });

      notifyListeners();
    }
  }

  String get userId => _userId;
  String get userName => _userName;
  String get rollNo => _rollNo;
  String get lastName => _lastName;
  String get firstName => _firstName;
  String get gender => _gender;
  String get profileUrl => _profileUrl;
  List<String> get followers => _followers;
  List<String> get following => _following;

  bool get isLoading => _isLoading;
}
