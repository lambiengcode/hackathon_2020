import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentLine extends StatefulWidget {
  final bool isMe;
  final String comment;
  final String idUser;
  final Timestamp publishAt;
  final int reply;

  CommentLine(
      {this.isMe, this.comment, this.idUser, this.publishAt, this.reply});

  @override
  State<StatefulWidget> createState() => _CommentLineState();
}

class _CommentLineState extends State<CommentLine> {
  String time = '';
  String messageState;
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
    final double sizeWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('id', isEqualTo: widget.idUser)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Column(
                  crossAxisAlignment: widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      width:
                          widget.comment.length > 40 ? sizeWidth * .69 : null,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        color: Colors.grey.shade200,
                      ),
                      child: Text(
                        widget.comment,
                        style: TextStyle(
                            fontSize: sizeWidth / 26,
                            color: widget.isMe
                                ? Colors.blueGrey[800]
                                : Colors.black),
                      ),
                      alignment: widget.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: widget.isMe ? 0 : 12,
                          right: widget.isMe ? 12 : 0),
                      child: Text(
                        time,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        String username = snapshot.data.documents[0]['username'];
        String image = snapshot.data.documents[0]['urlToImage'];

        return Container(
          width: sizeWidth,
          margin: EdgeInsets.only(bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: image == ''
                    ? AssetImage('images/avt.jpg')
                    : NetworkImage(image),
                radius: 18.0,
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      overflow: TextOverflow.visible,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$username',
                            style: TextStyle(
                              fontSize: sizeWidth / 23.5,
                              color: Color(0xFF171413),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: '\b\b'),
                          TextSpan(
                            text: widget.comment,
                            style: TextStyle(
                              fontSize: sizeWidth / 24.5,
                              color: Color(0xFF171413),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        StreamBuilder(
                          stream: Firestore.instance
                              .collection('favourite')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                'Like',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: sizeWidth / 26.0,
                                  decoration: TextDecoration.underline,
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: () async {},
                              child: Text(
                                'Liked',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: sizeWidth / 26.0,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Text(
                          'Reply',
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: sizeWidth / 26.0,
                              decoration: TextDecoration.underline),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        StreamBuilder(
                          stream: Firestore.instance
                              .collection('favourite')
                              .where('idPost', isEqualTo: 'widget.idPost')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                '0 likes',
                                style: TextStyle(
                                  fontSize: sizeWidth / 28.8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              );
                            }

                            int length = snapshot.data.documents.length;

                            return Text(
                              '$length likes',
                              style: TextStyle(
                                fontSize: sizeWidth / 28.8,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade800,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
