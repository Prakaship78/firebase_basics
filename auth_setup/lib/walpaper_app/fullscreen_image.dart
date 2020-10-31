import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImagePage extends StatefulWidget {
  String imgPath;
  FullScreenImagePage(this.imgPath);

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  bool downloading = false;

  var progressString = " ";

  final LinearGradient backgroundGradient = LinearGradient(
      colors: [Color(0x10000000), Color(0x30000000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);

  Future<void> downloadFile() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Dio dio = Dio();
    // var dir = await getApplicationDocumentsDirectory();
    // use external download dir to save photos
    var dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    var imageName = widget.imgPath.split('/').last;
    imageName = imageName.split('?').first;
    print(imageName);
    try {
      await dio.download(
        widget.imgPath,
        '$dir/$imageName',
        onReceiveProgress: (rec, total) {
          // print('Receive: $rec , Total: $total');
          setState(() {
            progressString = ((rec / total) * 100).toStringAsFixed(0) + '%';
          });
        },
      );
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = "Completed";
    });
    print('Download Complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: downloading
          ? Center(
              child: Container(
                height: 120,
                width: 250,
                child: Card(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Downloading File: $progressString',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            )
          : SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(gradient: backgroundGradient),
                child: Stack(
                  children: [
                    Hero(
                      tag: Text(widget.imgPath),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.network(widget.imgPath),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppBar(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            leading: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              downloadFile();
                            },
                            child: Text(
                              'download',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {},
                            child: Text(
                              'share',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {},
                            child: Text(
                              'walpaper',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );

//Onloading function
  }
}
