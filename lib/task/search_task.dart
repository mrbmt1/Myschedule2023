import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myshedule/task/todotask.dart';
import 'edit_task.dart';
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
    DateTime today = DateTime.now();
    DateTime startDate = DateTime(today.year, today.month, today.day);
    DateTime endDate = startDate.add(Duration(days: 1));
    _searchStream = FirebaseFirestore.instance
        .collection('tasks')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('dueDate', isLessThan: Timestamp.fromDate(endDate))
        .snapshots();
    _getFilterDates();
  }

  void _getFilterDates() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('tasks').get();
    List<DateTime> allDates = snapshot.docs
        .map((doc) => (doc['dueDate'] as Timestamp).toDate())
        .toList();
    allDates.sort(); // Sort the list of dates in ascending order

    // Group dates with the same date into one date
    Map<String, DateTime> groupedDates = {};
    allDates.forEach((date) {
      String dateKey = DateFormat('dd/MM/yyyy').format(date);
      if (groupedDates.containsKey(dateKey)) {
        // If a date with this key already exists, update its time to the latest time
        DateTime existingDate = groupedDates[dateKey]!;
        if (date.isAfter(existingDate)) {
          groupedDates[dateKey] = date;
        }
      } else {
        // If a date with this key doesn't exist, add it to the map
        groupedDates[dateKey] = date;
      }
    });

    // Create a list of unique dates from the map
    _filterDateList = groupedDates.values.toList();

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
      } else if (date.year == DateTime.now().subtract(Duration(days: 1)).year &&
          date.month == DateTime.now().subtract(Duration(days: 1)).month &&
          date.day == DateTime.now().subtract(Duration(days: 1)).day) {
        dateText += ' (hôm qua)';
      } else {
        dateText = DateFormat('dd/MM/yyyy').format(date);
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
    DateTime startDate = DateTime(date.year, date.month, date.day);
    DateTime endDate = startDate.add(Duration(days: 1));
    setState(() {
      _searchStream = FirebaseFirestore.instance
          .collection('tasks')
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dueDate', isLessThan: Timestamp.fromDate(endDate))
          .snapshots();
    });
    Navigator.pop(context);

    _searchController.text = DateFormat('dd/MM/yyyy').format(date);
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
