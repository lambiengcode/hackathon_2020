import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snack.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/pages/chat_page/widgets/course_info.dart';
import 'package:whoru/src/pages/chat_page/widgets/deadlines_page.dart';
import 'package:whoru/src/utils/constants.dart';
import 'package:whoru/src/widgets/bookmark_bottomsheet.dart';

import '../../models/user.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: .0,
        brightness: ThemeProvider.of(context).brightness,
        centerTitle: false,
        title: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .where('id', isEqualTo: user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            String urlToImage = snapshot.data.documents[0]['urlToImage'];
            String username = snapshot.data.documents[0]['username'];

            return Row(
              children: [
                CircleAvatar(
                  radius: _size.width / 18.0,
                  backgroundColor: Colors.grey.shade200,
                  child: CircleAvatar(
                    backgroundImage: urlToImage == ''
                        ? AssetImage('images/logo.png')
                        : NetworkImage(urlToImage),
                    radius: 16.5,
                  ),
                ),
                SizedBox(
                  width: 6.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hey, ',
                        style: TextStyle(
                          fontSize: _size.width / 18.0,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Lobster',
                        ),
                      ),
                      TextSpan(
                        text: username,
                        style: TextStyle(
                          fontSize: _size.width / 20.5,
                          color: Colors.blueAccent.shade700,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Feather.search,
              size: _size.width / 15.2,
              color: ThemeProvider.of(context).brightness == Brightness.dark
                  ? kLightPrimaryColor
                  : kDarkPrimaryColor,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 6.0,
          ),
        ],
      ),
      body: _buildMain(context),
    );
  }

  Widget _buildMain(context) {
    final Size _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16.0,
            ),
            Row(
              children: [
                SizedBox(
                  width: 2.5,
                ),
                _buildQuickAccess(
                    context, 'Bookmark', Feather.bookmark, Colors.blueAccent),
                SizedBox(
                  width: 16.0,
                ),
                _buildQuickAccess(context, 'File', Feather.file_text,
                    Colors.blueGrey.shade800),
                SizedBox(
                  width: 16.0,
                ),
                _buildQuickAccess(context, 'Todo', Feather.edit, Colors.indigo),
                SizedBox(
                  width: 16.0,
                ),
                _buildQuickAccess(context, 'Trash', Feather.trash,
                    Colors.deepPurple.shade800),
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 2.5),
                  child: Text(
                    'Deadlines',
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: _size.width / 16.8,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Raleway-Bold",
                    ),
                  ),
                ),
                Icon(
                  Feather.maximize_2,
                  size: _size.width / 16.5,
                  color: Colors.blueAccent,
                ),
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              height: _size.height * .3,
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('deadlines')
                    .where('members', arrayContains: user.uid)
                    .orderBy('closeAt', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                        stream: Firestore.instance
                            .collection('courses')
                            .where('id', isEqualTo: docs[index]['course'])
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snaps) {
                          if (!snaps.hasData) {
                            return Container();
                          }

                          return _buildDeadlines(
                            context,
                            docs[index],
                            snaps.data.documents[0],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 2.5),
                  child: Text(
                    'My Courses',
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: _size.width / 16.8,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Raleway-Bold",
                    ),
                  ),
                ),
                Icon(
                  Feather.maximize_2,
                  size: _size.width / 16.5,
                  color: Colors.blueAccent,
                ),
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              height: _size.height * .3,
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('courses')
                    .where('members', arrayContains: user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return _buildCourse(
                        context,
                        snapshot.data.documents[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(
    context,
    title,
    icon,
    color,
  ) {
    void showSaveBottomSheet() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return BookmarkBottomSheet(
              idPost: '',
            );
          });
    }

    final _size = MediaQuery.of(context).size;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          switch (title) {
            case 'Bookmark':
              showSaveBottomSheet();
              break;
            default:
              Get.snackbar(
                '',
                '',
                colorText: Colors.white,
                backgroundColor: Colors.black45,
                dismissDirection: SnackDismissDirection.HORIZONTAL,
                duration: Duration(
                  milliseconds: 2000,
                ),
                titleText: Text(
                  'Comming Soon!',
                  style: TextStyle(
                    fontSize: _size.width / 24.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                messageText: Text(
                  'This feature will available in next version.',
                  style: TextStyle(
                    fontSize: _size.width / 26.0,
                    color: Colors.white.withOpacity(.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  20.0,
                  8.0,
                  18.0,
                ),
              );
              break;
          }
        },
        child: Container(
          height: 50.0,
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
            color: color,
            size: 18.8,
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlines(
      context, DocumentSnapshot info, DocumentSnapshot course) {
    final Size _size = MediaQuery.of(context).size;
    var dateTime = DateTime.now();
    var mathTime = '';
    Timestamp publishAt = info['closeAt'];
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
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeadlinesPage(
            info: info,
            infoCourse: course,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          right: 8.0,
          top: 4.0,
          bottom: 8.0,
          left: 4.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 6.0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 6.0,
            ),
            Container(
              height: 100.0,
              width: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  6.0,
                ),
                image: DecorationImage(
                  image: course['urlToImage'] == ''
                      ? AssetImage('images/logo.png')
                      : NetworkImage(course['urlToImage']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Container(
              width: 135.0,
              padding: EdgeInsets.symmetric(
                horizontal: 2.8,
              ),
              child: Text(
                info['title'],
                style: TextStyle(
                  fontSize: _size.width / 22.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              width: 150.0,
              padding: EdgeInsets.symmetric(
                horizontal: 2.8,
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Course: ',
                      style: TextStyle(
                        fontSize: _size.width / 26.0,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: course['title'],
                      style: TextStyle(
                        fontSize: _size.width / 26.0,
                        color: Colors.blueAccent.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 6.0,
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
          ],
        ),
      ),
    );
  }

  Widget _buildCourse(context, DocumentSnapshot info) {
    final Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CourseInfoPage(
            info: info,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          right: 12.0,
          top: 4.0,
          bottom: 8.0,
          left: 4.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 6.0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 6.0,
            ),
            Container(
              height: 110.0,
              width: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  6.0,
                ),
                image: DecorationImage(
                  image: info['urlToImage'] == ''
                      ? AssetImage('images/logo.png')
                      : NetworkImage(info['urlToImage']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              width: 150.0,
              padding: EdgeInsets.symmetric(
                horizontal: 2.8,
              ),
              child: Text(
                info['title'],
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: _size.width / 25.0,
                  fontWeight: FontWeight.bold,
                ),
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
                  Feather.calendar,
                  size: _size.width / 25.5,
                  color: Colors.deepPurple.shade700,
                ),
                SizedBox(
                  width: 6.0,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 2.0,
                  ),
                  child: Text(
                    info['time'],
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontSize: _size.width / 28.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 2.5,
                ),
                Icon(
                  Feather.user,
                  size: _size.width / 25.5,
                  color: Colors.blueGrey.shade800,
                ),
                SizedBox(
                  width: 6.0,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 5.0,
                  ),
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .where('id', isEqualTo: info['own'])
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'Teacher',
                          style: TextStyle(
                            color: Colors.blueGrey.shade800,
                            fontSize: _size.width / 28.0,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }

                      return Text(
                        snapshot.data.documents[0]['username'],
                        style: TextStyle(
                          color: Colors.blueGrey.shade800,
                          fontSize: _size.width / 28.0,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
