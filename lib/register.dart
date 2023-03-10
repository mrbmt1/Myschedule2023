import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _passwordController = TextEditingController();
  String get _password => _passwordController.text;
  set _password(String value) => _passwordController.text = value;

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  String get _username => _usernameController.text;
  set _username(String value) => _usernameController.text = value;

  final _fullNameController = TextEditingController();
  String get _fullName => _fullNameController.text;
  set _fullName(String value) => _fullNameController.text = value;

  final _phoneController = TextEditingController();
  String get _phone => _phoneController.text;
  set _phone(String value) => _phoneController.text = value;

  final _emailController = TextEditingController();
  String get _email => _emailController.text;
  set _email(String value) => _emailController.text = value;

  final _dobController = TextEditingController();
  String get _dob => _dobController.text;
  set _dob(String value) => _dobController.text = value;

  String _gender = 'Khác';

  String? _validateFullname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    } else if (value.length < 6) {
      return 'Độ dài ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    } else if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])')
        .hasMatch(value)) {
      return 'Mật khẩu phải có chữ thường, chữ hoa, số và kí tự đặc biệt';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validateAllFields() {
    if (_username.isEmpty ||
        _fullName.isEmpty ||
        _phone.isEmpty ||
        _email.isEmpty ||
        _dob.isEmpty) {
      return 'Vui lòng điền thông tin vào tất cả các trường';
    }

    final phoneError = _validatePhone(_phone);
    if (phoneError != null) {
      return phoneError;
    }

    final dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);
    if (dob == null) {
      return 'Ngày sinh không hợp lệ';
    } else if (dob.isAfter(DateTime.now())) {
      return 'Ngày sinh không thể là ngày trong tương lai';
    }

    return null;
  }

  //Hàm đăng ký
  void _register() async {
    final passwordError = _validatePassword(_password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(passwordError),
      ));
      return;
    } //kiểm tra mật khẩu

    if (_formKey.currentState?.validate() ?? false) {
      final allFieldsError = _validateAllFields();
      if (allFieldsError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(allFieldsError),
        )); //kiểm tra các trường trống
        return;
      }
      try {
        // Kiểm tra trùng lặp tên đăng nhập hoặc email
        final signInMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(_emailController.text);
        if (signInMethods.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Email đã được sử dụng'),
          ));
          return;
        }

        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: _phone)
            .get();
        if (userQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Số điện thoại đã được sử dụng'),
          ));
          return;
        }

        final dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);
        final formattedDob = DateFormat('dd/MM/yyyy').format(dob);

        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _username)
            .get();
        if (usernameQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Tên đăng nhập đã được sử dụng'),
          ));
          return;
        }

        final signInResult =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _password,
        );
        if (signInResult.user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Đăng ký không thành công'),
          ));
          return;
        }

        final passwordHash = sha256.convert(utf8.encode(_password)).toString();

        final user = {
          'uid': signInResult.user!.uid,
          'username': _username,
          'password': passwordHash,
          'fullName': _fullName,
          'phone': _phone,
          'email': _email,
          'dob': formattedDob,
          'gender': _gender,
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(signInResult.user!.uid)
            .set(user);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đăng ký thành công'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ));
        // print('User data saved successfully');

        // Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Đăng ký không thành công'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đăng ký không thành công'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Đăng ký'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //TrườngTài khoản
            TextFormField(
              decoration: InputDecoration(labelText: 'Tài khoản'),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
              validator: _validateUsername,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            //Trường mật khẩu
            TextFormField(
              // controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
              ),
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
                _formKey.currentState?.validate();
              },
              validator: _validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            SizedBox(height: 10),
            TextFormField(
              // controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Họ tên',
              ),
              onChanged: (value) {
                setState(() {
                  _fullName = value;
                });
                _formKey.currentState?.validate();
              },
              validator: _validateFullname,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
              onChanged: (value) {
                setState(() {
                  _phone = value;
                });
              },
              validator: _validatePhone,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                    validator: _validateEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  // Các TextFormField khác ở đây...
                ],
              ),
            ),
            SizedBox(height: 10),
            DateTimePicker(
              type: DateTimePickerType.date, // Chỉ hiển thị ngày tháng năm
              firstDate:
                  DateTime(1900), // Ngày đầu tiên mà người dùng có thể chọn
              lastDate:
                  DateTime.now(), // Ngày cuối cùng mà người dùng có thể chọn
              dateMask: 'dd/MM/yyyy', // Định dạng ngày tháng năm
              decoration: InputDecoration(labelText: 'Ngày, tháng, năm sinh'),
              onChanged: (value) {
                setState(() {
                  _dob = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ngày sinh không được bỏ trống';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Giới tính'),
              value: _gender,
              items: ['Nam', 'Nữ', 'Khác']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value.toString();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn giới tính';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Đăng ký'),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final allFieldsError = _validateAllFields();
                  if (allFieldsError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(allFieldsError),
                    ));
                    return;
                  }
                  _register();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
