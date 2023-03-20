import 'package:flutter/material.dart';
import 'package:myshedule/school_schedule/fri_school_schedule.dart';
import 'package:myshedule/school_schedule/mon_school_schedule.dart';
import 'package:myshedule/school_schedule/sat_school_schedule.dart';
import 'package:myshedule/school_schedule/sun_school_schedule.dart';
import 'package:myshedule/school_schedule/thu_school_schedule.dart';
import 'package:myshedule/school_schedule/tue_school_schedule.dart';
import 'package:myshedule/school_schedule/wed_school_schedule.dart';

class SchoolScheduleNavigator extends StatefulWidget {
  @override
  _SchoolScheduleNavigatorState createState() =>
      _SchoolScheduleNavigatorState();
}

class _SchoolScheduleNavigatorState extends State<SchoolScheduleNavigator> {
  int _currentIndex = DateTime.now().weekday - 1;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _children = [
    MonDayScheduleScreen(),
    TuesDayScheduleScreen(),
    WednesDayScheduleScreen(),
    ThursDayScheduleScreen(),
    FriDayScheduleScreen(),
    SaturDayScheduleScreen(),
    SunDayScheduleScreen(),
  ];

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Quẹt sang phải
      setState(() {
        _currentIndex = (_currentIndex - 1) % 7;
      });
    } else if (details.primaryVelocity! < 0) {
      // Quẹt sang trái
      setState(() {
        _currentIndex = (_currentIndex + 1) % 7;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Colors.grey),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.looks_two_rounded,
              color: Colors.grey,
            ),
            label: 'Thứ 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_3_rounded, color: Colors.grey),
            label: 'Thứ 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_4_rounded, color: Colors.grey),
            label: 'Thứ 4',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_5_rounded, color: Colors.grey),
            label: 'Thứ 5',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_6_rounded, color: Colors.grey),
            label: 'Thứ 6',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.weekend, color: Colors.grey),
            label: 'Thứ 7',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.weekend, color: Colors.grey),
            label: 'Chủ nhật',
          ),
        ],
      ),
    );
  }
}
