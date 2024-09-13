import 'package:flutter/material.dart';

class ProfileOtherUser extends StatefulWidget {
  final String userId;
  final String namaOtherUser;
  final String PPOtherUser;
  final String otheremail;
  final String othertelepon;

  const ProfileOtherUser({
    Key? key,
    required this.userId,
    required this.namaOtherUser,
    required this.PPOtherUser,
    required this.otheremail,
    required this.othertelepon,
  }) : super(key: key);

  @override
  State<ProfileOtherUser> createState() => _ProfileOtherUserState();
}

class _ProfileOtherUserState extends State<ProfileOtherUser> {
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
            tag: widget.PPOtherUser,
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
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: widget.PPOtherUser != ""
                      ? () {
                          showLargeImage(widget.PPOtherUser);
                        }
                      : null,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    backgroundImage: widget.PPOtherUser != ""
                        ? NetworkImage(widget.PPOtherUser)
                        : null,
                    child: widget.PPOtherUser == ""
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 100,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Nama",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 500,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Text(
                    '${widget.namaOtherUser}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Jabatan",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 500,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Text(
                    '${widget.othertelepon}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 500,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Text(
                    '${widget.otheremail}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
