import 'package:auth_setup/HomePage.dart';
import 'package:auth_setup/walpaper_app/wall_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter demo app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WallScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User> signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: gSA.idToken, accessToken: gSA.accessToken);
    final UserCredential userCredential =
        await _auth.signInWithCredential(authCredential);
    User user = userCredential.user;
    print(user.displayName);
    return user;
  }

  signOut() async {
    googleSignIn.signOut();
    print('user signed out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RaisedButton(
              onPressed: () => signIn()
                  .then((User user) => print(user))
                  .catchError((e) => print(e)),
              child: Text('Sign In'),
              color: Colors.green,
            ),
            RaisedButton(
              onPressed: () {
                signOut();
              },
              child: Text('Sign Out'),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
