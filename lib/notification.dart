// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:myshedule/todolist.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:unorm_dart/unorm_dart.dart';

// class CreateTaskScreen extends StatefulWidget {
//   const CreateTaskScreen({Key? key}) : super(key: key);

//   @override
//   _CreateTaskScreenState createState() => _CreateTaskScreenState();
// }

// class _CreateTaskScreenState extends State<CreateTaskScreen> {
//   String? _content;
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   TimeOfDay _selectedTimeNotification = TimeOfDay(hour: 0, minute: 0);
//   bool _isNotification = false;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo cài đặt cho package flutter_local_notifications
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: AndroidInitializationSettings('ic_launcher'),
//     );
//     // Khởi tạo package flutter_local_notifications
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: onSelectNotification);
//   }

//   // Hàm lập lịch và hiển thị thông báo
//   Future<void> scheduleNotification(
//       String content, DateTime scheduledDate) async {
//     // Kiểm tra nếu không bật thông báo thì không làm gì cả
//     if (!_isNotification) return;

//     // Lấy thông tin người dùng hiện tại
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     final User? currentUser = auth.currentUser;
//     if (currentUser == null) return;
//     final String userId = currentUser.uid;

//     // Lấy dữ liệu của người dùng hiện tại từ Firebase
//     final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
//         await FirebaseFirestore.instance.collection('users').doc(userId).get();

//     // Lấy thời gian thông báo và ngày đến hạn từ dữ liệu của người dùng
//     final int timeNotification = userSnapshot.get('timeNotification');
//     final Timestamp dueDate = userSnapshot.get('dueDate');
//     // final DateTime dueDate = dueDateTimestamp.toDate();
//     // Tính toán thời gian hiển thị thông báo
//     final DateTime notificationTime = DateTime(
//       scheduledDate.year,
//       scheduledDate.month,
//       scheduledDate.day,
//       _selectedTimeNotification.hour,
//       _selectedTimeNotification.minute,
//     ).subtract(Duration(minutes: timeNotification));

//     // Tạo cài đặt cho thông báo
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//             'todo_app_channel', 'Todo App', 'Channel for Todo App tasks',
//             importance: Importance.max,
//             priority: Priority.high,
//             ticker: 'ticker');
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     // Lập lịch hiển thị thông báo
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         'Đến hạn task',
//         content,
//         tz.TZDateTime.from(notificationTime, tz.local),
//         platformChannelSpecifics,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime);
//   }

//   Future<void> onSelectNotification(String? payload) async {
//     // Handle the user tapping on the notification
//   }

//   Future<void> _selectDate() async {
//     final DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (selectedDate != null) {
//       setState(() {
//         _selectedDate = selectedDate;
//       });
//     }
//   }

//   Future<void> _selectTime() async {
//     final TimeOfDay? selectedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (selectedTime != null) {
//       setState(() {
//         _selectedTime = selectedTime;
//       });
//     }
//   }

//   Future<void> _selectTimeNotification() async {
//     final TimeOfDay? selectedTimeNotification = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay(hour: 0, minute: 0),
//     );
//     if (selectedTimeNotification != null) {
//       setState(() {
//         _selectedTimeNotification = selectedTimeNotification;
//         _isNotification = true;
//       });
//     }
//   }

//   Future<void> _onSaveButtonPressed() async {
//     // Lấy dữ liệu task từ textfield và thời gian người dùng đã chọn
//     final String content = _content ?? '';
//     final DateTime selectedDateTime = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _selectedTimeNotification.hour,
//       _selectedTimeNotification.minute,
//     );

//     // Lưu task vào Firebase
//     // await FirebaseFirestore.instance.collection('tasks').add({
//     //   'description': content,
//     //   'dueDate': selectedDateTime,
//     // });

//     // Lập lịch hiển thị thông báo
//     await scheduleNotification(content, selectedDateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tạo task mới'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _content = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Nhập nội dung task',
//               ),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: _selectDate,
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_today),
//                   SizedBox(width: 8),
//                   Text(
//                       'Ngày đến hạn: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
//                 ],
//               ),
//             ),
//             SizedBox(height: 0),
//             TextButton(
//               onPressed: _selectTime,
//               child: Row(
//                 children: [
//                   Icon(Icons.access_time),
//                   SizedBox(width: 8),
//                   Text('Giờ đến hạn: ${_selectedTime.format(context)}'),
//                 ],
//               ),
//             ),
//             SizedBox(height: 0),
//             TextButton(
//               onPressed: _selectTimeNotification,
//               child: Row(
//                 children: [
//                   Icon(Icons.notifications_active_outlined),
//                   SizedBox(width: 8),
//                   Text(_isNotification
//                       ? 'Bật thông báo: ${_selectedTimeNotification.format(context)}'
//                       : 'Bật thông báo: Không'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.save),
//         onPressed: () async {
//           if (_content != null) {
//             TodoItem newTodo = TodoItem(
//               id: '1',
//               content: _content!,
//             );
//             newTodo.date = _selectedDate;
//             newTodo.time = _selectedTime;
//             newTodo.timeNotification = _selectedTimeNotification;
//             newTodo.isNotification = _isNotification;
//             User? currentUser = FirebaseAuth.instance.currentUser;
//             if (currentUser != null) {
//               await FirebaseFirestore.instance.collection('tasks').add({
//                 'userID': currentUser.uid,
//                 'completed': false,
//                 'createdAt': DateTime.now(),
//                 'dueDate': newTodo.date,
//                 'description': newTodo.content,
//                 'timeOfDueDay': "${newTodo.time!.hour}:${newTodo.time!.minute}",
//                 'isNotification': newTodo.isNotification,
//                 'timeNotification':
//                     "${newTodo.timeNotification!.hour}:${newTodo.timeNotification!.minute}",
//               });
//               _onSaveButtonPressed();
//             }
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => TodoListScreen()),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
