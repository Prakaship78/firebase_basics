import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<DocumentSnapshot> subscription;
  String mytext = null;
  final DocumentReference documentReference =
      FirebaseFirestore.instance.doc('myapp/dummy');
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

  void _add() {
    Map<String, String> data = <String, String>{
      'name': 'Prakash',
      'desc': 'Flutter developer'
    };
    documentReference.set(data).whenComplete(() {
      print('Data added');
    }).catchError((e) => print(e));
  }

  void _update() {
    Map<String, String> data = <String, String>{
      'name': 'Prakash updated',
      'desc': 'Flutter developer updated'
    };
    documentReference.update(data).whenComplete(() {
      print('Data updated');
    }).catchError((e) => print(e));
  }

  void _delete() {
    documentReference.delete().whenComplete(() {
      print('Document deleted');
    }).catchError((e) => print(e));
  }

  void _fetch() {
    documentReference.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          mytext = datasnapshot.data()['desc'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = documentReference.snapshots().listen((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          mytext = datasnapshot.data()['desc'];
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
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
            RaisedButton(
              onPressed: _add,
              child: Text('Add'),
              color: Colors.cyan,
            ),
            RaisedButton(
              onPressed: _update,
              child: Text('Update'),
              color: Colors.lightBlue,
            ),
            RaisedButton(
              onPressed: _delete,
              child: Text('Delete'),
              color: Colors.orange,
            ),
            RaisedButton(
              onPressed: _fetch,
              child: Text('Fetch'),
              color: Colors.lime,
            ),
            mytext == null
                ? Container()
                : Text(
                    mytext,
                    style: TextStyle(fontSize: 20),
                  )
          ],
        ),
      ),
    );
  }
}
