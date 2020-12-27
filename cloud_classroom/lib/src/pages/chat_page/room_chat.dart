import 'dart:async';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/animation/fade_animation.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/pages/chat_page/widgets/build_chat_line.dart';
import 'package:whoru/src/pages/chat_page/widgets/chat_input.dart';
import 'package:whoru/src/services/algorithm_stranger.dart';
import 'package:whoru/src/widgets/photo_viewer.dart';

class RoomChat extends StatefulWidget {
  final String name;
  final String roomID;
  final String type;
  final index;

  RoomChat({this.name, this.roomID, this.index, this.type});

  @override
  State<StatefulWidget> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  String stranger = 'Stranger';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateCurrentRoom(index, num) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(index, {'user$num': 'off'});
    });
  }

  Future<void> _updateCurrentRoom2(index) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(index, {
        'user1': 'off',
        'user2': 'off',
      });
    });
  }

  Future<void> _requestFriend(
    id1,
    id2,
  ) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference =
          Firestore.instance.collection("chatrooms");
      await reference.add({
        'room': id1 + DateTime.now().toString(),
        'user1': id1,
        'user2': id2,
        'publishAt': DateTime.now(),
        'hashtag': '#Request',
        'male': false,
        'location': '',
        'save1': false,
        'save2': false,
        'id1': id1,
        'id2': id2,
        'noti1': false,
        'noti2': false,
        'name1': '',
        'name2': '',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;

    final user = Provider.of<User>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: StreamBuilder(
          stream: Firestore.instance
              .collection('chatrooms')
              .where('room', isEqualTo: widget.roomID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            String user1 = snapshot.data.documents[0]['user1'];
            String user2 = snapshot.data.documents[0]['user2'];
            String id1 = snapshot.data.documents[0]['id1'];
            String id2 = snapshot.data.documents[0]['id2'];

            String status = user1 == user.uid ? user2 : user1;
            String idStranger = user1 == user.uid ? id2 : id1;

            return status == 'wait'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 21.5,
                        backgroundColor: Colors.grey.shade200,
                        child: CircleAvatar(
                          backgroundImage: AssetImage('images/logo.png'),
                          radius: 18.5,
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stranger,
                            style: TextStyle(
                              fontSize: sizeWidth / 23.5,
                              fontWeight: FontWeight.bold,
                              color: ThemeProvider.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Waiting for Stranger',
                            style: TextStyle(
                              fontSize: sizeWidth / 32.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF009D00),
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                : StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .where('id', isEqualTo: idStranger)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot1) {
                      if (!snapshot1.hasData) {
                        return Container();
                      }

                      String username = snapshot1.data.documents[0]['username'];
                      String urlToImage = snapshot1.data.documents[0]['image'];
                      bool active = snapshot1.data.documents[0]['status'];

                      return GestureDetector(
                        onTap: () {
                          if (widget.type == '#Friend') {
                            if (urlToImage != '') {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PhotoViewer(
                                        image: urlToImage,
                                      )));
                            }
                          } else {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            widget.type != '#Friend' || urlToImage == ''
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage('images/logo.png'),
                                    radius: 20.0,
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(urlToImage),
                                    radius: 20.0,
                                  ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.type != '#Friend'
                                      ? stranger
                                      : username,
                                  style: TextStyle(
                                    fontSize: sizeWidth / 23.5,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        ThemeProvider.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade100
                                            : Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  widget.type != '#Friend' && status == 'off'
                                      ? 'Stranger have exited'
                                      : active
                                          ? 'Active now'
                                          : 'inActive',
                                  style: TextStyle(
                                    fontSize: sizeWidth / 32,
                                    fontWeight: FontWeight.w500,
                                    color: widget.type != '#Friend' &&
                                            status == 'off'
                                        ? Colors.red[400]
                                        : active
                                            ? ThemeProvider.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? Color(0xFF00CC66)
                                                : Color(0xFF009D00)
                                            : Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
          },
        ),
        actions: [
          widget.type == stranger
              ? StreamBuilder(
                  stream: Firestore.instance
                      .collection('chatrooms')
                      .where('room', isEqualTo: widget.roomID)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return IconButton(
                        icon: Icon(
                          Feather.more_vertical,
                          color: Colors.blueAccent,
                          size: sizeWidth / 15.0,
                        ),
                        onPressed: () {},
                      );
                    }

                    String color = snapshot.data.documents[0]['color'];

                    return IconButton(
                      icon: Icon(
                        Feather.more_vertical,
                        color: Color(int.parse(color)),
                        size: sizeWidth / 15.0,
                      ),
                      onPressed: () async {
                        String user1 = snapshot.data.documents[0]['user1'];
                        String user2 = snapshot.data.documents[0]['user2'];
                        if (user.uid == user1 && user2 == 'wait') {
                          await _updateCurrentRoom2(
                              snapshot.data.documents[0].reference);
                        } else if (user1 == user.uid) {
                          await _updateCurrentRoom(
                              snapshot.data.documents[0].reference, 1);
                        } else if (user2 == user.uid) {
                          await _updateCurrentRoom(
                              snapshot.data.documents[0].reference, 2);
                        }
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchRoom(
                              roomID: '',
                              index: widget.index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : Container(
                  height: 0.0,
                ),
        ],
        leading: StreamBuilder(
          stream: Firestore.instance
              .collection('chatrooms')
              .where('room', isEqualTo: widget.roomID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return FadeAnimation(
                0.5,
                IconButton(
                  icon: Icon(
                    Feather.arrow_left,
                    color: Colors.blueAccent,
                    size: sizeWidth / 14.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                ),
              );
            }

            String color = snapshot.data.documents[0]['color'];

            return IconButton(
              icon: Icon(
                Feather.arrow_left,
                size: sizeWidth / 14.0,
                color: Color(int.parse(color)),
              ),
              onPressed: () {
                Navigator.of(context).pop(context);
              },
            );
          },
        ),
        elevation: 2.5,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('chatrooms')
              .where('room', isEqualTo: widget.roomID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            String id1 = snapshot.data.documents[0]['id1'];
            String id2 = snapshot.data.documents[0]['id2'];
            bool save1 = snapshot.data.documents[0]['save1'];
            bool save2 = snapshot.data.documents[0]['save2'];
            bool noti1 = snapshot.data.documents[0]['noti1'];
            bool noti2 = snapshot.data.documents[0]['noti2'];
            String color = snapshot.data.documents[0]['color'];

            String idReceive;

            if (id1 == id2) {
              idReceive = '';
            } else if (id1 == user.uid) {
              //user1 is me & user2 is stranger
              if (save2 && noti2) {
                idReceive = id2;
              } else {
                idReceive = '';
              }
            } else {
              if (save1 && noti1) {
                //user2 is me & user1 is stranger
                idReceive = id1;
              } else {
                idReceive = '';
              }
            }
            return Column(
              children: <Widget>[
                Expanded(
                  child: FadeAnimation(
                    .025,
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 4.0,
                        bottom: 8.0,
                        top: 8.0,
                      ),
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('datachatrooms')
                            .where('room', isEqualTo: widget.roomID)
                            .orderBy('publishAt', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(0.0),
                            itemCount: snapshot.data.documents.length,
                            controller: _scrollController,
                            reverse: true,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return BuildChatLine(
                                message: snapshot.data.documents[index]
                                    ['message'],
                                hour: snapshot.data.documents[index]['hour'],
                                min: snapshot.data.documents[index]['min'],
                                isMe: snapshot.data.documents[index]['id'] ==
                                        user.uid
                                    ? true
                                    : false,
                                type: snapshot.data.documents[index]['type'],
                                name: widget.name,
                                seen: snapshot.data.documents[index]['seen'] ==
                                        null
                                    ? true
                                    : snapshot.data.documents[index]['seen'],
                                index: snapshot.data.documents[index].reference,
                                isLast: index == 0 ? true : false,
                                idUser: snapshot.data.documents[index]
                                    ['receiveID'],
                                publishAt: snapshot.data.documents[index]
                                    ['publishAt'],
                                color: int.parse(color),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                ChatInput(
                  roomID: widget.roomID,
                  receiveID: idReceive,
                  index: snapshot.data.documents[0].reference,
                  color: int.parse(color),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
