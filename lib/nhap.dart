// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:myshedule/search.dart';
// import 'edit_task.dart';
// import 'main.dart';
// import 'profile.dart';
// import 'create_task.dart';
// import 'edit_task.dart';
// import 'package:myshedule/todolist.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:ui' as ui;
// import 'package:unorm_dart/unorm_dart.dart';
// import 'setting.dart';
// import 'task_widget.dart';

// //log out function
// void logout(BuildContext context) async {
//   bool confirm = await showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text("Đăng xuất"),
//       content: Text("Bạn muốn đăng xuất khỏi tài khoản?"),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(false),
//           child: Text("Không"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(true),
//           child: Text("Có"),
//         ),
//       ],
//     ),
//   );
//   if (confirm == true) {
//     // Đăng xuất khỏi Firebase Authentication
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => MainApp()),
//     );
//   }
// }

// //Hàm hiển thị thông báo khi bấm vào icon chuông thông báo
// showNotificationDialog(BuildContext context, TodoItem todo) async {
//   var result = await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Thông báo'),
//         content: Text('Bạn muốn tắt thông báo hay đặt lại giờ thông báo?'),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Tắt thông báo'),
//             onPressed: () {
//               Navigator.of(context).pop('Tắt thông báo');
//             },
//           ),
//           TextButton(
//             child: Text('Đặt lại giờ thông báo'),
//             onPressed: () {
//               Navigator.of(context).pop('Đặt lại giờ thông báo');
//             },
//           ),
//         ],
//       );
//     },
//   );

//   if (result == 'Tắt thông báo') {
//     FirebaseFirestore.instance
//         .collection('tasks')
//         .doc(todo.id)
//         .update({'isNotification': false});
//   } else if (result == 'Đặt lại giờ thông báo') {
//     var newTime = await showTimePicker(
//       context: context,
//       initialTime: todo.timeNotification ?? TimeOfDay.now(),
//     );
//     if (newTime != null) {
//       FirebaseFirestore.instance.collection('tasks').doc(todo.id).update({
//         'timeNotification': newTime.format(context),
//         'isNotification': true,
//       });
//     }
//   }
// }

// class TodoItem {
//   final String id;
//   final String content;
//   bool completed;
//   DateTime? date;
//   String? title;
//   String? description;
//   TimeOfDay? time;
//   TimeOfDay? timeNotification;
//   bool isNotification;

//   TodoItem({
//     required this.id,
//     required this.content,
//     this.completed = false,
//     this.title,
//     this.description,
//     this.date,
//     this.time,
//     this.timeNotification,
//     this.isNotification = false,
//   }) : assert(id != null);

//   factory TodoItem.fromSnapshot(DocumentSnapshot snapshot) {
//     var timeFromSnapshot = snapshot['timeOfDueDay'];
//     TimeOfDay? time;
//     if (timeFromSnapshot is String) {
//       time = TimeOfDay(
//         hour: DateFormat('HH:mm').parse(timeFromSnapshot).hour,
//         minute: DateFormat('HH:mm').parse(timeFromSnapshot).minute,
//       );
//     } else if (timeFromSnapshot != null) {
//       time = TimeOfDay(
//         hour: timeFromSnapshot.hour,
//         minute: timeFromSnapshot.minute,
//       );
//     }

//     var timeNotificationFromSnapshot = snapshot['timeNotification'];
//     TimeOfDay? timeNotification;
//     if (timeNotificationFromSnapshot is String) {
//       timeNotification = TimeOfDay(
//         hour: DateFormat('HH:mm').parse(timeNotificationFromSnapshot).hour,
//         minute: DateFormat('HH:mm').parse(timeNotificationFromSnapshot).minute,
//       );
//     } else if (timeNotificationFromSnapshot != null) {
//       timeNotification = TimeOfDay(
//         hour: timeNotificationFromSnapshot.hour,
//         minute: timeNotificationFromSnapshot.minute,
//       );
//     }

//     return TodoItem(
//       id: snapshot.id,
//       content: snapshot['description'] ?? '',
//       completed: snapshot['completed'] ?? false,
//       date: snapshot['dueDate']?.toDate(),
//       time: time, // assign parsed time directly to the time field
//       timeNotification: timeNotification,
//       isNotification: snapshot['isNotification'],
//     );
//   }
// }

// class TodoListScreen extends StatelessWidget {
//   const TodoListScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return Center(
//         child: Text('Vui lòng đăng nhập để xem danh sách task'),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Danh sách lịch của tôi'),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SearchScreen()),
//                 );
//               },
//               icon: Icon(Icons.search))
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               child: Text('Menu'),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.person),
//               title: Text('Thông tin người dùng'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => UserProfileScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.settings),
//               title: Text('Cài đặt'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => SettingsScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Đăng xuất'),
//               onTap: () {
//                 logout(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('tasks')
//             .where('userID', isEqualTo: currentUser.uid)
//             .orderBy('dueDate')
//             .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
//             );
//           }

//           if (!snapshot.hasData) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           List<TodoItem> todoList = snapshot.data!.docs
//               .map((doc) => TodoItem.fromSnapshot(doc))
//               .toList();
// // Giao diện single task
//           return ListView.builder(
//             itemCount: todoList.length,
//             itemBuilder: (BuildContext context, int index) {
//               TodoItem todo = todoList[index];
//               return TaskWidget(todo: todo);
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () async {
//           TodoItem? newTodo = await Navigator.push<TodoItem?>(
//             context,
//             MaterialPageRoute(builder: (context) => CreateTaskScreen()),
//           );
//           if (newTodo != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Đã thêm task mới')),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
