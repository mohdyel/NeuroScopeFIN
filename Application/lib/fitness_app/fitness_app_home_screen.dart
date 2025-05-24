import 'package:NeuroScope/fitness_app/models/tabIcon_data.dart';
import 'package:NeuroScope/fitness_app/profile/profilescreen.dart';
import 'package:NeuroScope/fitness_app/faq/faq_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
import 'package:NeuroScope/fitness_app/history/history_screen.dart';
import 'package:NeuroScope/fitness_app/welcome/welcome_screen.dart';

class TabIconData {
  IconData imagePath;
  IconData selectedIcon;
  bool isSelected;

  TabIconData({
    this.imagePath = Icons.home,
    this.selectedIcon = Icons.home,
    this.isSelected = false,
  });

  static List<TabIconData> tabIconsList = [
    TabIconData(
      imagePath: Icons.home,
      selectedIcon: Icons.home_filled,
      isSelected: true,
    ),
    TabIconData(
      imagePath: Icons.history,
      selectedIcon: Icons.history_toggle_off,
      isSelected: false,
    ),
    TabIconData(
      imagePath: Icons.help_outline,
      selectedIcon: Icons.help,
      isSelected: false,
    ),
    TabIconData(
      imagePath: Icons.person_outline,
      selectedIcon: Icons.person,
      isSelected: false,
    ),
  ];
}

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  late TabController _tabController;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    super.initState();
    _checkFirstLogin();
    _initializeController();
    _tabController = TabController(length: tabIconsList.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  Future<void> _checkFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLoggedIn = prefs.getBool('has_logged_in') ?? false;

    if (!hasLoggedIn) {
      await prefs.setBool('has_logged_in', true);
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          Phoenix.rebirth(context);
        }
      });
    }
  }

  void _initializeController() {
    animationController =
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    tabBody = WelcomeScreen(animationController: animationController);
  }

  void _handleTabSelection() {
    if (!mounted || !_tabController.indexIsChanging) return;

    setState(() {
      tabIconsList.forEach((tab) => tab.isSelected = false);
      tabIconsList[_tabController.index].isSelected = true;

      switch (_tabController.index) {
        case 0:
          tabBody = WelcomeScreen(animationController: animationController);
          break;
        case 1:
          tabBody = HistoryPage();
          break;
        case 2:
          tabBody = FAQScreen(animationController: animationController);
          break;
        case 3:
          tabBody = ProfileScreen(animationController: animationController);
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    animationController?.dispose();
    super.dispose();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent layout shift from keyboard
      backgroundColor: FitnessAppTheme.background,
      body: SafeArea(
        bottom: false, // avoid padding duplication with bottomNavigationBar
        child: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return tabBody;
            }
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: FitnessAppTheme.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: FitnessAppTheme.grey.withOpacity(0.2),
                offset: const Offset(0, -2),
                blurRadius: 8.0,
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            tabs: tabIconsList.map((TabIconData tab) {
              return Tab(
                icon: AnimatedBuilder(
                  animation: animationController!,
                  builder: (context, child) => Icon(
                    tab.isSelected ? tab.selectedIcon : tab.imagePath,
                    color: tab.isSelected
                        ? FitnessAppTheme.nearlyDarkBlue
                        : FitnessAppTheme.grey.withOpacity(0.6),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
