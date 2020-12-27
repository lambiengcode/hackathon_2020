import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whoru/src/pages/discover_page/widgets/forum_card.dart';

class NoticePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('posts')
              .where('type', isEqualTo: 'notice')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            List<DocumentSnapshot> docs = snapshot.data.documents;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return StreamBuilder(
                  stream: Firestore.instance
                      .collection('contents')
                      .where('post', isEqualTo: docs[index]['id'])
                      .orderBy('publishAt', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapContent) {
                    if (!snapContent.hasData) {
                      return Container();
                    }

                    return StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .where('id', isEqualTo: docs[index]['own'])
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapUser) {
                        if (!snapUser.hasData) {
                          return Container();
                        }

                        return ForumCard(
                          info: snapContent.data.documents[0],
                          userInfo: snapUser.data.documents[0],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
