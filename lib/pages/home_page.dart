import 'package:carpool_training/pages/home_pages/all_rides_page.dart';
import 'package:carpool_training/pages/home_pages/create_ride_page.dart';
import 'package:carpool_training/pages/home_pages/my_profile_page.dart';
import 'package:carpool_training/style.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final List<Widget> homePages = [
    AllRidesPage(),
    CreateRidePage(),
    MyProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: uniPoolAppBar(appBarTitle: "UniPool"),
      body: IndexedStack(index: currentIndex, children: homePages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'All Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Create a Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}
