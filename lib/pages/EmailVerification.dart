import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realtime/pages/fillprofil.dart';

class Verifikasi extends StatefulWidget {
  final String email;
  final String uid;

  const Verifikasi({
    super.key,
    required this.email,
    required this.uid,
  });

  @override
  State<Verifikasi> createState() => _VerifikasiState();
}

class _VerifikasiState extends State<Verifikasi> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  Timer? countdownTimer;
  int countdown = 60;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;

    if (user != null) {
      _sendEmailVerification();
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          chekemail();
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendEmailVerification() async {
    if (!isButtonDisabled) {
      setState(() {
        isButtonDisabled = true;
        countdown = 60;
      });

      try {
        await user!.sendEmailVerification();
        print('Email terkirim ke ${user!.email}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Link verifikasi telah dikirim ke email Anda.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              if (countdown > 0) {
                countdown--;
              } else {
                timer.cancel();
                isButtonDisabled = false;
              }
            });
          }
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'too-many-requests'
                  ? 'Terlalu banyak permintaan. Silakan coba lagi nanti.'
                  : 'Terjadi kesalahan. Silakan coba lagi nanti.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                e.code == 'too-many-requests' ? Colors.red : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String get timerText {
    final minutes = (countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              SizedBox(height: 100),
              Text(
                'Verifikasi email Anda',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Link verifikasi sudah dikirimkan ke email:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                '${user?.email}',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Silakan cek email Anda dan klik link verifikasi untuk melanjutkan. Jika email verifikasi tidak masuk, klik tombol "Kirim Ulang Email Verifikasi" di bawah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed:
                          isButtonDisabled ? null : _sendEmailVerification,
                      child: Text(
                        'Kirim Ulang Email Verifikasi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (isButtonDisabled)
                Text(
                  '$timerText',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> chekemail() async {
    user = auth.currentUser;
    await user?.reload();

    try {
      String imageUrl = '';
      String telepon = '';
      String nama = '';

      if (user != null && user!.emailVerified) {
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('users');
        await usersRef.child(user!.uid).update({
          'email': widget.email,
          'uid': user!.uid,
          'profilePicture': imageUrl,
          'nama': nama,
          'telepon': telepon,
        });

        // buat user data map
        Map<String, dynamic> userData = {
          'email': widget.email,
          'uid': user!.uid,
          'nama': nama,
          'telepon': telepon,
        };
        print('Data Pengguna: $userData');
        await _saveUserDataToFile(userData);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => fillProfile()),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _saveUserDataToFile(Map<String, dynamic> userData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.json');
    await file.writeAsString(json.encode(userData));
  }
}
