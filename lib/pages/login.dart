import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realtime/pages/EmailVerification.dart';
import 'package:realtime/pages/ForgotPassword.dart';
import 'package:realtime/pages/home.dart';
import 'package:realtime/pages/signup.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isValidationFailed = false;
  bool _obscurePassword = true;

  void _signInWithEmailAndPassword() async {
    if (_isValidationFailed) {
      return;
    }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi email dan kata sandi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          // Redirect to Verifikasi Page if email is not verified
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Verifikasi(
                email: user.email!,
                uid: user.uid,
              ),
            ),
          );
          return;
        }

        // Ambil data pengguna dari Realtime Database
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users').child(user.uid);

        userRef.onValue.listen((DatabaseEvent event) async {
          if (event.snapshot.value != null) {
            var userValue = event.snapshot.value as Map<dynamic, dynamic>?;
            if (userValue != null) {
              Map<String, dynamic> userData = {
                'uid': user.uid,
                'nama': userValue['nama'] ?? 'N/A',
                'telepon': userValue['telepon'] ?? 'N/A',
                'email': userValue['email'] ?? 'N/A',
              };
              print('Data Pengguna: $userData');

              // Simpan data pengguna ke file JSON
              await _saveUserDataToFile(userData);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home_Page(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data pengguna tidak ditemukan.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Data pengguna tidak ditemukan.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Gagal masuk: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cek kembali email dan kata sandi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _saveUserDataToFile(Map<String, dynamic> userData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.json');
    await file.writeAsString(json.encode(userData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "DisApp",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Email',
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                  ),
                  cursorColor: Colors.blue,
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Kata Sandi',
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  cursorColor: Colors.blue,
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _signInWithEmailAndPassword,
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun?",
                      ),
                      CupertinoButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return signup();
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Daftar",
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
