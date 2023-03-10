import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_task.dart';
import 'package:myshedule/todolist.dart';
import 'task_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _searchStream;
  List<DateTime> _filterDateList = [];
  List<Widget> _filterButtonList = [];

  @override
  void initState() {
    super.initState();
    _searchStream = FirebaseFirestore.instance.collection('tasks').snapshots();
    _getFilterDates();
  }

  void _getFilterDates() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('tasks').get();
    List<DateTime> allDates = snapshot.docs
        .map((doc) => (doc['dueDate'] as Timestamp).toDate())
        .toList();
    allDates.sort(); // Sắp xếp danh sách thời gian tăng dần
    _filterDateList = allDates.toSet().toList();
    _filterButtonList = _filterDateList.map<Widget>((date) {
      String dateText = DateFormat('dd/MM/yyyy').format(date);
      if (date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day) {
        dateText += ' (hôm nay)';
      } else if (date.year == DateTime.now().add(Duration(days: 1)).year &&
          date.month == DateTime.now().add(Duration(days: 1)).month &&
          date.day == DateTime.now().add(Duration(days: 1)).day) {
        dateText += ' (ngày mai)';
      }

      return TextButton(
        onPressed: () {
          _filterTasks(date);
        },
        child: Text(dateText),
      );
    }).toList();

    setState(() {});
  }

  void _filterTasks(DateTime date) {
    setState(() {
      _searchStream = FirebaseFirestore.instance
          .collection('tasks')
          .where('dueDate', isEqualTo: Timestamp.fromDate(date))
          .snapshots();
    });
    Navigator.pop(context); // Ẩn cửa sổ chọn ngày

    _searchController.text = DateFormat('dd/MM/yyyy')
        .format(date); // Đặt giá trị cho trường tìm kiếm là ngày đã chọn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Lọc theo ngày'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _filterButtonList,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
        title: TextField(
          controller: _searchController,
          autofocus: true, // Tự động focus vào trường tìm kiếm
          cursorColor: Colors.white, // Màu con trỏ màu trắng
          keyboardAppearance:
              Brightness.dark, // Bàn phím hiện lên với giao diện tối
          decoration: InputDecoration(
            hintText: 'Tìm kiếm',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchStream = FirebaseFirestore.instance
                  .collection('tasks')
                  .where('description',
                      isGreaterThanOrEqualTo: value.toLowerCase())
                  .where('description',
                      isLessThanOrEqualTo: value.toLowerCase() + '\uf8ff')
                  .snapshots();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _searchStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<TodoItem> todoList = snapshot.data!.docs
              .map((document) => TodoItem.fromSnapshot(document))
              .toList();
          if (todoList.isEmpty) {
            return Center(
              child: Text('Không tìm thấy kết quả'),
            );
          }
          return ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (context, index) {
              TodoItem todo = todoList[index];
              return TaskWidget(todo: todo);
            },
          );
        },
      ),
    );
  }
}
