import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/pages/chat_page/room_chat.dart';
import 'package:whoru/src/widgets/loading.dart';

class MatchRoom extends StatefulWidget {
  final String roomID;
  final index;

  MatchRoom({this.roomID, this.index});

  @override
  State<StatefulWidget> createState() => _MatchRoomState();
}

class _MatchRoomState extends State<MatchRoom> {
  int time;
  Timer timer;
  bool loading = false;
  String roomID = '';

  List<String> agesRange = [
    '16-20',
    '18-22',
    '20-24',
    '22-26',
    '24-28',
    '26-30',
    '28-32',
    '30-34',
    '32-36',
    '34-38',
    '36-40',
    '40+'
  ];

  List<String> myRange = new List();

  void setMyRange(int age, bool male) {
    if (age < 18) {
      myRange.add(agesRange[0]);
    } else if (age < 20) {
      if (male) {
        myRange.add(agesRange[0]);
        myRange.add(agesRange[1]);
      } else {
        myRange.add(agesRange[1]);
        myRange.add(agesRange[0]);
      }
    } else if (age < 22) {
      if (male) {
        myRange.add(agesRange[1]);
        myRange.add(agesRange[2]);
      } else {
        myRange.add(agesRange[2]);
        myRange.add(agesRange[1]);
      }
    } else if (age < 24) {
      if (male) {
        myRange.add(agesRange[2]);
        myRange.add(agesRange[3]);
      } else {
        myRange.add(agesRange[3]);
        myRange.add(agesRange[2]);
      }
    } else if (age < 26) {
      if (male) {
        myRange.add(agesRange[3]);
        myRange.add(agesRange[4]);
      } else {
        myRange.add(agesRange[4]);
        myRange.add(agesRange[3]);
      }
    } else if (age < 28) {
      if (male) {
        myRange.add(agesRange[4]);
        myRange.add(agesRange[5]);
      } else {
        myRange.add(agesRange[5]);
        myRange.add(agesRange[4]);
      }
    } else if (age < 30) {
      if (male) {
        myRange.add(agesRange[5]);
        myRange.add(agesRange[6]);
      } else {
        myRange.add(agesRange[6]);
        myRange.add(agesRange[5]);
      }
    } else if (age < 32) {
      if (male) {
        myRange.add(agesRange[6]);
        myRange.add(agesRange[7]);
      } else {
        myRange.add(agesRange[7]);
        myRange.add(agesRange[6]);
      }
    } else if (age < 34) {
      if (male) {
        myRange.add(agesRange[7]);
        myRange.add(agesRange[8]);
      } else {
        myRange.add(agesRange[8]);
        myRange.add(agesRange[7]);
      }
    } else if (age < 36) {
      if (male) {
        myRange.add(agesRange[8]);
        myRange.add(agesRange[9]);
      } else {
        myRange.add(agesRange[9]);
        myRange.add(agesRange[8]);
      }
    } else if (age < 38) {
      if (male) {
        myRange.add(agesRange[9]);
        myRange.add(agesRange[10]);
      } else {
        myRange.add(agesRange[10]);
        myRange.add(agesRange[9]);
      }
    } else if (age < 40) {
      myRange.add(agesRange[10]);
    } else {
      myRange.add(agesRange[11]);
    }
  }

  startTimer() {
    time = 7;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        time = time - 1;
        if (time == 4) {
          loading = true;
        }
      });
    });
  }

  Future<void> _updateRoom(roomID) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(widget.index, {'room': roomID});
    });
  }

  Future<void> _updateStateRoom(index, uid, roomID) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(index, {
        'user2': uid,
        'id2': uid,
        'save1': true,
        'save2': true,
        'noti1': true,
        'noti2': true,
      });
    });
  }

  Future<void> _createRoom(
      uid, roomID, now, hashtag, location, male, range) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference =
          Firestore.instance.collection("chatrooms");
      await reference.add({
        'room': roomID,
        'user1': uid,
        'user2': 'wait',
        'publishAt': now,
        'hashtag': hashtag,
        'male': !male,
        'location': location,
        'save1': false,
        'save2': false,
        'id1': uid,
        'id2': uid,
        'noti1': false,
        'noti2': false,
        'name1': '',
        'name2': '',
        'range': range,
        'color': Colors.blueAccent.value.toString(),
        'publish1': DateTime.now(),
        'publish2': DateTime.now(),
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (time == 0) {
      timer.cancel();
    }

    if (widget.roomID.length != 0) {
      timer.cancel();
    }

    return widget.roomID.length == 0
        ? StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .where('id', isEqualTo: user.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              String hashtag = snapshot.data.documents[0]['hashtag'];
              String location = snapshot.data.documents[0]['location'];
              int age = snapshot.data.documents[0]['age'];
              bool male = snapshot.data.documents[0]['male'];
              setMyRange(age, male);

              return StreamBuilder(
                stream: Firestore.instance
                    .collection('blacklist')
                    .where('id', isEqualTo: user.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot1) {
                  if (!snapshot1.hasData) {
                    return Loading();
                  }

                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection('blacklist')
                        .where('idBan', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot2) {
                      if (!snapshot2.hasData) {
                        return Loading();
                      }

                      List<DocumentSnapshot> idBan1 = snapshot1.data.documents;
                      List<DocumentSnapshot> idBan2 = snapshot2.data.documents;

                      return hashtag == '#Talk'
                          ? _talk(context, user, hashtag, location, male,
                              idBan1, idBan2)
                          : hashtag == '#LGBT'
                              ? _lgbt(context, user, hashtag, location, male,
                                  idBan1, idBan2)
                              : _love(context, user, hashtag, location, male,
                                  idBan1, idBan2);
                    },
                  );
                },
              );
            },
          )
        : RoomChat(
            roomID: widget.roomID,
            name: 'Stranger',
            index: widget.index,
            type: 'Stranger',
          );
  }

  Widget _talk(context, User user, hashtag, location, male,
      List<DocumentSnapshot> idBan1, List<DocumentSnapshot> idBan2) {
    List<String> range = myRange;

    return range.length == 1
        ? StreamBuilder(
            stream: Firestore.instance
                .collection('chatrooms')
                .where('user2', isEqualTo: 'wait')
                .where('hashtag', isEqualTo: hashtag)
                .where('range', isEqualTo: range[0])
                .orderBy('publishAt', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              List<DocumentSnapshot> documents = snapshot.data.documents;

              if (loading) {
                for (int i = 0; i < documents.length; i++) {
                  for (int j = 0; j < idBan1.length; j++) {
                    if (documents[i]['id1'] == idBan1[j]['idBan']) {
                      documents.removeAt(i);
                    }
                  }
                }

                for (int i = 0; i < documents.length; i++) {
                  for (int j = 0; j < idBan2.length; j++) {
                    if (documents[i]['id1'] == idBan2[j]['id']) {
                      documents.removeAt(i);
                    }
                  }
                }

                int length = documents.length;

                if (length == 0) {
                  DateTime now = DateTime.now();
                  roomID = user.uid + now.toString();
                  _createRoom(
                      user.uid, roomID, now, hashtag, location, male, range[0]);
                } else {
                  roomID = documents[0]['room'];
                  _updateStateRoom(documents[0].reference, user.uid, roomID);
                }
                _updateRoom(roomID);
                loading = false;
              }

              return time == 0
                  ? RoomChat(
                      roomID: roomID,
                      name: 'Stranger',
                      index: widget.index,
                      type: 'Stranger',
                    )
                  : Loading();
            },
          )
        : StreamBuilder(
            stream: Firestore.instance
                .collection('chatrooms')
                .where('user2', isEqualTo: 'wait')
                .where('hashtag', isEqualTo: hashtag)
                .where('range', isEqualTo: range[0])
                .orderBy('publishAt', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              return StreamBuilder(
                stream: Firestore.instance
                    .collection('chatrooms')
                    .where('user2', isEqualTo: 'wait')
                    .where('hashtag', isEqualTo: hashtag)
                    .where('range', isEqualTo: range[0])
                    .orderBy('publishAt', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot1) {
                  if (!snapshot1.hasData) {
                    return Loading();
                  }

                  List<DocumentSnapshot> documents = snapshot.data.documents;
                  documents.addAll(snapshot1.data.documents);

                  if (loading) {
                    for (int i = 0; i < documents.length; i++) {
                      for (int j = 0; j < idBan1.length; j++) {
                        if (documents[i]['id1'] == idBan1[j]['idBan']) {
                          documents.removeAt(i);
                        }
                      }
                      for (int j = 0; j < idBan2.length; j++) {
                        if (documents[i]['id1'] == idBan2[j]['id']) {
                          documents.removeAt(i);
                        }
                      }
                    }

                    if (documents.length == 0) {
                      DateTime now = DateTime.now();
                      roomID = user.uid + now.toString();
                      _createRoom(user.uid, roomID, now, hashtag, location,
                          male, range[0]);
                    } else {
                      roomID = documents[0]['room'];
                      _updateStateRoom(
                          documents[0].reference, user.uid, roomID);
                    }
                    _updateRoom(roomID);
                    loading = false;
                  }

                  return time == 0
                      ? RoomChat(
                          roomID: roomID,
                          name: 'Stranger',
                          index: widget.index,
                          type: 'Stranger',
                        )
                      : Loading();
                },
              );
            },
          );
  }

  Widget _love(context, User user, hashtag, location, male,
      List<DocumentSnapshot> idBan1, List<DocumentSnapshot> idBan2) {
    List<String> range = myRange;

    return range.length == 1
        ? StreamBuilder(
            stream: Firestore.instance
                .collection('chatrooms')
                .where('user2', isEqualTo: 'wait')
                .where('hashtag', isEqualTo: hashtag)
                .where('male', isEqualTo: male)
                .where('range', isEqualTo: range[0])
                .where('location', isEqualTo: location)
                .orderBy('publishAt', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              List<DocumentSnapshot> documents = snapshot.data.documents;

              if (loading) {
                for (int i = 0; i < documents.length; i++) {
                  for (int j = 0; j < idBan1.length; j++) {
                    if (documents[i]['id1'] == idBan1[j]['idBan']) {
                      documents.removeAt(i);
                    }
                  }
                }

                for (int i = 0; i < documents.length; i++) {
                  for (int j = 0; j < idBan2.length; j++) {
                    if (documents[i]['id1'] == idBan2[j]['id']) {
                      documents.removeAt(i);
                    }
                  }
                }

                int length = documents.length;

                if (length == 0) {
                  DateTime now = DateTime.now();
                  roomID = user.uid + now.toString();
                  _createRoom(
                      user.uid, roomID, now, hashtag, location, male, range[0]);
                } else {
                  roomID = documents[0]['room'];
                  _updateStateRoom(documents[0].reference, user.uid, roomID);
                }
                _updateRoom(roomID);
                loading = false;
              }

              return time == 0
                  ? RoomChat(
                      roomID: roomID,
                      name: 'Stranger',
                      index: widget.index,
                      type: 'Stranger',
                    )
                  : Loading();
            },
          )
        : StreamBuilder(
            stream: Firestore.instance
                .collection('chatrooms')
                .where('user2', isEqualTo: 'wait')
                .where('hashtag', isEqualTo: hashtag)
                .where('male', isEqualTo: male)
                .where('range', isEqualTo: range[0])
                .where('location', isEqualTo: location)
                .orderBy('publishAt', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              return StreamBuilder(
                stream: Firestore.instance
                    .collection('chatrooms')
                    .where('user2', isEqualTo: 'wait')
                    .where('hashtag', isEqualTo: hashtag)
                    .where('male', isEqualTo: male)
                    .where('range', isEqualTo: range[1])
                    .where('location', isEqualTo: location)
                    .orderBy('publishAt', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot1) {
                  if (!snapshot1.hasData) {
                    return Loading();
                  }

                  List<DocumentSnapshot> documents = snapshot.data.documents;
                  documents.addAll(snapshot1.data.documents);

                  if (loading) {
                    for (int i = 0; i < documents.length; i++) {
                      for (int j = 0; j < idBan1.length; j++) {
                        if (documents[i]['id1'] == idBan1[j]['idBan']) {
                          documents.removeAt(i);
                        }
                      }
                      for (int j = 0; j < idBan2.length; j++) {
                        if (documents[i]['id1'] == idBan2[j]['id']) {
                          documents.removeAt(i);
                        }
                      }
                    }

                    if (documents.length == 0) {
                      DateTime now = DateTime.now();
                      roomID = user.uid + now.toString();
                      _createRoom(user.uid, roomID, now, hashtag, location,
                          male, range[0]);
                    } else {
                      roomID = documents[0]['room'];
                      _updateStateRoom(
                          documents[0].reference, user.uid, roomID);
                    }
                    _updateRoom(roomID);
                    loading = false;
                  }

                  return time == 0
                      ? RoomChat(
                          roomID: roomID,
                          name: 'Stranger',
                          index: widget.index,
                          type: 'Stranger',
                        )
                      : Loading();
                },
              );
            },
          );
  }

  Widget _lgbt(context, User user, hashtag, location, male,
      List<DocumentSnapshot> idBan1, List<DocumentSnapshot> idBan2) {
    List<String> range = myRange;

    return range.length == 1
        ? StreamBuilder(
            stream: Firestore.instance
                .collection('chatrooms')
                .where('user2', isEqualTo: 'wait')
                .where('hashtag', isEqualTo: hashtag)
                .where('male', isEqualTo: !male)
                .where('range', isEqualTo: range[0])
                .where('location', isEqualTo: location)
                .orderBy('publishAt', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              List<DocumentSnapshot> documents = snapshot.data.documents;

              if (loading) {
                for (int i = 0; i < documents.length; i++) {
                  for (int j = 0; j < idBan1.length; j++) {
                    if (documents[i]['id1'] == idBan1[j]['idBan']) {
                      documents.removeAt(i);
                    }
                  }
                }

                for (int i = 0; i < documents.length; i++) {
                  for (int j = 0; j < idBan2.length; j++) {
                    if (documents[i]['id1'] == idBan2[j]['id']) {
                      documents.removeAt(i);
                    }
                  }
                }

                int length = documents.length;

                if (length == 0) {
                  DateTime now = DateTime.now();
                  roomID = user.uid + now.toString();
                  _createRoom(
                      user.uid, roomID, now, hashtag, location, male, range[0]);
                } else {
                  roomID = documents[0]['room'];
                  _updateStateRoom(documents[0].reference, user.uid, roomID);
                }
                _updateRoom(roomID);
                loading = false;
              }

              return time == 0
                  ? RoomChat(
                      roomID: roomID,
                      name: 'Stranger',
                      index: widget.index,
                      type: 'Stranger',
                    )
                  : Loading();
            },
          )
        : StreamBuilder(
            stream: Firestore.instance
                .collection('chatrooms')
                .where('user2', isEqualTo: 'wait')
                .where('hashtag', isEqualTo: hashtag)
                .where('male', isEqualTo: !male)
                .where('range', isEqualTo: range[0])
                .where('location', isEqualTo: location)
                .orderBy('publishAt', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }

              return StreamBuilder(
                stream: Firestore.instance
                    .collection('chatrooms')
                    .where('user2', isEqualTo: 'wait')
                    .where('hashtag', isEqualTo: hashtag)
                    .where('male', isEqualTo: !male)
                    .where('range', isEqualTo: range[1])
                    .where('location', isEqualTo: location)
                    .orderBy('publishAt', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot1) {
                  if (!snapshot1.hasData) {
                    return Loading();
                  }

                  List<DocumentSnapshot> documents = snapshot.data.documents;
                  documents.addAll(snapshot1.data.documents);

                  if (loading) {
                    for (int i = 0; i < documents.length; i++) {
                      for (int j = 0; j < idBan1.length; j++) {
                        if (documents[i]['id1'] == idBan1[j]['idBan']) {
                          documents.removeAt(i);
                        }
                      }
                      for (int j = 0; j < idBan2.length; j++) {
                        if (documents[i]['id1'] == idBan2[j]['id']) {
                          documents.removeAt(i);
                        }
                      }
                    }

                    if (documents.length == 0) {
                      DateTime now = DateTime.now();
                      roomID = user.uid + now.toString();
                      _createRoom(user.uid, roomID, now, hashtag, location,
                          male, range[0]);
                    } else {
                      roomID = documents[0]['room'];
                      _updateStateRoom(
                          documents[0].reference, user.uid, roomID);
                    }
                    _updateRoom(roomID);
                    loading = false;
                  }

                  return time == 0
                      ? RoomChat(
                          roomID: roomID,
                          name: 'Stranger',
                          index: widget.index,
                          type: 'Stranger',
                        )
                      : Loading();
                },
              );
            },
          );
  }
}
