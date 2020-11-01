import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaperplugin/wallpaperplugin.dart';

// ignore: must_be_immutable
class FullScreen extends StatefulWidget {
  String imgPath;
  FullScreen(this.imgPath);

  @override
  _FullScreen createState() => _FullScreen();
}

class _FullScreen extends State<FullScreen> {
  bool downloading = false;
  var downloadtask;

  var progressString = " ";
  var filePath = '';

  final LinearGradient backgroundGradient = LinearGradient(
      colors: [Color(0x10000000), Color(0x30000000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);

  Future<void> downloadFile() async {
    final status = await Permission.storage.request();
    var dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    print('dir:$dir');
    var imageName = widget.imgPath.split('/').last;
    imageName = imageName.split('?').first;
    print('imagename: $imageName');

    print('path: $dir/$imageName');
    if (status.isGranted) {
      final id = await FlutterDownloader.enqueue(
          url: widget.imgPath,
          savedDir: dir,
          fileName: '$imageName',
          showNotification: true,
          openFileFromNotification: true);
      downloadtask = 'Done';
    } else {
      print('Permission denied');
    }
    return downloadtask;
  }

  Future<void> setWallpaper() async {
    downloading = true;
    final status = await Permission.storage.request();
    var dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    print('dir:$dir');
    var imageName = widget.imgPath.split('/').last;
    imageName = imageName.split('?').first;
    print('imagename: $imageName');

    print('path: $dir/$imageName');
    if (status.isGranted) {
      final id = await FlutterDownloader.enqueue(
          url: widget.imgPath,
          savedDir: dir,
          fileName: '$imageName',
          showNotification: false,
          openFileFromNotification: false);
      progressString = 'Completed';

      setState(() {
        filePath = '$dir/$imageName';
        downloading = false;
      });
      Wallpaperplugin.setAutoWallpaper(localFile: filePath);
      Navigator.pop(context);
    } else {
      print('Permission denied');
    }
    // Navigator.pop(context);
  }

  ontapProgress(context, values) {
    return AlertDialog(
      title: Text('Set as Wallpaper'),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No')),
        FlatButton(
            onPressed: () {
              setWallpaper();
            },
            child: Text('Yes')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ontapProgress(context, widget.imgPath),
                        );
                      },
                      child: Text(
                        'walpaper',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
