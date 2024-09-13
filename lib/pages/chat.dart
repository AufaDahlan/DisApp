import 'dart:convert';
import 'dart:io';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realtime/pages/profilotheruser.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String targetUserID;
  final String nama;
  final String profilePicture;
  final String email;
  final String telepon;

  ChatScreen({
    required this.roomId,
    required this.targetUserID,
    required this.nama,
    required this.profilePicture,
    required this.email,
    required this.telepon,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference referenceDatabase =
      FirebaseDatabase.instance.ref().child('rooms');
  TextEditingController messageController = TextEditingController();
  final storage = FlutterSecureStorage();
  Map<String, String> decryptedMessages = {};
  Map<String, bool> _downloadingFiles = {};

  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  String? userNama;

  Future<void> getUserNama() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference referenceDatabase =
        FirebaseDatabase.instance.ref().child('users').child(uid);

    try {
      final DatabaseEvent event = await referenceDatabase.once();

      if (event.snapshot.exists) {
        final Map<dynamic, dynamic>? userData =
            event.snapshot.value as Map<dynamic, dynamic>?;
        userNama = userData?['nama'];
        print("Nama pengguna: $userNama");
      } else {
        print("Data pengguna tidak ditemukan.");
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengambil data pengguna: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('icon');

    // const InitializationSettings initializationSettings =
    //     InitializationSettings(android: initializationSettingsAndroid);

    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  //   print('Download status for task $id: $status, progress: $progress%');

  //   // Menangani status unduhan
  //   switch (status) {
  //     case DownloadTaskStatus.enqueued:
  //       print('Unduhan berada dalam antrean.');
  //       break;
  //     case DownloadTaskStatus.running:
  //       print('Unduhan sedang berlangsung: $progress%');
  //       break;
  //     case DownloadTaskStatus.complete:
  //       print('Unduhan selesai.');
  //       break;
  //     case DownloadTaskStatus.failed:
  //       print('Unduhan gagal.');
  //       break;
  //     default:
  //       break;
  //   }

  //   // mengupdate UI atau status unduhan di sini
  // }

  IconData _getFileTypeIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file;
    String ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  void showLargeImage(String? imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: widget.profilePicture,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    )
                  : Icon(Icons.person, size: 100, color: Colors.white),
            ),
          ),
        ),
      );
    }));
  }

  Future<void> _decryptMessage(String roomId, String messageId,
      String encryptedText, int timestamp) async {
    if (!decryptedMessages.containsKey(messageId)) {
      String? priv_key = await storage.read(key: "private_key");
      var decrypted = await RSA.decryptPKCS1v15(encryptedText, priv_key!);
      if (mounted) {
        setState(() {
          decryptedMessages[messageId] = decrypted;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        leading: Row(
          children: [
            IconButton(
              icon: Image.asset('assets/icons/back.png'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: Text('Lihat profil'),
                value: 'opt1',
              ),
              PopupMenuItem(
                child: Text('Bersihkan chat'),
                value: 'opt2',
              ),
            ],
            onSelected: (value) {
              if (value == 'opt1') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileOtherUser(
                      userId: widget.targetUserID,
                      namaOtherUser: widget.nama,
                      PPOtherUser: widget.profilePicture,
                      otheremail: widget.email,
                      othertelepon: widget.telepon,
                    ),
                  ),
                );
              } else if (value == 'opt2') {
                bool isChecked = false;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: Text('Bersihkan chat ini?'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isChecked = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text.rich(
                                      TextSpan(
                                        text:
                                            'Bersihkan chat juga membersihkan pada ',
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: widget.nama,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                'Bersihkan chat',
                                style: TextStyle(
                                  color: isChecked ? Colors.blue : Colors.grey,
                                ),
                              ),
                              onPressed: isChecked
                                  ? () {
                                      _clearChat();
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ],
        title: Row(
          children: [
            GestureDetector(
              onTap: widget.profilePicture != ""
                  ? () {
                      showLargeImage(widget.profilePicture);
                    }
                  : null,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: widget.profilePicture != ""
                    ? NetworkImage(widget.profilePicture)
                    : null,
                child: widget.profilePicture == ""
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 8),
            Text(
              widget.nama,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: referenceDatabase
                    .child(widget.roomId)
                    .orderByChild('timestamp')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic>? map =
                        (snapshot.data!.snapshot.value as Map?);
                    List<dynamic> messages = [];
                    if (map != null) {
                      map.forEach((key, value) {
                        messages.add({"id": key, ...value});
                      });
                    }
                    messages.sort((a, b) {
                      final timestampA = a['timestamp'] ??
                          0; // Provide a default value of 0 if null
                      final timestampB = b['timestamp'] ??
                          0; // Provide a default value of 0 if null
                      return timestampB.compareTo(timestampA);
                    });

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        bool isSentByCurrentUser = (message['sender'] ==
                            FirebaseAuth.instance.currentUser!.uid);
                        String messageId = message['id'];

                        // Decrypt message jika belum
                        if (message['text'] != null) {
                          _decryptMessage(widget.roomId, messageId,
                              message['text'], message['timestamp']);
                        }
                        return Column(
                          crossAxisAlignment: isSentByCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            if (message['text'] != null)
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSentByCurrentUser
                                      ? Colors.blue
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      decryptedMessages[messageId] ??
                                          'Memuat pesan baru...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _formatTimestamp(message['timestamp']),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (message['imageUrl'] != null)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSentByCurrentUser
                                          ? Colors.blue
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                message['imageUrl'],
                                                fit: BoxFit.cover,
                                                width:
                                                    constraints.maxWidth * 0.7,
                                                height:
                                                    constraints.maxWidth * 0.7,
                                                color: isSentByCurrentUser
                                                    ? null
                                                    : Color.fromRGBO(
                                                        255, 255, 255, 0.5),
                                                colorBlendMode:
                                                    isSentByCurrentUser
                                                        ? BlendMode.dstATop
                                                        : BlendMode.srcOver,
                                              ),
                                            ),
                                            if (!isSentByCurrentUser)
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.transparent,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.download,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          _formatTimestamp(
                                              message['timestamp']),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            if (message['fileUrl'] != null)
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSentByCurrentUser
                                      ? Colors.blue
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getFileTypeIcon(message['fileName']),
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${message['fileName']}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Ukuran: ${_formatFileSize(message['fileSize'])}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isSentByCurrentUser)
                                          GestureDetector(
                                            onTap: () async {
                                              String fileName =
                                                  message['fileName'];
                                              if (!(await _isFileDownloaded(
                                                  fileName))) {
                                                setState(() {
                                                  _downloadingFiles[fileName] =
                                                      true;
                                                });
                                                await _downloadFile(
                                                    message['fileUrl'],
                                                    fileName);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'File sudah diunduh.'),
                                                    backgroundColor:
                                                        Colors.blue,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: _buildDownloadIcon(
                                                message['fileName']),
                                          )
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _formatTimestamp(message['timestamp']),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('Belum ada pesan'),
                    );
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          color: Colors.white,
                          // height: 50,
                          width: MediaQuery.of(context).size.width * 0.70,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SingleChildScrollView(
                                child: TextField(
                                  controller: messageController,
                                  maxLines: 5,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      hintText: "Ketik Pesan",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            PopupMenuButton(
                              icon: Image.asset('assets/icons/clip.png'),
                              onSelected: (value) async {
                                final storageStatus =
                                    await Permission.storage.status;
                                if (!storageStatus.isGranted) {
                                  final result =
                                      await Permission.storage.request();
                                  if (!result.isGranted) {
                                    print('Izin penyimpanan tidak diberikan.');
                                    return; // Hentikan jika izin tidak diberikan
                                  }
                                }
                                if (value == 'image') {
                                  final imagePicker = ImagePicker();
                                  final pickedFile = await imagePicker
                                      .pickImage(source: ImageSource.gallery);

                                  if (pickedFile != null) {
                                    final imageFile = File(pickedFile.path);
                                    final imageRef = FirebaseStorage.instance
                                        .ref()
                                        .child(widget.roomId)
                                        .child(
                                            '${DateTime.now().millisecondsSinceEpoch}');
                                    await imageRef.putFile(imageFile);
                                    final imageUrl =
                                        await imageRef.getDownloadURL();

                                    _sendMessage('', imageUrl: imageUrl);
                                  }
                                }
                                if (value == 'file') {
                                  final result = await FilePicker.platform
                                      .pickFiles(allowMultiple: false);

                                  if (result != null) {
                                    final filePath = result.files.single.path!;
                                    final file = File(filePath);
                                    if (await file.exists()) {
                                      final fileName = result.files.single.name;
                                      final fileRef = FirebaseStorage.instance
                                          .ref()
                                          .child(widget.roomId)
                                          .child(
                                              '${DateTime.now().millisecondsSinceEpoch}_$fileName');

                                      await fileRef.putFile(file);
                                      final fileUrl =
                                          await fileRef.getDownloadURL();
                                      final fileFileSize = await file.length();
                                      _sendMessage('',
                                          fileUrl: fileUrl,
                                          fileName: fileName,
                                          fileSize: fileFileSize);
                                    } else {
                                      print('File tidak ditemukan.');
                                    }
                                  }
                                }
                              },
                              offset: Offset(0, 300),
                              itemBuilder: (BuildContext bc) {
                                return [
                                  PopupMenuItem(
                                    value: 'image',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Pilih Gambar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'file',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.file_copy_outlined,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Pilih File'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width * 0.03,
                            // ),
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.blue),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  iconSize: 20,
                                  onPressed: () {
                                    if (messageController.text.isNotEmpty) {
                                      _sendMessage(messageController.text);
                                      messageController.clear();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(String text,
      {String? imageUrl,
      String? imagestatus,
      String? fileUrl,
      String? filestatus,
      String? fileName,
      int? fileSize}) async {
    if (text.isNotEmpty ||
        imageUrl != null ||
        fileUrl != null ||
        fileName != null) {
      Map<String, dynamic> messageData = {
        'sender': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (text.isNotEmpty) {
        print("===== current UID ========");
        print(widget.targetUserID);
        print("============================");

        String? public_key;
        String? fcmToken;

        final DatabaseReference refToUsers =
            FirebaseDatabase.instance.ref().child('users');

        await refToUsers
            .child(widget.targetUserID)
            .once()
            .then((DatabaseEvent event) {
          print(event.snapshot.value);

          if (event.snapshot.value != null) {
            Map<dynamic, dynamic>? pubkey =
                event.snapshot.value as Map<dynamic, dynamic>?;

            pubkey?.forEach((key, value) {
              if (key == "public_key") {
                print("=====tampildata pubkey=====");
                public_key = value;
                print(value);
              } else if (key == "fcmToken") {
                print("=====tampildata fcmToken=====");
                fcmToken = value;
                print(value);
              }
            });
          }
        });
        if (public_key != null && fcmToken != null) {
          // Enkripsi pesan sebelum dikirim
          String messageId = referenceDatabase.child(widget.roomId).push().key!;
          decryptedMessages[messageId] = text;

          String encrypted = await RSA.encryptPKCS1v15(text, public_key!);
          messageData['text'] = encrypted;

          setState(() {
            decryptedMessages[messageId] = text;
          });

          // Kirim data pesan ke Firebase Realtime Database
          // referenceDatabase.child(widget.roomId).push().set(messageData);

          // Kirim notifikasi menggunakan FCM
          await _sendFCMNotification(fcmToken!, text, messageType: "text");
          // await _sendLocalNotification("$userNama", text, messageType: "text");
        } else {
          print("Kunci publik atau FCM token tidak ditemukan.");
        }
      }

      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
        messageData['imagestatus'] = false;
        print("===== current UID ========");
        print(widget.targetUserID);
        print("============================");

        String? fcmToken;

        final DatabaseReference refToUsers =
            FirebaseDatabase.instance.ref().child('users');

        await refToUsers
            .child(widget.targetUserID)
            .once()
            .then((DatabaseEvent event) {
          print(event.snapshot.value);

          if (event.snapshot.value != null) {
            Map<dynamic, dynamic>? pubkey =
                event.snapshot.value as Map<dynamic, dynamic>?;

            pubkey?.forEach((key, value) {
              if (key == "fcmToken") {
                print("=====tampildata fcmToken=====");
                fcmToken = value;
                print(value);
              }
            });
          }
        });
        await _sendFCMNotification(fcmToken!, imageUrl, messageType: "image");
        // await _sendLocalNotification("$userNama", imageUrl,
        //     messageType: "image");
      }

      if (fileUrl != null) {
        messageData['fileUrl'] = fileUrl;
        messageData['filestatus'] = false;
        messageData['fileName'] = fileName;
        messageData['fileSize'] = fileSize;
        print("===== current UID ========");
        print(widget.targetUserID);
        print("============================");

        String? fcmToken;

        final DatabaseReference refToUsers =
            FirebaseDatabase.instance.ref().child('users');

        await refToUsers
            .child(widget.targetUserID)
            .once()
            .then((DatabaseEvent event) {
          print(event.snapshot.value);

          if (event.snapshot.value != null) {
            Map<dynamic, dynamic>? pubkey =
                event.snapshot.value as Map<dynamic, dynamic>?;

            pubkey?.forEach((key, value) {
              if (key == "fcmToken") {
                print("=====tampildata fcmToken=====");
                fcmToken = value;
                print(value);
              }
            });
          }
        });
        await _sendFCMNotification(fcmToken!, fileName!, messageType: "file");
        // await _sendLocalNotification("$userNama", fileName!,
        // messageType: "file");
      }

      referenceDatabase.child(widget.roomId).push().set(messageData);
    }
  }

  Future<String> getOAuthToken() async {
    final serviceAccountJson =
        await rootBundle.loadString('assets/service_account.json');
    final serviceAccount = jsonDecode(serviceAccountJson);

    final accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccount);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = http.Client();
    final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
      accountCredentials,
      scopes,
      client,
    );

    return accessCredentials.accessToken.data;
  }

  Future<void> _sendFCMNotification(String fcmToken, String message,
      {String? messageType}) async {
    const String firebaseApiUrl =
        'https://fcm.googleapis.com/v1/projects/chatapp-de7e8/messages:send';

    try {
      final String oauthToken = await getOAuthToken();
      await getUserNama();

      Map<String, dynamic> notificationPayload = {
        "message": {
          "token": fcmToken,
          "notification": {
            // "data": {
            "title": "$userNama",
            "body": messageType == "text"
                ? message
                : messageType == "file"
                    ? "📄 $message"
                    : "🖼️ Image",
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "screen": "ChatScreen",
            "messageType": messageType ?? "text",
            "title": "$userNama",
            "body": messageType == "text"
                ? message
                : messageType == "file"
                    ? "📄 $message"
                    : "🖼️ Image",
            "roomId": widget.roomId,
            "nama": widget.nama,
            "profilePicture": widget.profilePicture,
            "targetUserID": widget.targetUserID,
            "email": widget.email,
            "telepon": widget.telepon,
          }
        }
      };

      var response = await http.post(
        Uri.parse(firebaseApiUrl),
        headers: {
          "Authorization": "Bearer $oauthToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print("Notifikasi berhasil dikirim.");
      } else {
        print(
            "Gagal mengirim notifikasi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengirim notifikasi: $e");
    }
  }

  void _clearChat() async {
    await referenceDatabase.child(widget.roomId).remove();

    final storageRef = FirebaseStorage.instance.ref().child(widget.roomId);
    final ListResult result = await storageRef.listAll();
    for (var item in result.items) {
      try {
        await item.delete();
      } catch (e) {
        print('gagal hapus ${item.fullPath}: $e');
      }
    }

    try {
      await storageRef.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        print('folder tidak ditemukan');
      } else {
        print('gagal menghapus folder: $e');
      }
    }
    setState(() {
      decryptedMessages.clear();
    });
  }

  String _formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = "${date.day}/${date.month}/${date.year}";
    String formattedTime =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    return "$formattedDate $formattedTime";
  }

  String _formatFileSize(int fileSize) {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final externalDir = await getExternalStorageDirectory();
        final savedDir = Directory('${externalDir!.path}/DisApp/Documents');
        if (!await savedDir.exists()) {
          await savedDir.create(recursive: true);
        }

        await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: savedDir.path,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: true,
        );

        await FlutterDownloader.registerCallback((id, status, progress) {
          print('Download status for task $id: $status, progress: $progress%');
          if (status == DownloadTaskStatus.complete) {
            setState(() {
              _downloadingFiles[fileName] = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pengunduhan selesai.'),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (status == DownloadTaskStatus.failed) {
            setState(() {
              _downloadingFiles[fileName] = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pengunduhan gagal, coba lagi.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (status == DownloadTaskStatus.running) {
            setState(() {
              _downloadingFiles[fileName] = true;
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin penyimpanan ditolak.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      setState(() {
        _downloadingFiles[fileName] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildDownloadIcon(String fileName) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: _downloadingFiles[fileName] == true
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : FutureBuilder<bool>(
                future: _isFileDownloaded(fileName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink();
                  } else if (snapshot.hasData && snapshot.data!) {
                    return Icon(Icons.done, color: Colors.white);
                  } else {
                    return Icon(Icons.download, color: Colors.white);
                  }
                },
              ),
      ),
    );
  }

  Future<bool> _isFileDownloaded(String fileName) async {
    final externalDir = await getExternalStorageDirectory();
    final file = File('${externalDir!.path}/DisApp/Documents/$fileName');
    return await file.exists();
  }
}
