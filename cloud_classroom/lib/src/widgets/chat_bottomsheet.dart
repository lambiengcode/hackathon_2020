import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/widgets/comment_input.dart';
import 'package:whoru/src/widgets/comment_line.dart';

import '../models/user.dart';

class CommentBottomSheet extends StatefulWidget {
  final String idPost;
  final index;

  CommentBottomSheet({this.idPost, this.index});

  @override
  State<StatefulWidget> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  Future<void> _favourive(uid) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference =
          Firestore.instance.collection("favourite");
      await reference.add({
        'id': uid,
        'idPost': widget.idPost,
      });
    });
  }

  Future<void> _unFavourite(index) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.delete(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;
    final double sizeHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<User>(context);

    return Container(
      height: sizeHeight * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFABBAD5),
                  spreadRadius: .0,
                  blurRadius: 4.0,
                  offset: Offset(0, 1.6), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('favourites')
                        .where('post', isEqualTo: widget.idPost)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          '0',
                          style: TextStyle(
                            fontSize: sizeWidth / 28.8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF605F61),
                          ),
                        );
                      }

                      int length = snapshot.data.documents.length;

                      return RichText(
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$length\t\t',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: sizeWidth / 22.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: 'Liked',
                              style: TextStyle(
                                color: Colors.blueAccent.shade400,
                                fontSize: sizeWidth / 22.5,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder(
                  stream: Firestore.instance
                      .collection('favourites')
                      .where('id', isEqualTo: user.uid)
                      .where('post', isEqualTo: widget.idPost)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return _buildAction(
                        context,
                        widget.idPost,
                        'Favourite',
                        Feather.heart,
                        Colors.grey.shade600,
                        null,
                        false,
                      );
                    }

                    List<DocumentSnapshot> docs = snapshot.data.documents;

                    return _buildAction(
                      context,
                      widget.idPost,
                      'Favourite',
                      Feather.heart,
                      docs.length == 0
                          ? Colors.grey.shade600
                          : Colors.redAccent,
                      docs.length == 0 ? null : docs[0].reference,
                      true,
                    );
                  },
                ),
                SizedBox(
                  width: 12.0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(
                  left: 10.0, right: 12.0, top: 12, bottom: 8.0),
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('comment')
                    .where('idPost', isEqualTo: widget.idPost)
                    .orderBy('publishAt', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(0.0),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CommentLine(
                        comment: snapshot.data.documents[index]['comment'],
                        isMe: snapshot.data.documents[index]['id'] == user.uid
                            ? true
                            : false,
                        publishAt: snapshot.data.documents[index]['publishAt'],
                        reply: snapshot.data.documents[index]['reply'],
                        idUser: snapshot.data.documents[index]['id'],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: CommentInput(
              idPost: widget.idPost,
              index: widget.index,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    context,
    post,
    title,
    icon,
    color,
    index,
    done,
  ) {
    Future<void> _favourite(id, post) async {
      Firestore.instance.collection('favourites').add({
        'id': id,
        'publishAt': DateTime.now(),
        'post': post,
      });
    }

    Future<void> _unFavourite() async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.delete(index);
      });
    }

    final _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);

    return GestureDetector(
      onTap: () {
        if (done) {
          switch (title) {
            case 'Favourite':
              index == null ? _favourite(user.uid, post) : _unFavourite();
              break;
            default:
              break;
          }
        }
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: _size.width / 18.5,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
