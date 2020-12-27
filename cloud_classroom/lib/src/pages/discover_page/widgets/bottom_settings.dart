import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomSettings extends StatefulWidget {
  final DocumentSnapshot info;
  final index;

  BottomSettings({this.info, this.index});

  @override
  State<StatefulWidget> createState() => _BottomSettingsState();
}

class _BottomSettingsState extends State<BottomSettings> {
  String hashtag = '#Talk';
  bool notifications = false;

  List<String> hashtags = [
    '#Talk',
    '#Love',
    '#18+',
    '#LGBT',
  ];

  @override
  void initState() {
    super.initState();
    hashtag = widget.info['hashtag'];
    notifications = widget.info['notifications_stranger'];
  }

  Future<void> _updateStateRoom(hashtag, notifications) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(widget.index, {
        'hashtag': hashtag,
        'notifications_stranger': notifications,
      });
    });
    Navigator.of(context).pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            8.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                "Choose strangers to",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: sizeWidth / 24.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade400,
              thickness: .25,
              height: .25,
              indent: 20.0,
              endIndent: 20.0,
            ),
            SizedBox(
              height: 12.0,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16.0, right: 12.0),
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeProvider.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.white.withOpacity(.04)
                              : Color(0xFFABBAD5),
                          spreadRadius: .8,
                          blurRadius: 2.0,
                          offset: Offset(0, 2.0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField(
                        icon: Icon(
                          FontAwesomeIcons.hashtag,
                          size: sizeWidth / 20,
                          color: Colors.grey.shade700,
                        ),
                        iconEnabledColor: Colors.grey.shade800,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        value: hashtag,
                        items: hashtags.map((size) {
                          return DropdownMenuItem(
                              value: size,
                              child: Text(
                                size.substring(1),
                                style: TextStyle(
                                  fontSize: sizeWidth / 24,
                                  color: Colors.grey.shade800,
                                ),
                              ));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            hashtag = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      notifications = !notifications;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                      14.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeProvider.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.white.withOpacity(.04)
                              : Color(0xFFABBAD5),
                          spreadRadius: .8,
                          blurRadius: 2.0,
                          offset: Offset(0, 2.0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Icon(
                      notifications
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: notifications
                          ? Colors.blueAccent
                          : Colors.grey.shade600,
                      size: sizeWidth / 18.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16.0,
                ),
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            Divider(
              color: Colors.grey.shade400,
              thickness: .25,
              height: .25,
              indent: 20.0,
              endIndent: 20.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () async {
                        await _updateStateRoom(
                          hashtag,
                          notifications,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeProvider.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(.04)
                                  : Colors.black26,
                              spreadRadius: .8,
                              blurRadius: 2.0,
                              offset:
                                  Offset(0, 2.0), // changes position of shadow
                            ),
                          ],
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
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
