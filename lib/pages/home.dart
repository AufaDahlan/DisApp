import 'dart:io';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realtime/pages/chat.dart';
import 'package:realtime/pages/login.dart';
import 'package:realtime/pages/search.dart';
import 'package:realtime/pages/updateprofil.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late User _currentUser;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final storage = const FlutterSecureStorage();

  // pengguna lain
  List<String> _otherUserNames = [];
  List<String> _otherUserProfilePictures = [];
  List<String> _otherUserIds = [];
  List<String> _otheremail = [];
  List<String> _othertelepon = [];

  // pengguna login
  // List<String> _currentUserName = [];
  // List<String> _currentUseremail = [];
  // List<String> _currentUserProfilePicture = [];
  // List<String> _currentUserId = [];

  Map<String, dynamic> _latestMessages = {};
  Map<String, int> _latestTimestamps = {};

  String? nama;
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Izin notifikasi diberikan.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Izin notifikasi diberikan secara provisional.');
    } else {
      print('Izin notifikasi ditolak.');
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
    if (_currentUser != null) {
      await _checkRooms();
      _listenForNewRooms();
      _listenForRemovedRooms();
      // await _getdataCurrentUser();
    }
  }

  // Future<void> _getdataCurrentUser() async {
  //   String currentUserUid = _currentUser.uid;
  //   _database
  //       .child('users')
  //       .child(currentUserUid)
  //       .onValue
  //       .listen((DatabaseEvent event) {
  //     if (event.snapshot.value != null) {
  //       Map<dynamic, dynamic>? userData =
  //           event.snapshot.value as Map<dynamic, dynamic>?;

  //       if (userData != null && userData.containsKey('nama')) {
  //         String nama = userData['nama'] as String;
  //         String email = userData['email'] as String;
  //         String profilePicture = userData['profilePicture'] as String;
  //         String uid = userData['uid'] as String;
  //         if (!_currentUserName.contains(uid)) {
  //           setState(() {
  //             _currentUserName.clear();
  //             _currentUserProfilePicture.clear();
  //             _currentUseremail.clear();

  //             // _currentUserName.add(nama);
  //             // _currentUserProfilePicture.add(profilePicture);
  //             // _currentUseremail.add(email);
  //             // _currentUserId.add(uid);
  //           });
  //         }
  //       }
  //     }
  //   });
  // }

  Future<void> _checkRooms() async {
    String currentUserUid = _currentUser.uid;
    _database.child('rooms').once().then((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? rooms =
            event.snapshot.value as Map<dynamic, dynamic>?;
        rooms?.forEach((key, value) async {
          List<String> users = key.split('_');
          if (users.contains(currentUserUid)) {
            String otherUserId =
                users.firstWhere((userId) => userId != currentUserUid);
            await _getUserDetails(otherUserId);

            await _updateLatestMessages(key);

            // baca pesan terakhir di local
            // String? decryptedMessage = await _readMessage(key);
            // if (decryptedMessage != null) {
            //   setState(() {
            //     _latestMessages[key] = decryptedMessage;
            //     _latestTimestamps[key] = value['timestamp'] ?? 0;
            //   });
            // }
          }
        });
      }
    });
  }

  void _sortRoomsByLatestTimestamp() {
    List<Map<String, dynamic>> combinedList = [];
    for (int i = 0; i < _otherUserIds.length; i++) {
      String roomKey = generateRoomId(_currentUser.uid, _otherUserIds[i]);
      int timestamp = _latestTimestamps[roomKey] ?? 0;

      combinedList.add({
        'userId': _otherUserIds[i],
        'userName': _otherUserNames[i],
        'profilePicture': _otherUserProfilePictures[i],
        'email': _otheremail[i],
        'telepon': _othertelepon[i],
        'timestamp': timestamp,
        'lastMessage': _latestMessages[roomKey],
      });
    }

    combinedList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    _otherUserIds =
        combinedList.map((item) => item['userId'] as String).toList();
    _otherUserNames =
        combinedList.map((item) => item['userName'] as String).toList();
    _otherUserProfilePictures =
        combinedList.map((item) => item['profilePicture'] as String).toList();
    _otheremail = combinedList.map((item) => item['email'] as String).toList();
    _othertelepon =
        combinedList.map((item) => item['telepon'] as String).toList();
  }

  Future<void> _getUserDetails(String userId) async {
    _database.child('users').child(userId).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (userData != null && userData.containsKey('nama')) {
          String nama = userData['nama'] as String;
          String profilePicture = userData['profilePicture'] as String;
          String uid = userData['uid'] as String;
          String email = userData['email'] as String;
          String telepon = userData['telepon'] as String;
          if (!_otherUserNames.contains(nama)) {
            setState(() {
              _otherUserNames.add(nama);
              _otherUserProfilePictures.add(profilePicture);
              _otherUserIds.add(uid);
              _otheremail.add(email);
              _othertelepon.add(telepon);
            });
          }
        }
      }
    });
  }

  void _listenForNewRooms() {
    _database.child('rooms').onChildAdded.listen((event) async {
      String currentUserUid = _currentUser.uid;
      String roomKey = event.snapshot.key!;
      Map<dynamic, dynamic> roomData =
          event.snapshot.value as Map<dynamic, dynamic>;

      List<String> users = roomKey.split('_');
      if (users.contains(currentUserUid)) {
        String otherUserId =
            users.firstWhere((userId) => userId != currentUserUid);
        await _getUserDetails(otherUserId);

        // baca pesan terbaru di realtime
        await _updateLatestMessages(roomKey);

        // baca pesan terbaru di local storage
        // String? decryptedMessage = await _readMessage(roomKey);
        // if (decryptedMessage != null) {
        //   setState(() {
        //     _latestMessages[roomKey] = decryptedMessage;
        //     _latestTimestamps[roomKey] = roomData['timestamp'] ?? 0;
        //   });
        // }
      }
    });
  }

  Future<void> _updateLatestMessages(String roomKey) async {
    DatabaseReference roomRef = _database.child('rooms').child(roomKey);
    roomRef.orderByKey().limitToLast(1).onChildAdded.listen((event) async {
      String messageKey = event.snapshot.key!;
      Map<dynamic, dynamic> messageData =
          event.snapshot.value as Map<dynamic, dynamic>;

      if (messageData != null) {
        if (messageData['text'] != null) {
          // Dekripsi pesan teks dan update state
          await dekripsiPesan(messageData['text'], (decryptedMessage) async {
            if (mounted) {
              setState(() {
                _latestMessages[roomKey] = decryptedMessage;
                _latestTimestamps[roomKey] = messageData['timestamp'] ?? 0;
              });
            }
          });
        } else if (messageData['fileUrl'] != null) {
          if (mounted) {
            setState(() {
              _latestMessages[roomKey] = Icons.file_copy_sharp;
              _latestTimestamps[roomKey] = messageData['timestamp'] ?? 0;
            });
          }
        } else if (messageData['imageUrl'] != null) {
          if (mounted) {
            setState(() {
              _latestMessages[roomKey] = Icons.image;
              _latestTimestamps[roomKey] = messageData['timestamp'] ?? 0;
            });
          }
        }
      }
    });
  }

  Future<void> dekripsiPesan(
      String dataEnkripsi, Function(String) onDecrypted) async {
    // Ambil private key dari secure storage
    String? privKey = await storage.read(key: "private_key");

    // Dekripsi menggunakan private key
    var decrypted = await RSA.decryptPKCS1v15(dataEnkripsi, privKey!);

    // Panggil callback dengan hasil dekripsi
    onDecrypted(decrypted);
  }

  void _listenForRemovedRooms() {
    _database.child('rooms').onChildRemoved.listen((event) {
      String removedRoomKey = event.snapshot.key!;
      List<String> removedUsers = removedRoomKey.split('_');
      String currentUserUid = _currentUser.uid;

      if (removedUsers.contains(currentUserUid)) {
        setState(() {
          _latestMessages.remove(removedRoomKey);
          _latestTimestamps.remove(removedRoomKey);

          int indexToRemove = _otherUserIds.indexWhere((userId) =>
              generateRoomId(userId, currentUserUid) == removedRoomKey);
          if (indexToRemove != -1) {
            _otherUserIds.removeAt(indexToRemove);
            _otherUserNames.removeAt(indexToRemove);
            _otherUserProfilePictures.removeAt(indexToRemove);
            _otheremail.removeAt(indexToRemove);
            _othertelepon.removeAt(indexToRemove);
          }
        });
      }
    });
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) {
      return '';
    }
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }

  void _signOut() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _deleteUserDataFile(user.uid);
      }
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> _deleteUserDataFile(String uid) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_data.json');
      if (await file.exists()) {
        await file.delete();
        print('User data file deleted.');
      }
    } catch (e) {
      print('Error deleting user data file: $e');
    }
  }

  String generateRoomId(String userId1, String userId2) {
    List<String> participants = [userId1, userId2];
    participants.sort();
    String roomId = participants.join('_');
    return roomId;
  }

  @override
  Widget build(BuildContext context) {
    _sortRoomsByLatestTimestamp();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "DisApp",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => uprofil_page()));
              } else if (value == 2) {
                // Handle Log Out option
                _signOut();
              }
            },
            itemBuilder: (BuildContext bc) {
              return [
                PopupMenuItem(
                  child: Text("Profil"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text("Log Out"),
                  value: 2,
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _otherUserNames.length,
            itemBuilder: (context, index) {
              String roomKey;
              if (_otherUserIds[index].compareTo(_currentUser.uid) < 0) {
                roomKey = '${_otherUserIds[index]}_${_currentUser.uid}';
              } else {
                roomKey = '${_currentUser.uid}_${_otherUserIds[index]}';
              }

              String lastMessage = _latestMessages.containsKey(roomKey) &&
                      _latestMessages[roomKey] is String
                  ? _latestMessages[roomKey]
                  : '';

              int? lastTimestamp = _latestTimestamps.containsKey(roomKey)
                  ? _latestTimestamps[roomKey]
                  : 0;

              String lastMessageTime = _formatTimestamp(lastTimestamp!);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ChatScreen(
                        roomId: generateRoomId(
                            _currentUser.uid, _otherUserIds[index]),
                        nama: _otherUserNames[index],
                        profilePicture: _otherUserProfilePictures[index],
                        targetUserID: _otherUserIds[index],
                        email: _otheremail[index],
                        telepon: _othertelepon[index],
                      );
                    }),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: _otherUserProfilePictures[index] != ""
                        ? NetworkImage(_otherUserProfilePictures[index])
                        : null,
                    child: _otherUserProfilePictures[index] == ""
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  title: Text(_otherUserNames[index]),
                  subtitle: _latestMessages.containsKey(roomKey) &&
                          _latestMessages[roomKey] != null
                      ? Row(
                          children: [
                            _latestMessages[roomKey] is IconData
                                ? Icon(
                                    _latestMessages[roomKey] as IconData,
                                    size: 15,
                                  )
                                : Expanded(
                                    child: Text(
                                    _latestMessages[roomKey] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                          ],
                        )
                      : Text('tidak ada pesan'),
                  trailing: Text(lastMessageTime),
                ),
              );
            },
          ),
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => SearchPage(),
          //         ),
          //       );
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.all(25),
          //       child: CircleAvatar(
          //         backgroundColor: Colors.green,
          //         radius: 26,
          //         child: Icon(
          //           Icons.search,
          //           color: Colors.white,
          //           size: 26,
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
