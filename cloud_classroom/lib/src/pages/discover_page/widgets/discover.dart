import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/models/discover.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/pages/discover_page/widgets/bottom_settings.dart';
import 'package:whoru/src/pages/discover_page/widgets/history_page.dart';
import 'package:whoru/src/services/algorithm_stranger.dart';
import 'package:whoru/src/utils/constants.dart';

class Discover extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return _buildContainerDefault(context);
        }

        return _buildContainerDone(
          context,
          snapshot.data.documents[0].reference,
          snapshot.data.documents[0],
        );
      },
    );
  }
}

Widget _buildContainerDefault(context) {
  final Size _size = MediaQuery.of(context).size;

  return Container(
    child: Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              12.0,
              24.0,
              12.0,
              .0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.04)
                      : Color(0xFFABBAD5),
                  spreadRadius: .8,
                  blurRadius: 2.0,
                  offset: Offset(0, 2.0), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: _size.width / 5.8,
                      width: _size.width / 5.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10, width: 0.3),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(discovers[0].image),
                            fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discovers[0].title,
                            style: TextStyle(
                              fontSize: _size.width / 20.0,
                              fontWeight: FontWeight.bold,
                              color: ThemeProvider.of(context).brightness ==
                                      Brightness.dark
                                  ? kLightPrimaryColor
                                  : Colors.blueAccent,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            discovers[0].subTitle,
                            style: TextStyle(
                              fontSize: _size.width / 26,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 4.0,
                    ),
                    _buildActionChat(
                      context,
                      'settings',
                      Feather.settings,
                      null,
                      null,
                      false,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    _buildActionChat(
                      context,
                      'history',
                      Feather.clock,
                      null,
                      null,
                      false,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    _buildActionChat(
                      context,
                      'password',
                      Feather.lock,
                      null,
                      null,
                      false,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    _buildActionChat(
                      context,
                      'find',
                      Feather.search,
                      null,
                      null,
                      false,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 4.0,
                    ),
                    _buildActionCall(
                      context,
                      'chat',
                      Feather.message_square,
                      Colors.blueAccent.shade400,
                      null,
                      null,
                      false,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    _buildActionCall(
                      context,
                      'video',
                      Feather.video,
                      Colors.deepPurple.shade600,
                      null,
                      null,
                      false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.04)
                      : Color(0xFFABBAD5),
                  spreadRadius: .8,
                  blurRadius: 2.0,
                  offset: Offset(0, 2.0), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildContainerDone(context, index, DocumentSnapshot info) {
  final Size _size = MediaQuery.of(context).size;

  return Container(
    child: Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              12.0,
              24.0,
              12.0,
              .0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.04)
                      : Color(0xFFABBAD5),
                  spreadRadius: .8,
                  blurRadius: 2.0,
                  offset: Offset(0, 2.0), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: _size.width / 5.8,
                      width: _size.width / 5.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10, width: 0.3),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(discovers[0].image),
                            fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discovers[0].title,
                            style: TextStyle(
                              fontSize: _size.width / 20.0,
                              fontWeight: FontWeight.bold,
                              color: ThemeProvider.of(context).brightness ==
                                      Brightness.dark
                                  ? kLightPrimaryColor
                                  : Colors.blueAccent,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            discovers[0].subTitle,
                            style: TextStyle(
                              fontSize: _size.width / 26,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 4.0,
                    ),
                    _buildActionChat(
                      context,
                      'settings',
                      Feather.settings,
                      index,
                      info,
                      true,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    _buildActionChat(
                      context,
                      'history',
                      Feather.clock,
                      index,
                      info,
                      true,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    _buildActionChat(
                      context,
                      'password',
                      Feather.lock,
                      index,
                      info,
                      true,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    _buildActionChat(
                      context,
                      'find',
                      Feather.search,
                      index,
                      info,
                      true,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 4.0,
                    ),
                    _buildActionCall(
                      context,
                      'chat',
                      Feather.message_square,
                      Color(0xFF4D648D),
                      index,
                      info,
                      true,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    _buildActionCall(
                      context,
                      'call',
                      Feather.phone_call,
                      Color(0xFF50C878),
                      index,
                      info,
                      true,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    _buildActionCall(
                      context,
                      'video',
                      Feather.video,
                      Colors.blueAccent,
                      index,
                      info,
                      true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.04)
                      : Color(0xFFABBAD5),
                  spreadRadius: .8,
                  blurRadius: 2.0,
                  offset: Offset(0, 2.0), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionChat(
  context,
  title,
  icon,
  index,
  DocumentSnapshot info,
  done,
) {
  void showCustomBottomSheet(hashtag, index) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return BottomSettings(
          info: info,
          index: index,
        );
      },
    );
  }

  return Expanded(
    child: GestureDetector(
      onTap: () {
        if (done) {
          switch (title) {
            case 'settings':
              showCustomBottomSheet(info['hashtag'], index);
              break;
            case 'history':
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HistoryPage(
                    index: index,
                    info: info,
                  ),
                ),
              );
              break;
            case 'password':
              break;
            case 'find':
              break;
            default:
              break;
          }
        }
      },
      child: Container(
        height: 45.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            4.0,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeProvider.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(.04)
                  : Color(0xFFABBAD5),
              spreadRadius: 1.15,
              blurRadius: 1.25,
              offset: Offset(0, 2.0), // changes position of shadow
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.grey.shade900,
          size: 18.8,
        ),
      ),
    ),
  );
}

Widget _buildActionCall(
  context,
  title,
  icon,
  color,
  index,
  DocumentSnapshot info,
  done,
) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        if (done) {
          switch (title) {
            case 'chat':
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MatchRoom(
                    index: index,
                    roomID: info['room'],
                  ),
                ),
              );
              break;
            case 'video':
              break;
            default:
              break;
          }
        }
      },
      child: Container(
        height: 45.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            4.0,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeProvider.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(.04)
                  : Color(0xFFABBAD5),
              spreadRadius: 1.0,
              blurRadius: 1.25,
              offset: Offset(0, 2.0), // changes position of shadow
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    ),
  );
}
