import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/widgets/loading_upload.dart';

import '../../../models/user.dart';

class DeadlinesPage extends StatefulWidget {
  final DocumentSnapshot info;
  final DocumentSnapshot infoCourse;
  DeadlinesPage({this.info, this.infoCourse});
  @override
  State<StatefulWidget> createState() => _DeadlinesPageState();
}

class _DeadlinesPageState extends State<DeadlinesPage> {
  double _progress;
  bool _isLoading;
  String _fileName;
  String _path;
  Map<String, String> _paths;
  List<String> _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;

  var dateTime = DateTime.now();
  var mathTime = '';

  List<Widget> _pages = [
    Container(
      child: Center(
        child: Text(
          'Empty',
          style: TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    Container(),
  ];

  @override
  void initState() {
    super.initState();

    _pickingType = FileType.any;
    _multiPick = false;
    _extension = [
      'pdf',
      'doc',
      'docx',
      'jpg',
      'png',
      'jpeg',
    ];

    _isLoading = false;
    _progress = 0.0;

    Timestamp publishAt = widget.info['closeAt'];
    DateTime datePublish = publishAt.toDate();
    int min = datePublish.difference(dateTime).inMinutes;
    if (min < 1) {
      mathTime = "1 min";
    } else if (min < 60) {
      if (min == 1) {
        mathTime = "${min} min";
      } else {
        mathTime = "${min} mins";
      }
    } else if (min < 1440) {
      if ((min / 60).round() == 1) {
        mathTime = "${(min / 60).round()} hour";
      } else {
        mathTime = "${(min / 60).round()} hours";
      }
    } else if (min < 10080) {
      if ((min / 1440).round() == 1) {
        mathTime = "${(min / 1440).round()} day";
      } else {
        mathTime = "${(min / 1440).round()} days";
      }
    } else if (min < 524160) {
      if ((min / 10080).round() == 1) {
        mathTime = "${(min / 10080).round()} week";
      } else {
        mathTime = "${(min / 10080).round()} weeks";
      }
    } else {
      if ((min / 524160).round() == 1) {
        mathTime = "${(min / 524160).round()} year";
      } else {
        mathTime = "${(min / 524160).round()} years";
      }
    }
  }

  Future<String> _uploadFile(file, uid) async {
    String fileName = uid + DateTime.now().microsecondsSinceEpoch.toString();
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(uid).child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var downUrl = await taskSnapshot.ref.getDownloadURL();
    StreamSubscription<StorageTaskEvent> listen =
        await uploadTask.events.listen((event) {
      setState(() {
        _isLoading = true;
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
        print(_progress.toString() + 'haha');
      });
    });
    String url = downUrl.toString();
    return url;
  }

  Future<void> _uploadFileToFirestore(uid, file) async {
    Firestore.instance.collection('submits').add({
      'id': uid,
      'publishAt': DateTime.now(),
      'filePath': await _uploadFile(file, uid),
      'deadlines': widget.info['id'],
      'receive': false,
    });
  }

  void _openFileExplorer(uid) async {
    if (_pickingType != FileType.custom || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
            type: _pickingType,
          );
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
            type: _pickingType,
          );
          await _uploadFileToFirestore(
            uid,
            File(_path),
          );
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null
                ? _paths.keys.toString()
                : '...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return _isLoading
        ? LoadingProgess(
            progress: _progress,
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(context),
                icon: Icon(
                  Feather.arrow_left,
                  color: Colors.black,
                  size: _size.width / 14.0,
                ),
              ),
              title: Text(
                widget.info['title'],
                style: TextStyle(
                  fontSize: _size.width / 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(context),
                  icon: Icon(
                    Feather.log_out,
                    color: Colors.black,
                    size: _size.width / 15.0,
                  ),
                ),
              ],
            ),
            body: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.infoCourse['urlToImage'],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.info['title'],
                                style: TextStyle(
                                  fontSize: _size.width / 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text(
                                widget.info['desc'],
                                style: TextStyle(
                                  fontSize: _size.width / 24.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 2.5,
                                  ),
                                  Icon(
                                    Feather.clock,
                                    size: _size.width / 26.0,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(
                                    width: 6.0,
                                  ),
                                  Text(
                                    mathTime,
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: _size.width / 26.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Divider(
                    height: .25,
                    thickness: .25,
                    indent: 16.0,
                    endIndent: 16.0,
                    color: Colors.grey.shade400,
                  ),
                  Expanded(
                    child: Container(
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('submits')
                            .where('id', isEqualTo: user.uid)
                            .where('deadlines', isEqualTo: widget.info['id'])
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          List<DocumentSnapshot> docs = snapshot.data.documents;

                          return docs.length != 0
                              ? _buildFile(context, docs[0])
                              : Center(
                                  child: GestureDetector(
                                    onTap: () => _openFileExplorer(user.uid),
                                    child: Container(
                                      height: 44.0,
                                      width: 130.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeProvider.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? Colors.white.withOpacity(.04)
                                                : Color(0xFFABBAD5),
                                            spreadRadius: .8,
                                            blurRadius: 1.25,
                                            offset: Offset(0,
                                                2.0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Upload File',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: _size.width / 26.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildFile(context, DocumentSnapshot info) {
    Future<void> _remove() async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.delete(info.reference);
      });
    }

    String checkDate(int input) {
      if (input < 10) {
        return '0$input';
      } else {
        return '$input';
      }
    }

    final _size = MediaQuery.of(context).size;
    Timestamp tPublishAt = info['publishAt'];
    var publishAt = tPublishAt.toDate();
    String _publish =
        '${checkDate(publishAt.hour)}:${checkDate(publishAt.minute)}:${checkDate(publishAt.second)} at ' +
            '${checkDate(publishAt.day)}/${checkDate(publishAt.month)}/${checkDate(publishAt.year)}';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.04)
                      : Color(0xFFABBAD5),
                  spreadRadius: .8,
                  blurRadius: 1.25,
                  offset: Offset(0, 2.0), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: AssetImage('images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 12.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted',
                      style: TextStyle(
                        fontSize: _size.width / 22.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Submit At: ',
                            style: TextStyle(
                              fontSize: _size.width / 25.0,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: _publish,
                            style: TextStyle(
                              fontSize: _size.width / 28.0,
                              color: Colors.blueAccent.shade700,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async => await _remove(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Feather.trash,
                          color: Colors.black,
                          size: _size.width / 18.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
