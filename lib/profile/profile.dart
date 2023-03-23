import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:myshedule/profile/edit_profile.dart';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
              border: OutlineInputBorder(),
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
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EditProfileScreen()),
                    ).then((result) {
                      if (result != null && result) {}
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

  Future<Widget> _getImage() async {
    if (_userData.containsKey('avatarURL')) {
      try {
        final ref = firebase_storage.FirebaseStorage.instance
            .refFromURL(_userData['avatarURL']);
        final url = await ref.getDownloadURL();
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.person),
          ),
        );
      } catch (e) {
        print('Error loading image: $e');
        return Text('Chưa có avatar');
      }
    } else {
      return ClipOval(
        child: Icon(Icons.person, size: 120),
      );
    }
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
                  GestureDetector(
                    onTap: () async {
                      if (_userData.containsKey('avatarURL')) {
                        try {
                          final ref = firebase_storage.FirebaseStorage.instance
                              .refFromURL(_userData['avatarURL']);
                          final url = await ref.getDownloadURL();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return Scaffold(
                                backgroundColor: Colors.black,
                                body: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Hero(
                                        tag: 'imageHero',
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 30,
                                      right: 10,
                                      child: IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        } catch (e) {
                          print('Error loading image: $e');
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 60,
                      child: Hero(
                        tag: 'imageHero',
                        child: FutureBuilder<Widget>(
                          future: _getImage(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return FittedBox(
                                fit: BoxFit.cover,
                                child: snapshot.data!,
                              );
                            } else {
                              return Icon(Icons.person);
                            }
                          },
                        ),
                      ),
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
                      suffixIcon: Icon(Icons.person),
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
                      suffixIcon: Icon(Icons.calendar_today),
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
                      suffixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: false,
                    initialValue: _userData['username'] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Tên tài khoản',
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person_pin),
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
                      suffixIcon: Icon(Icons.phone),
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
                      suffixIcon: Icon(Icons.mail),
                    ),
                  ),
                  SizedBox(height: 50.0),
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
