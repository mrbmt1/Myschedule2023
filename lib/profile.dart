import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:myshedule/edit_profile.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _userData = userSnapshot.data()!;
      });
    }
  }

  Future<void> _refreshUserData() async {
    await _getUserData();
  }

  void _verifyPassword(BuildContext context) async {
    String password = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận mật khẩu hiện tại'),
          content: TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Mật khẩu',
            ),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xác nhận'),
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  final uid = currentUser.uid;
                  final userSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
                  final storedPassword = userSnapshot.get('password');
                  final passwordHash =
                      sha256.convert(password.codeUnits).toString();
                  if (storedPassword == passwordHash) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => EditProfileScreen()),
                    ).then((_) {
                      setState(() {
                        password = '';
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sai mật khẩu!'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin người dùng'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.0),
        child: _userData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['username'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Tên tài khoản',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['fullName'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['gender'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Giới tính',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['dob'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Ngày sinh',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['email'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['phone'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _verifyPassword(context);
        },
        label: Text('Chỉnh sửa thông tin'),
        icon: Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
