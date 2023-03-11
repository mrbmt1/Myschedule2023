import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String _gender = 'Khác';
  final List<String> _genderList = ['Nam', 'Nữ', 'Khác'];

  bool _validatePhone(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^\d{10}$').hasMatch(value)) {
      return false;
    }
    return true;
  }

  bool _validateEmail(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return false;
    }
    return true;
  }

  void _updateProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    final data = snapshot.data();
    final fullname = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final dob = _dobController.text.trim();
    final gender = _gender;

    if (fullname.isEmpty || phone.isEmpty || email.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
    } else if (fullname == data!['fullName'] &&
        phone == data['phone'] &&
        email == data['email'] &&
        dob == data['dob'] &&
        gender == data['gender']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có thông tin nào được thay đổi')),
      );
    } else if (_formKey.currentState!.validate()) {
      final existingUserByEmail = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('uid', isNotEqualTo: currentUser?.uid)
          .get();
      final existingUserByPhone = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('uid', isNotEqualTo: currentUser?.uid)
          .get();
      if (existingUserByEmail.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email đã được sử dụng bởi người khác')),
        );
      } else if (existingUserByPhone.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Số điện thoại đã được sử dụng bởi người khác')),
        );
      } else {
        Map<String, dynamic> updatedFields = {};
        if (fullname != data['fullName']) {
          updatedFields['fullName'] = fullname;
        }
        if (phone != data['phone'] && _validatePhone(phone) == true) {
          updatedFields['phone'] = phone;
        }
        if (email != data['email'] && _validateEmail(email) == true) {
          updatedFields['email'] = email;
        }
        if (dob != data['dob']) {
          updatedFields['dob'] = dob;
        }
        if (gender != data['gender']) {
          updatedFields['gender'] = gender;
        }

        if (updatedFields.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .update(updatedFields)
              .then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật thông tin thành công')),
            );
            Navigator.pop(context, updatedFields);
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Có lỗi xảy ra khi cập nhật thông tin')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không có thông tin nào được thay đổi')),
          );
        }
      }
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        _usernameController.text = data['username'];
        _fullNameController.text = data['fullName'];
        _phoneController.text = data['phone'];
        _emailController.text = data['email'];
        final dob = data['dob'];
        DateTime? dobDateTime;
        if (dob is String) {
          try {
            dobDateTime = DateFormat('dd/MM/yyyy').parse(dob);
            _dobController.text = DateFormat('dd/MM/yyyy').format(dobDateTime);
          } catch (e) {
            debugPrint('Error parsing date: $e');
            _dobController.text = '';
          }
        } else if (dob is Timestamp) {
          dobDateTime = dob.toDate();
          _dobController.text = DateFormat('dd/MM/yyyy').format(dobDateTime);
        }
        final gender = data['gender'] as String?;
        if (gender != null) {
          _gender = gender;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cập nhật thông tin'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Tên đăng nhập',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                      enabled: false,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Không được để trống';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Ngày sinh',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime? dob = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (dob == null) return;
                          _dobController.text =
                              DateFormat('dd/MM/yyyy').format(dob);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Không được để trống';
                          }
                          return null;
                        }),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: _genderList
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Giới tính',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                    ),
                  ])))),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateProfile,
        child: Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
