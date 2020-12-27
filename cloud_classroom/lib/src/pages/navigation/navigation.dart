import 'dart:async';
import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:whoru/src/pages/chat_page/chat_page.dart';
import 'package:whoru/src/pages/profile_page/profile_page.dart';
import 'package:whoru/src/pages/storage_page/storage_page.dart';

import '../discover_page/discover_page.dart';

class Navigation extends StatefulWidget {
  final String uid;
  Navigation({this.uid});
  @override
  State<StatefulWidget> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPage = 0;
  var _pages = [
    ChatPage(),
    DiscoverPage(),
    StoragePage(),
    ProfilePage(),
  ];

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  _saveDeviceToken() async {
    // Get the current user
    String uid = widget.uid;
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _db.collection('users').document(uid);

      await tokens.updateData({
        'token': fcmToken,
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true,
      body: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (i) {
            setState(() {
              currentPage = i;
            });
          },
          type: BottomNavigationBarType.fixed,
          iconSize: _size.width / 14.75,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor:
              ThemeProvider.of(context).brightness == Brightness.dark
                  ? Colors.blueAccent.shade100
                  : Colors.blueAccent.shade400,
          unselectedItemColor:
              ThemeProvider.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade100
                  : Colors.black,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Feather.home), title: Text("Dashboard")),
            BottomNavigationBarItem(
                icon: Icon(Feather.trending_up), title: Text("Feed")),
            BottomNavigationBarItem(
                icon: Icon(Feather.package), title: Text("File")),
            BottomNavigationBarItem(
                icon: Icon(Feather.user), title: Text("Profile")),
          ],
        ),
        body: _pages[currentPage],
      ),
    );
  }
}
