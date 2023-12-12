import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goal_quester/screens/nav_drawer.dart';
import 'package:goal_quester/screens/starting_screen.dart';
import 'firebase_options.dart';
import 'package:goal_quester/screens/chats_page.dart';
import 'package:goal_quester/screens/home_page.dart';
import 'package:goal_quester/screens/profile_page.dart';
import 'package:goal_quester/screens/search_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return const MyHomePage();
          } else {
            return const StartingScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static Map<String, dynamic> userInfo = {};
  String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      userInfo['name'] = data['name'];
      userInfo['rollno'] = data['rollno'];
      userInfo['lname'] = data['lname'];
      userInfo['fname'] = data['fname'];
      userInfo['gender'] = data['gender'];
      userInfo['purl'] = data['purl'];
    });
  }

  var _selectedIndex = 0;
  final List<Widget> _contentShown = [
    const HomePage(),
    ChatsPage(),
    SearchPage(),
    const ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        drawer: NavDrawer(userData: userInfo),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor:
              Colors.deepPurple, //Theme.of(context).colorScheme.inversePrimary
          title: const Text(
            'Goal Quester',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _contentShown.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
                backgroundColor: Colors.deepPurple),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
