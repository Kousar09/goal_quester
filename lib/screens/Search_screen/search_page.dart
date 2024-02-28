import 'package:flutter/material.dart';
import 'package:goal_quester/screens/Search_screen/goal_search.dart';
import 'package:goal_quester/screens/Search_screen/user_search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search Users'),
            Tab(text: 'Search Goals'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [UserSearch(), GoalSearch()],
          ),
        ),
      ],
    );
  }
}
