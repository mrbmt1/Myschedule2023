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
                  Text('Tên tài khoản:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Text('${_userData['username'] ?? ''}',
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 16.0),
                  Text('Họ và tên:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Text('${_userData['fullName'] ?? ''}',
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 16.0),
                  Text('Giới tính:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Text('${_userData['gender'] ?? ''}',
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 16.0),
                  Text('Ngày sinh:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Text('${_userData['dob'] ?? ''}',
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 16.0),
                  Text('Email:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Text('${_userData['email'] ?? ''}',
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 16.0),
                  Text('Số điện thoại:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  Text('${_userData['phone'] ?? ''}',
                      style: TextStyle(fontSize: 16.0)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _verifyPassword(context);
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (_) => EditProfileScreen()));
        },
        label: Text('Chỉnh sửa thông tin'),
        icon: Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
