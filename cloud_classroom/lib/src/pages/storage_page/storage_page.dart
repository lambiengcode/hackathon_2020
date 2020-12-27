import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/pages/storage_page/widgets/pie_chart.dart';

import '../../models/user.dart';
import '../../utils/constants.dart';

class StoragePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<double> files = [12.17, 11.15, 10.02, 11.21, 13.83, 14.16, 14.30];
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
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

            return Row(
              children: [
                CircleAvatar(
                  radius: _size.width / 18.0,
                  backgroundColor: Colors.grey.shade300,
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
                Text(
                  'Storage',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: _size.width / 16.8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Feather.plus_circle,
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
      body: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 8.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Daily',
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: _size.width / 16.8,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway-Bold",
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'All: ',
                            style: TextStyle(
                              fontSize: _size.width / 25.0,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: '20 files',
                            style: TextStyle(
                              fontSize: _size.width / 25.0,
                              color: Colors.blueAccent.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: _size.height * .33,
                child: PieChart(
                  files: files,
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Folder',
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: _size.width / 16.8,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway-Bold",
                      ),
                    ),
                    GestureDetector(
                      onTap: () => null,
                      child: Icon(
                        Feather.maximize_2,
                        size: _size.width / 16.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                height: _size.height * .08,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(
                        2.0,
                        4.0,
                        12.0,
                        4.0,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          4.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeProvider.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white.withOpacity(.04)
                                : Color(0xFFABBAD5),
                            spreadRadius: 1.15,
                            blurRadius: 1.25,
                            offset:
                                Offset(0, 2.0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Feather.folder,
                            color: Colors.grey.shade700,
                            size: _size.width / 18.8,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Text(
                              'My Share',
                              style: TextStyle(
                                fontSize: _size.width / 24.5,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bookmark',
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: _size.width / 16.8,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway-Bold",
                      ),
                    ),
                    GestureDetector(
                      onTap: () => null,
                      child: Icon(
                        Feather.maximize_2,
                        size: _size.width / 16.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                height: _size.height * .08,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('cloud')
                      .where('id', isEqualTo: user.uid)
                      .where('parent', isEqualTo: '')
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
                        return _buildBookmark(context, docs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmark(context, DocumentSnapshot info) {
    final _size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.fromLTRB(
        2.0,
        4.0,
        14.0,
        4.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 26.0,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Feather.bookmark,
                color: Colors.grey.shade700,
                size: _size.width / 18.8,
              ),
              SizedBox(
                width: 8.0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  info['name'],
                  style: TextStyle(
                    fontSize: _size.width / 24.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
