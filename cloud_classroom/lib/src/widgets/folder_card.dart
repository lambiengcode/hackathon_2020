import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class FolderCard extends StatefulWidget {
  final String name;
  final String idPost;
  final String parent;
  final Timestamp publishAt;
  final index;

  FolderCard({this.name, this.idPost, this.parent, this.publishAt, this.index});

  @override
  State<StatefulWidget> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {
  String mathTime;

  @override
  void initState() {
    super.initState();
    var dateTime = DateTime.now();
    DateTime datePublish = widget.publishAt.toDate();
    int min = dateTime.difference(datePublish).inMinutes;
    if (min < 1) {
      mathTime = "1m";
    } else if (min < 60) {
      if (min == 1) {
        mathTime = "${min}m";
      } else {
        mathTime = "${min}m";
      }
    } else if (min < 1440) {
      if ((min / 60).round() == 1) {
        mathTime = "${(min / 60).round()}h";
      } else {
        mathTime = "${(min / 60).round()}h";
      }
    } else if (min < 10080) {
      if ((min / 1440).round() == 1) {
        mathTime = "${(min / 1440).round()}d";
      } else {
        mathTime = "${(min / 1440).round()}d";
      }
    } else if (min < 524160) {
      if ((min / 10080).round() == 1) {
        mathTime = "${(min / 10080).round()}w";
      } else {
        mathTime = "${(min / 10080).round()}w";
      }
    } else {
      if ((min / 524160).round() == 1) {
        mathTime = "${(min / 524160).round()}y";
      } else {
        mathTime = "${(min / 524160).round()}y";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User>(context);

    Future<void> _add() async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference = Firestore.instance.collection("cloud");
        await reference.add({
          'id': user.uid,
          'idPost': widget.idPost,
          'name': '',
          'library': true,
          'parent': widget.parent,
          'type': 'post',
          'publishAt': DateTime.now(),
        });
      });
    }

    Future<void> _remove(index) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.delete(index);
      });
    }

    Future<void> _updateFolder() async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.update(widget.index, {
          'publishAt': DateTime.now(),
        });
      });
    }

    return StreamBuilder(
      stream: Firestore.instance
          .collection('cloud')
          .where('id', isEqualTo: user.uid)
          .where('library', isEqualTo: true)
          .where('idPost', isEqualTo: widget.idPost)
          .where('parent', isEqualTo: widget.parent)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        int length = snapshot.data.documents.length;

        print(user.uid);

        return GestureDetector(
          onTap: () async {
            if (length == 0) {
              await _updateFolder();
              await _add();
            } else {}
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 8.0),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: length != 0 ? Colors.blueAccent : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(
                color: length != 0 ? Colors.transparent : Colors.grey.shade300,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          StreamBuilder(
                            stream: Firestore.instance
                                .collection('cloud')
                                .where('id', isEqualTo: user.uid)
                                .where('parent', isEqualTo: widget.parent)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot1) {
                              if (!snapshot1.hasData) {
                                return Container(
                                  height: sizeWidth / 6.5,
                                  width: sizeWidth / 6.5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: Icon(
                                    Icons.photo_library,
                                    size: sizeWidth / 12,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              }

                              String idPost;

                              snapshot1.data.documents.length == 0
                                  ? idPost = ''
                                  : idPost =
                                      snapshot1.data.documents[0]['idPost'];

                              return idPost == ''
                                  ? Container(
                                      height: sizeWidth / 6.5,
                                      width: sizeWidth / 6.5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                      child: Icon(
                                        Icons.photo_library,
                                        size: sizeWidth / 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    )
                                  : StreamBuilder(
                                      stream: Firestore.instance
                                          .collection('contents')
                                          .where('post', isEqualTo: idPost)
                                          .orderBy('publishAt',
                                              descending: true)
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot2) {
                                        if (!snapshot2.hasData) {
                                          return Container(
                                            height: sizeWidth / 6.5,
                                            width: sizeWidth / 6.5,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Icon(
                                              Icons.photo_library,
                                              size: sizeWidth / 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          );
                                        }

                                        String urlToImage = snapshot2
                                            .data.documents[0]['urlToImage'];

                                        return urlToImage != ''
                                            ? Container(
                                                height: sizeWidth / 6.5,
                                                width: sizeWidth / 6.5,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4.0)),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        urlToImage),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: sizeWidth / 6.5,
                                                width: sizeWidth / 6.5,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4.0)),
                                                ),
                                                child: Icon(
                                                  Icons.photo_library,
                                                  size: sizeWidth / 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              );
                                      },
                                    );
                            },
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                widget.name,
                                style: TextStyle(
                                  color: length != 0
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                  fontSize: sizeWidth / 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text(
                                'updated about $mathTime ago',
                                style: TextStyle(
                                  color: length != 0
                                      ? Colors.white.withOpacity(.78)
                                      : Colors.grey.shade600,
                                  fontSize: sizeWidth / 30.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    length != 0
                        ? GestureDetector(
                            onTap: () async {
                              await _remove(
                                  snapshot.data.documents[0].reference);
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade100,
                              size: sizeWidth / 16.0,
                            ),
                          )
                        : Container(
                            width: 0.0,
                          ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
