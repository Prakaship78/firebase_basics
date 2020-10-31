import 'package:auth_setup/walpaper_app/full_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:async';

class WallScreen extends StatefulWidget {
  @override
  _WallScreenState createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> wallpapers;
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('walpaper');

  @override
  void initState() {
    super.initState();
    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        wallpapers = datasnapshot.docs;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Wallpaper App'),
        ),
        body: wallpapers != null
            ? StaggeredGridView.countBuilder(
                itemCount: wallpapers.length,
                padding: EdgeInsets.all(8),
                crossAxisCount: 4,
                itemBuilder: (context, i) {
                  String imgPath = wallpapers[i].data()['url'];
                  return Material(
                    elevation: 15,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullScreen(imgPath)));
                      },
                      child: Hero(
                        tag: Text(imgPath),
                        child: FadeInImage(
                          image: NetworkImage(imgPath),
                          fit: BoxFit.cover,
                          placeholder: AssetImage('assets/logo.png'),
                        ),
                      ),
                    ),
                  );
                },
                staggeredTileBuilder: (i) =>
                    StaggeredTile.count(2, i.isEven ? 2 : 3),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
