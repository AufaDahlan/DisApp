import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:realtime/pages/chat.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');
  User? currentUser = FirebaseAuth.instance.currentUser;
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Stream<DatabaseEvent> searchUserBynama(String nama) {
    String lowerCaseName = nama.toLowerCase();
    return _userRef
        .orderByChild('nama')
        .startAt(lowerCaseName)
        .endAt(lowerCaseName + "\uf8ff")
        .onValue;
  }

  //mengambil semua data user
  Stream<DatabaseEvent> getAllUsers() {
    return _userRef.onValue;
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
            tag: ['profilePicture'],
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
        title: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          decoration: InputDecoration(
            hintText: "Cari",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {});
          },
          cursorColor: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                //stream untuk memutuskan antara pencarian atau mengambil semua pengguna
                stream: searchController.text.isNotEmpty
                    ? searchUserBynama(searchController.text.trim())
                    : getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic>? userData =
                        (snapshot.data!.snapshot.value as Map?);
                    List<Map<dynamic, dynamic>> usersList = [];
                    if (userData != null) {
                      userData.forEach((key, value) {
                        if (value['uid'] != currentUser!.uid &&
                            value['nama'] != null &&
                            value['nama'].isNotEmpty &&
                            value['telepon'] != null &&
                            value['telepon'].isNotEmpty) {
                          usersList.add(value);
                        }
                      });
                    }

                    // urutkan list pengguna berdasarkan 'nama'
                    usersList.sort((a, b) {
                      return a['nama']
                          .toString()
                          .toLowerCase()
                          .compareTo(b['nama'].toString().toLowerCase());
                    });

                    return usersList.isNotEmpty
                        ? ListView.builder(
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              var value = usersList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ChatScreen(
                                          roomId: generateRoomId(
                                              currentUser!.uid, value['uid']),
                                          nama: value['nama'],
                                          profilePicture:
                                              value['profilePicture'],
                                          targetUserID: value['uid'],
                                          email: value['email'],
                                          telepon: value['telepon'],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: GestureDetector(
                                    onTap: value['profilePicture'] != null &&
                                            value['profilePicture'] != ""
                                        ? () {
                                            showLargeImage(
                                                value['profilePicture']);
                                          }
                                        : null,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          value['profilePicture'] != null &&
                                                  value['profilePicture'] != ""
                                              ? NetworkImage(
                                                  value['profilePicture'])
                                              : null,
                                      child: value['profilePicture'] == null ||
                                              value['profilePicture'] == ""
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                  title: Text(value['nama']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        value['email'],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(value['telepon'],
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text('Tidak ada hasil'),
                          );
                  } else {
                    return Center(
                      child: Text('Tidak ada hasil'),
                    );
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  String generateRoomId(String userId1, String userId2) {
    List<String> participants = [userId1, userId2];
    participants.sort();
    String roomId = participants.join('_');
    return roomId;
  }
}
