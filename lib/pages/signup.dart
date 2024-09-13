// ignore_for_file: deprecated_member_use

import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:realtime/pages/EmailVerification.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();
String public_key = '';
//String passsUUID = uuid.v4();

const password = '123456789';
const pkcs12 =
    '''MIIQSQIBAzCCEA8GCSqGSIb3DQEHAaCCEAAEgg/8MIIP+DCCBi8GCSqGSIb3DQEH
BqCCBiAwggYcAgEAMIIGFQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQI/pTm
UKFwK/UCAggAgIIF6N5rjkv/eidrXYlkrkyl2EBNfK8hQU+cJt0lkLt6zVC+ddNW
THJW4R98rhFGqYvSRHP13H65Pq+zG8nFu4WyRog3qO/rOcQPNCFeJQ1k1RUa7HSx
Ugjki8s7WG0+EsuA39jqZDrVDdaU2gWrgR9Oj5d5/zITYu7Rr37I+S1es9otUBus
YPd/YaNwtWyLuZJikDjQuMxtHEzyRshu0fylDloTFLGSmdQQR2DxQDWffoi3Hq1G
a7KoDW9kgqZPAyOOeRf24Y3dqNYJbJ9Sk5w5GNQldGy++LH26fhcu+/fXMxjq5+9
0Z2mJguDGbKf4JtAXEaFQGE7UQFULjdh4dmfl45Wv4rhfyst+BA6wvW3EClJ3/7a
/pmtM0SmiGmIxKO3AYsqCljkRJvpE5Ph5SmsX8HJQBMX0AkYzQI9KmSuCyuze64y
4VmW0ZLxfL/rmJn1UIywaznQcE/f2eN52K39eo96P1rY19hbTx+b+pSTnpFnxf8e
vkbVvLKLug0ifZcw+cIF+AeUS/SRVA06icC6ul2vdAsc78tlSXkVBzV/dj1ohIU6
i3atO7Lz+OIHRlh02IVtCW/Pwgm44kmxYu6ZM3P1uQjVympBkelD/4wBLdZMCUwP
4z9wGD9gQUVzxspwL3d9NHRdd1JLVFxoLG0kmt1zj2EEMTyPuHtGMyzhRRM6qDu1
1JUTDgyO1dFHmWqBbWyrPe1gAaGvZUaMrmv2ekvncOgvMZEIbvxEVf3nH49lBJ5h
qBNBHDPgIjQcrpF4ym5ghWq/fmoH27Wn5wKyJkfs54TLy7AWM125zqINntTN89Mf
IcqLLBumlgRfy0QnsZiAzeQf6ELrrMUw1LqV9PPwTGlcqk9CfVI2jaDYGSKtkbrr
CbeNmElF9wU/kmMSzEsVqfRPfaWMNkpuIek330lEkHHBbZ38kaXsJcXcAQ1swoc9
UegtOKX1g0wU4+fMIX43tlzIz1RmNqjQXBlLBFqc++JHwqGW1bhrNOJqvAKZhGU0
QPCQNYxh5waqWdGUa5P+kWAAlIOd24aMohlKIYYVJXkFbZhDcDhY85FUeEP5AT5L
tOKCtE7dI6LK+m2nR+yw0zwokqmfwqh3IQJYOirZc2BYa8VDYVj1gaHsGcsKCE1g
6lzvKvIUzRRIWc/xvzOfD6ywD9/MTBkgGAYokocLkd+BFcrtJkWt0VzVCj32t7G7
PgPxjns5xSyDRAR8Q9UGyCnj4RrRsuLyR+B/swFdTfRLaVNFEHNxZnOBolvxzcNE
sF2PV+3ZRMQE/8FCbk3z9vG/LMey+Z2TLtB4HA0uzGC+YrnFsIBFCksfIaDHzhrg
Wm+D4tNwEDGnT31f/beyIf3FWVcaogxQYD//s4k3ldTc46h+hJenMhPWgq1lvIyK
VOHveA5AzGiOTdBBqn8eoQsHnP8d7axoYu2Es1Yh//5jBQU0v6WLnzlirj+t24s/
1YqsXyJXDN0jlMQ6+lVx6KOWUGjbuZtGuOfY6rwzv9TDq2hPZLFmCANLlJcahDgZ
ipvrGIO4xP7tlTf49ASckbqLB3CF6Fe4/FhK7teo4TEXEjilHlacIiELUUo7Jo6h
+6r1fsv1VplBHyhF1zzWKX0RCytx8dw5Py7uBxWz4aSTjmg6k9SLri1KMZRvGsp/
sVUarJ6sNRhGk86gWpgE0uH3q8ZBGrs0roF1YMGJHdtqPT7sdulhuvhDHS8idRIR
mzWG3yiFvEcbSydPyQriTdENHbmf+faRkTMucOaac5bqdazqDgKHtzPiH0+5ruNA
xlSiInoI8w8Xh0XRlL2eZ3j0OyOftYzj+xCdkhGj2nYXecvlaPBhs7ZIuvltn2Oe
6zI2fudtiOVSo6Eb98h8v9TpM1SS4RL7BnCnPkhX3XNCu3H5D10YerGlLjqwX3ZQ
WpgBTRhpC2A8TEFGZBu/GHAvR/4sVSkPW7Nw6TBcCNVThrnyM4o7bDCdmlCBXFmr
jz5O5C2e8/xCqvmzL+EG0/iny+5p3si6xAnPleniUyiS6IdybTCCCcEGCSqGSIb3
DQEHAaCCCbIEggmuMIIJqjCCCaYGCyqGSIb3DQEMCgECoIIJbjCCCWowHAYKKoZI
hvcNAQwBAzAOBAiINWiWDO9TpgICCAAEgglItWrFwv6mt10g76SgnfbqUnz3glB8
vBUk5zouqR+43/fSF0hK0LhRF5vsnq8U2jwXTYxQYguJy6MjpZl1wNZ42kdWMCHF
ci8EYn9+4xd+tSakuilJmEJ4hybD3GRabcslivurd/9sGYpQ9oPWLbuEsoJJC83y
qn6YQL6DSbdb1hctndEp2kuLK7Xha1pe1T99vrgieGeELV1MCitR2tGR4o38UjBb
YUxI8wXtjSFWI+59szwdwnOTi8jBBgxyD0mzfAe7jnwuX61Kctj97UBKp353jtUq
flOVqqCkLq+yvpId/361CL3+k1Gi6xMfFUH+GwBJZcCc2Ue/wsoWlFnA9Ck2+ROt
cvS9Q94otkOPkscGU92sna6Oz4ESGgSTyc0HumuApbq33t6+yQKZtV/zds48IeQ1
ZaDqCtYhycr80CSveHuyI12ExNRT56AFTEk9oP7OpCu3BhqECDPJ+tF+TyGBjPf8
MQyshXPaGkf/gzpkcK21ZCKDZgbFkt07WzmjrIn5JvpO+spxKxXSDMe4DGeA3fkT
VVUwumJl1y/8uHs9MQmL7jZgicoCap75lSuR84zMnF0zRbmNK33ujHCpyMZ/F/Ys
tVR9SwcdJCa30nckkWUAMhKTa5UI856aR9Qtwu9384ggrtXvqz1uUy3MkAluOPX+
Ce4RWpUO87qEk2oOwN6lPVBlRnUe9VbmRlTBTeLgsF7lXLZ820pQkuZAql1XAFa0
FzjHw3f846XFlt3sFjkgBlLo/x8zVQ7HX9S+3aBiGZO0eY1T5HeTjiDOEuxDa0ZY
CbsD7NuFiZud06m7BoiOVxiFAuq3RE15NC86f8zEfP2Resfr/LGLeeSqpIzwvCTI
kUczHPoTtHQWEdo1M8/gAYhavv9dYz1c9uvI8ZQcnc7S4X7fA9JFXi2bJQrWKOJr
x4wFAj3nUH6PaC8/Lg74cJzTqy7STEoHrlQbDMLZNAO974AJGDm7glSw4XwQO5h+
euL4J7vTXx+WbnRT1ymHfvUZEydqH0DEjLkicut65tbvJZAm6M3tbBCP24myWUHR
tbw7BZQKczt/AxmgotC5Nt8uflzSfQ2n2POTwxOrvWcd660rrumkVANCMas5WiQD
2zlxMBjiNW3JA2I/ytivyYKGampECZEi3Zcl3FuBTFBJkSbeShfAA8wWPYxiVn/M
ybdT24uQThtQEvpPOkxyszHB7L6nnQ7a/eOjMPUc+oe2cfTbupU2ZtArSxZm7vMn
B1gyFxHIIkFlp1RzYVtYoQcHN9XDRc9lanCKQUn6Rrqq6KoQN/rXf6VRvoWG23tg
SlEBC73sd/28mcbSyMYDB18zmbZnzMazSUzndDpgv+5qypcslRq1fSfAK3dKUOI8
7kPpKxRtq5HvuiGMqLG9xzdlJpqCUJ3PAhsYNmU2uFVqsaRLzOBNk0e7M0H0NAr1
4YuXh6ZPjx65ZBJRLRwl7vNEgbWT0QYb9e2Hr7sxuWvjFEeac6N43PXOvMVEBNFc
3Y+ZeMV4K6833H8u9WMKRIHOUNRXXaAWIZvK2qsdyMV/y+wfK9L9GTdDcXFJg6xJ
KNUjcz6p3TLsEf2l8qG2Ddb1/0dfMBx8qE9Hfw9MBPKYbkYmJECStLLfPZ04GQ4s
yS+niHKvvMnsJHVfz18zcnnaA9EIg3FCsvs5TuVShMWkATrbBuhUbpmiU6iyTjtI
esXg46yXFOeam547fXDOYXUTnp+i8SK4ovFOwZ0KbjK0cr/WrbGla59SSpmEW80u
JeOl/icVuI2A1VclLmQt5ZKeMzKUBbG5ontVNTsOeXylAdG/cC13UiXVFjt029YV
XwKEjIzZE1++pa1FZrkHJvz/zkE6fnTUlSN52eIP6IMQWfIEemPUTtq217tEgicX
PgSig9oCL4ZX2dekm8a4xVzLu/e5v6BKHLIY6AdfwWXxYvxQlX6PVAybDT01eRMS
7LErjuY+3jB/o9Mptta777iRFAL/aohDd4zKBNVKRPCdhDXA8+n/OSQ3tEBOM32X
YOOKntunjdDe3+dachRp3U5SIfaympX92bAsN2USNooAfjN2YbiMd2coO/SrKv6Q
86Wz984ojyArA+/bEtoi91C7EAim7lo1LHeEFj8J8RC9AqYKIo0OeNjIjgDAx+Su
kkWt+N0zNgumwXfeODb/THkJkgfv+OrlexwUtvrvT6gh8RHWETByxUVCu6sYqQMC
YIP9ztSszuIhEvHrMII+lf98E1aGM5T3L/VQBmO4DEDqxrQ38r+7XPAK4uSXyKjg
mx+cIp5KohrlKgXeVg8aZvGLCDz4LHqhfZh6O6xTZM2uaR4iM00ZPEpPnSzTlZvg
Otv7rWjn7eP27HpJfNQMEKRRftxx1FOwBHCcrtMyU5x5cb2Qt7rkIMWTroInLubt
wCwat48j2FzDejxGxWyX30Bi6BH0Un79GC3TH4PkXaBwquBLSwdQjCUGUgUp83l4
C3zXH8m1TuPgQ6pkplS0nNsjRVNHSQo94AbkmwuLEyEDSAUhC3ZW2tkQ9sj4tE7v
dUCZf4Ngl6bqjQdUNCKMaHYqzfg6ndt+al3OwMvgmIhG6D8z0yhj7sdJA7Ioj2q9
kwdh9/Y/hglGTEUiHYl+Yv9MXBkxYxrofEjMToR8DRYgdJlTyuMBZpf52mHmE/ob
XLezyV5/CShtri34m5mauzsg7rih/tOQ5iYkqV/kcIvEqq9HeJQRteWHSkNSO4Df
VX0FWGClPVBLT+kzlWXT1t6yswe1Cdo/KQeNBISbp7SbGX/ZhSbR1swbme7I6Iq8
NETOlLa49/aCrfTnpU8c//xxhedgTMyO30qRgUgX7BqniEU0/WJsI156DSedhcVh
DGVm4O54xJ09koguBo/4BP6rs0Vr3TqXzpq0npUYFE0UuxtECHnB6iyd7he/2inf
kn/No2BMDI0D005rxV6i8h1psk8wv6ACwZhX6L6/QjLP2PzM5zxM6VTsWyuUpN1t
cQ5QDZ4QaUaXRszyZ+xd7arJUCWTJkqZifLvB1WCZ0J28Jg5Bbd+fW/HKNlpB9vT
1bwsrTrXoiG+w70gTURjgRDgz9kJAGvHtqQuwe99SiGtaigdZ2ntTeplNjzA+iV6
d4k6nehNbjrrhTDkeV4i7kRFjDQRQn8dX1XrVng3c1w4tJI46J82E1re1dCw9eU5
SqLMMSUwIwYJKoZIhvcNAQkVMRYEFMlOPeNFP3dsXCHkZzNfcbC+SIwiMDEwITAJ
BgUrDgMCGgUABBQ9GTbjyC/z9oi+bg8R3kdod+2+XQQINXgTTMTGIPkCAggA''';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  final storage = const FlutterSecureStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      // Token berhasil didapatkan
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> setStorage() async {
    print("masuk sini");
    await storage.deleteAll();

    String? value = await storage.read(key: "private_key");

    print("==== storage =====");
    print(value);
    print("==== end storage =====");

    if (value == null) {
      print("step 1");
      var data = await RSA.convertPKCS12ToKeyPair(pkcs12, password);
      print("step 2");

      await storage.write(key: "private_key", value: data.privateKey);
      public_key = data.publicKey;

      print("==== PRIVATE KEY =====");
      print(data.privateKey);

      print("==== PUBLIC KEY =====");
      print(data.publicKey);
    }
  }

  void checkvalues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cpassword = _cPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || cpassword.isEmpty) {
      print("Harap isikan semua data yang diminta");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isikan semua data yang diminta'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (password.length < 6) {
      print("Password must be at least 6 characters long");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('kata sandi minimal 6 karakter'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (password != cpassword) {
      print("Passwords do not match");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('kata sandi tidak sama'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      signup(email, password);
    }
  }

  void signup(String email, String password) async {
    await setStorage();
    String? fcmToken = await getFCMToken();
    try {
      String imageUrl = '';
      String telepon = '';
      String nama = '';
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Simpan data Ke Firebase Realtime Database
          DatabaseReference usersRef =
              FirebaseDatabase.instance.ref().child('users');
          usersRef.child(user.uid).set({
            'email': email,
            'uid': user.uid,
            'profilePicture': imageUrl,
            'nama': nama,
            'telepon': telepon,
            'public_key': public_key,
            'fcmToken': fcmToken,
          });

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Verifikasi(
              email: email,
              uid: user.uid,
            ),
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Email sudah terdaftar, coba masuk dengan email tersebut.'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
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
                    labelText: "Email",
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                  ),
                  cursorColor: Colors.blue,
                ),
                SizedBox(
                  height: 15,
                ),
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
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _cPasswordController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: "Konformasi Kata Sandi",
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      child: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  cursorColor: Colors.blue,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          checkvalues();
                        },
                        child: Text(
                          "Daftar",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
                        "Sudah memiliki akun?",
                      ),
                      CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Masuk",
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
