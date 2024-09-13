import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class uprofil_page extends StatefulWidget {
  @override
  _uprofil_pageState createState() => _uprofil_pageState();
}

class _uprofil_pageState extends State<uprofil_page> {
  late DatabaseReference _userRef;
  late User? _currentUser;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _userRef =
        FirebaseDatabase.instance.ref().child('users').child(_currentUser!.uid);
  }

  void updateUserData(String field, String newValue) {
    _userRef.update({
      field: newValue,
    });
  }

  Future<File?> cropImage(File imageFile) async {
    final imageCropper = ImageCropper();

    CroppedFile? croppedImage = await imageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      compressQuality: 20,
    );

    if (croppedImage != null) {
      File croppedFile = File(croppedImage.path);
      return croppedFile;
    } else {
      return null;
    }
  }

  void selectImage(ImageSource source) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Izin Penting"),
            content: Text("Untuk melanjutkan, memerlukan izin penyimpanan."),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Tutup",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      File? croppedImageFile = await cropImage(imageFile);
      if (croppedImageFile != null) {
        setState(() {
          _imageFile = croppedImageFile;
        });
        uploadImage(croppedImageFile);
      }
    }
  }

  void uploadImage(File imageFile) {
    String uid = _currentUser!.uid;
    String fileName = '$uid.jpg';

    Reference ref =
        FirebaseStorage.instance.ref("profilePicture").child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((url) {
        updateUserData('profilePicture', url);
      });
    });
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Unggah foto Profil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(
                  Icons.image,
                  color: Colors.blue,
                ),
                title: Text("Pilih dari galeri"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  deleteProfilePicture();
                  setState(() {
                    _imageFile =
                        null; // Setel kembali variabel _imageFile menjadi null
                  });
                },
                leading: Icon(
                  Icons.delete,
                  color: Colors.blue,
                ),
                title: Text("Hapus foto profil"),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteProfilePicture() async {
    // Hapus gambar dari penyimpanan Firebase
    String uid = _currentUser!.uid;
    String fileName = '$uid.jpg';

    Reference ref =
        FirebaseStorage.instance.ref("profilePicture").child(fileName);
    await ref.delete();

    // Update database untuk menghapus URL gambar dari profil pengguna
    updateUserData('profilePicture', '');
  }

  void showLargeImage(String? imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Image.asset('assets/icons/back.png'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: 'profileImage',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Profil",
          style: TextStyle(
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.normal,
              color: Colors.white),
        ),
      ),
      body: _currentUser != null
          ? StreamBuilder<DatabaseEvent>(
              stream: _userRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(child: Text('No user data found.'));
                }

                Map<dynamic, dynamic> userData =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (userData['profilePicture'] != null)
                          // SizedBox(
                          //   height: 10,
                          // ),
                          Stack(
                            children: [
                              if (userData['profilePicture'] != null &&
                                  userData['profilePicture'] != "")
                                CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      NetworkImage(userData['profilePicture']),
                                  child: GestureDetector(
                                    onTap: () {
                                      showLargeImage(
                                          userData['profilePicture']);
                                    },
                                  ),
                                ),
                              if (userData['profilePicture'] == null ||
                                  userData['profilePicture'] == "")
                                CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.grey,
                                  child: GestureDetector(
                                    onTap: () {
                                      showLargeImage(
                                          userData['profilePicture']);
                                    },
                                    child: Icon(Icons.person,
                                        size: 100, color: Colors.white),
                                  ),
                                ),
                              Positioned(
                                bottom: 10,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    showPhotoOptions();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    child: Icon(Icons.camera_alt,
                                        color: Colors.white, size: 30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Nama",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.black, width: 2)),
                          child: Row(
                            children: [
                              Text(
                                '${userData['nama'] ?? 'No nama available'}',
                                style: TextStyle(fontSize: 20),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          TextEditingController _controller =
                                              TextEditingController();
                                          return AlertDialog(
                                            title: Text('Ubah nama'),
                                            content: TextField(
                                              controller: _controller,
                                              decoration: InputDecoration(
                                                hintText: 'Masukkan nama Anda',
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .blue), // Warna garis bawah saat fokus
                                                ),
                                              ),
                                              cursorColor: Colors.blue,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  String newnama =
                                                      _controller.text;
                                                  updateUserData('nama',
                                                      newnama.toLowerCase());
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Simpan',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Telepon",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${userData['telepon'] ?? 'No telepon available'}',
                                style: TextStyle(fontSize: 20),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          TextEditingController _controller =
                                              TextEditingController();

                                          return AlertDialog(
                                            title: Text('Ubah telepon'),
                                            content: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: _controller,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Masukkan nomor telepon Anda',
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .blue), // Warna garis bawah saat fokus
                                                ),
                                              ),
                                              cursorColor: Colors.blue,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  String newtelepon =
                                                      _controller.text;
                                                  updateUserData(
                                                      'telepon', newtelepon);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Simpan',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${userData['email'] ?? 'No email available'}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('No user signed in.'),
            ),
    );
  }

  croppedFile(File imageFile) {}
}
