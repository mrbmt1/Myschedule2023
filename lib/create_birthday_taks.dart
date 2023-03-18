import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myshedule/birthdaylist.dart';
import 'package:myshedule/todolist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:unorm_dart/unorm_dart.dart';

class CreateBirthDayTaskScreen extends StatefulWidget {
  const CreateBirthDayTaskScreen({Key? key}) : super(key: key);

  @override
  _CreateBirthDayTaskScreenState createState() =>
      _CreateBirthDayTaskScreenState();
}

class _CreateBirthDayTaskScreenState extends State<CreateBirthDayTaskScreen> {
  static int _lastNotificationID = 0;
  int newNotificationID = ++_lastNotificationID;
  String? _content;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _selectedTimeNotification = TimeOfDay(hour: 0, minute: 0);
  bool _isNotification = false;

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

  Future<void> _selectTimeNotification() async {
    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );
    if (selectedTimeNotification != null) {
      setState(() {
        _selectedTimeNotification = selectedTimeNotification;
        _isNotification = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sinh nhật'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _content = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Sinh nhật của ai nhỉ?',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.cake),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _selectDate,
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text(
                      'Sinh nhật: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                ],
              ),
            ),
            SizedBox(height: 0),
            TextButton(
              onPressed: _selectTimeNotification,
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined),
                  SizedBox(width: 8),
                  Text(_isNotification
                      ? 'Bật thông báo: ${_selectedTimeNotification.format(context)}'
                      : 'Bật thông báo: Không'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          if (_content == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vui lòng cho biết sinh nhật của ai'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            _lastNotificationID++;
            TodoItem newTodo = TodoItem(
              id: '1',
              notificationID: newNotificationID,
              content: _content!,
            );
            newTodo.date = _selectedDate;
            newTodo.timeNotification = _selectedTimeNotification;
            newTodo.isNotification = _isNotification;
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await FirebaseFirestore.instance.collection('birthdays').add({
                'userID': currentUser.uid,
                'createdAt': DateTime.now(),
                'birthDay': newTodo.date,
                'description': newTodo.content,
                'isNotification': newTodo.isNotification,
                'timeNotification':
                    "${newTodo.timeNotification!.hour}:${newTodo.timeNotification!.minute}",
                'notificationID': _lastNotificationID,
              });
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BirthdayScreen()),
            );
          }
        },
      ),
    );
  }
}
