import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myshedule/create_task.dart';
import 'package:myshedule/todolist.dart';
import 'edit_task.dart';

class TaskWidget extends StatelessWidget {
  final TodoItem todo;

  TaskWidget({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10, // Độ nâng của Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bo tròn cạnh của Card
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: EdgeInsets.only(
            top: 15,
            bottom: 20,
            right: 20,
            left: 20), //4 phía của card với content
        child: Row(
          children: [
            Checkbox(
              value: todo.completed,
              shape: CircleBorder(),
              checkColor: Colors.white,
              activeColor: Colors.green,
              onChanged: (bool? value) async {
                if (value != null) {
                  bool isCompleted = value;
                  bool isNotification = !isCompleted;
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(todo.id)
                      .update({
                    'completed': isCompleted,
                    'isNotification': isNotification,
                  });
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => showNotificationDialog(context, todo),
                    child: Row(
                      children: [
                        if (todo.isNotification)
                          Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.notifications_active,
                                    color: Colors.orange,
                                    size: 20), // Kích thước icon là 20
                                SizedBox(
                                  width:
                                      7, // Khoảng cách giữa icon và text thời gian thông báo
                                ),
                                Text(
                                  '${todo.timeNotification != null ? DateFormat('HH:mm').format(DateTime(2000, 1, 1, todo.timeNotification!.hour, todo.timeNotification!.minute)) : ""}',
                                ), // Hiển thị giá trị của timeNotification
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                  Text(
                    todo.content,
                    style: TextStyle(
                        decoration:
                            todo.completed ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  if (todo.date != null)
                    Text(
                      'Hạn chót: ${todo.time != null ? DateFormat('HH:mm - ').format(DateTime(2000, 1, 1, todo.time!.hour, todo.time!.minute)) : ""}${DateFormat('dd/MM/yyyy').format(todo.date!)}',
                      style: TextStyle(
                        decoration:
                            todo.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTaskScreen(todo: todo),
                  ),
                );
              },
              icon: Icon(
                Icons.edit,
                color: Color.fromARGB(255, 16, 44, 206),
              ),
            ),
            IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Xác nhận xóa'),
                      content: Text('Bạn có chắc muốn xóa task này không?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(todo.id)
                                .delete();
                            Navigator.pop(context);
                          },
                          child: Text('Xác nhận'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Hủy bỏ'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 27, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
