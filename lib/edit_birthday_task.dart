import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myshedule/birthdaylist.dart';

class EditBirthDayTaskScreen extends StatefulWidget {
  final BirthDayItem birthdayTodo;

  EditBirthDayTaskScreen({required this.birthdayTodo});

  @override
  _EditBirthDayTaskScreenState createState() => _EditBirthDayTaskScreenState();
}

class _EditBirthDayTaskScreenState extends State<EditBirthDayTaskScreen> {
  late String _content;
  late DateTime _selectedDate;
  late TextEditingController _contentController;
  late TimeOfDay _selectedTimeNotification;
  late bool _isNotification = false;
  late int newNotificationID;

  @override
  void initState() {
    super.initState();
    newNotificationID = widget.birthdayTodo.notificationID;
    _content = widget.birthdayTodo.content;
    _selectedDate = widget.birthdayTodo.date!;
    _contentController = TextEditingController(text: _content);
    _selectedTimeNotification = widget.birthdayTodo.timeNotification!;
    _isNotification = widget.birthdayTodo.isNotification;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _selectTimeNotification() async {
    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: context,
      initialTime: _selectedTimeNotification,
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
        title: Text('Chỉnh sửa ngày sinh nhật'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                hintText: 'Nhập nội dung ngày sinh nhật',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.cake_rounded),
              ),
              controller: _contentController,
            ),
            SizedBox(height: 8),
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
          if (_content == null || _content!.isEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Chưa nhập nội dung"),
                  content: Text("Vui lòng nhập nội dung trước khi lưu"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Đóng"),
                    ),
                  ],
                );
              },
            );
          } else {
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await FirebaseFirestore.instance
                  .collection('birthdays')
                  .doc(widget.birthdayTodo.id)
                  .update({
                'description': _content,
                'updatedAt': DateTime.now(),
                'birthDay': _selectedDate,
                'description': _content,
                'isNotification': _isNotification,
                'timeNotification': _selectedTimeNotification.format(context),
              });
            }
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
