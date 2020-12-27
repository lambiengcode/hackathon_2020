import 'dart:ui';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class CourseInfoPage extends StatefulWidget {
  final DocumentSnapshot info;
  CourseInfoPage({this.info});
  @override
  State<StatefulWidget> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

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
    _tabController = new TabController(
      vsync: this,
      length: _pages.length,
      initialIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
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
                          widget.info['urlToImage'],
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
                                widget.info['time'],
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
                                    .where('id', isEqualTo: widget.info['own'])
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                ],
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Divider(
              height: .25,
              thickness: .25,
              color: Colors.grey.shade200,
            ),
            Container(
              height: 60.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:
                        ThemeProvider.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(.04)
                            : Color(0xFFABBAD5),
                    spreadRadius: .8,
                    blurRadius: 1.25,
                    offset: Offset(0, 2.0), // changes position of shadow
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blueAccent.shade400,
                indicatorColor: Colors.blueAccent.shade400,
                unselectedLabelColor: Colors.grey.shade700,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2.5,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _size.width / 24.0,
                  fontFamily: 'Raleway-Bold',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _size.width / 25.0,
                  fontFamily: 'Raleway-Bold',
                ),
                tabs: [
                  Tab(
                    text: 'Documents',
                  ),
                  Tab(
                    text: 'Members',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _pages.map((Widget tab) {
                  return tab;
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
