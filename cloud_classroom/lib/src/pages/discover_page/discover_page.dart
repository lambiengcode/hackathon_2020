import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/pages/discover_page/widgets/forum_page.dart';
import 'package:whoru/src/pages/discover_page/widgets/meeting_page.dart';
import 'package:whoru/src/pages/discover_page/widgets/notice_page.dart';
import 'package:whoru/src/utils/constants.dart';

class DiscoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<Widget> _pages = [
    NoticePage(),
    ForumPage(),
    MeetingPage(),
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
    final Size _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        brightness: ThemeProvider.of(context).brightness,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('id', isEqualTo: user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                String urlToImage = snapshot.data.documents[0]['urlToImage'];

                return CircleAvatar(
                  radius: _size.width / 18.0,
                  backgroundColor: Colors.grey.shade200,
                  child: CircleAvatar(
                    backgroundImage: urlToImage == ''
                        ? AssetImage('images/logo.png')
                        : NetworkImage(urlToImage),
                    radius: 16.0,
                  ),
                );
              },
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeProvider.of(context).brightness ==
                                Brightness.dark
                            ? Colors.white.withOpacity(.04)
                            : Color(0xFFABBAD5),
                        spreadRadius: .5,
                        blurRadius: 1.25,
                        offset: Offset(0, 1.5), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    left: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Feather.search,
                        size: _size.width / 22.0,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: _size.width / 25.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.headset,
              size: _size.width / 16.0,
              color: ThemeProvider.of(context).brightness == Brightness.dark
                  ? kLightPrimaryColor
                  : kDarkPrimaryColor,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 4.0,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          indicatorColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey.shade700,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 2.5,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _size.width / 23.5,
            fontFamily: 'Raleway-Bold',
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _size.width / 25.0,
            fontFamily: 'Raleway-Bold',
          ),
          tabs: [
            Tab(
              text: 'Notice',
            ),
            Tab(
              text: 'Forum',
            ),
            Tab(
              text: 'Meeting',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pages.map((Widget tab) {
          return tab;
        }).toList(),
      ),
    );
  }
}
