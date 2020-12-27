import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/widgets/folder_card.dart';

import '../models/user.dart';
import '../utils/constants.dart';

class BookmarkBottomSheet extends StatefulWidget {
  final String idPost;

  BookmarkBottomSheet({this.idPost});

  @override
  State<StatefulWidget> createState() => _BookmarkBottomSheetState();
}

class _BookmarkBottomSheetState extends State<BookmarkBottomSheet> {
  bool create = false;
  String folderName = '';

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final sizeHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<User>(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: sizeHeight * 0.62,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
          color: ThemeProvider.of(context).brightness == Brightness.dark
              ? kDarkSecondaryColor
              : kLightSecondaryColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(6.8),
          )),
      child: create
          ? _createFolder(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 18.0,
                    ),
                    Text(
                      'Add this post to a folder',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: sizeWidth / 24.0,
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: .5,
                      height: .5,
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('cloud')
                        .where('id', isEqualTo: user.uid)
                        .where('library', isEqualTo: true)
                        .where('parent', isEqualTo: '')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return FolderCard(
                            name: snapshot.data.documents[index]['name'],
                            publishAt: snapshot.data.documents[index]
                                ['publishAt'],
                            index: snapshot.data.documents[index].reference,
                            parent: snapshot.data.documents[index]['idFolder'],
                            idPost: widget.idPost,
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: .6,
                          ),
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizeWidth / 26.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          create = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 26.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade900,
                            width: .6,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Text(
                          'Create a new folder',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: sizeWidth / 26.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24.0,
                ),
              ],
            ),
    );
  }

  Widget _createFolder(context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User>(context);

    Future<void> _createFol(name) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference = Firestore.instance.collection("cloud");
        await reference.add({
          'id': user.uid,
          'idFolder':
              user.uid + DateTime.now().millisecondsSinceEpoch.toString(),
          'name': name,
          'library': true,
          'parent': '',
          'type': 'folder',
          'publishAt': DateTime.now(),
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 8.0,
              ),
              Text(
                'Create a new folder',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: sizeWidth / 24.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(
                color: Colors.grey.shade500,
                thickness: .45,
                height: .45,
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                child: Material(
                  elevation: 2.2,
                  shadowColor: Color(0xFFABBAD5),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  child: TextFormField(
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: sizeWidth / 26.0,
                      fontWeight: FontWeight.w400,
                    ),
                    validator: (val) =>
                        val.length == 0 ? 'Type folder name' : null,
                    onChanged: (val) => folderName = val.trim(),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 24.0, top: 32.0),
                      hintText: 'New Folder',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: sizeWidth / 26.0,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        create = false;
                        folderName = '';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.grey.shade800,
                        size: sizeWidth / 23.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (folderName.length > 0) {
                        _createFol(folderName);
                      }
                      setState(() {
                        create = false;
                        folderName = '';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 42.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 1.2,
                        ),
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Text(
                        'Create Folder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sizeWidth / 26.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12.0,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
      ],
    );
  }
}
