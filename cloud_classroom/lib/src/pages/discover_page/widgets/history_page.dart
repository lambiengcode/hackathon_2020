import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/widgets/loading.dart';

class HistoryPage extends StatefulWidget {
  final index;
  final DocumentSnapshot info;
  HistoryPage({
    this.index,
    this.info,
  });
  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> _hashtags = [];
  List<String> _hashtags0 = ['#All', '#Talk', '#Love', '#LGBT', '#18+'];
  List<String> _hashtags1 = ['#Talk'];
  List<String> _hashtags2 = ['#Love'];
  List<String> _hashtags3 = ['#LGBT'];
  List<String> _hashtags4 = ['#18+'];
  DateTime _fromDate;
  DateTime _toDate;

  String _hashtag;
  String _from;
  String _to;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(Duration(days: 14));
    _from = DateFormat('dd/MM/yyyy').format(_fromDate);
    _to = DateFormat('dd/MM/yyyy').format(_toDate);
    _hashtags.addAll(_hashtags0);
    _hashtag = _hashtags[0];
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      context: context,
      builder: (context) {
        return _filterBottomSheet(context);
      },
    );
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _fromDate,
        firstDate: DateTime(2020, 10),
        lastDate: DateTime.now());
    if (picked != null && picked != _fromDate)
      setState(() {
        if (_toDate.compareTo(picked) != -1) {
          _fromDate = picked;
          _from = DateFormat('dd/MM/yyyy').format(_fromDate);
        }
      });

    Navigator.of(context).pop(context);
    showFilterBottomSheet();
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2020, 10),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate)
      setState(() {
        if (_fromDate.compareTo(picked) != 1) {
          _toDate = picked;
          _to = DateFormat('dd/MM/yyyy').format(_toDate);
        }
      });
    Navigator.of(context).pop(context);
    showFilterBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2.5,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(context),
          icon: Icon(
            Feather.arrow_left,
            size: _size.width / 15.0,
          ),
        ),
        title: Text(
          'History',
          style: TextStyle(
            fontSize: _size.width / 16.0,
            fontWeight: FontWeight.w400,
            fontFamily: 'Lobster',
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => showFilterBottomSheet(),
            child: Icon(
              Feather.sliders,
              size: _size.width / 16.0,
            ),
          ),
          SizedBox(
            width: 4.0,
          ),
          IconButton(
            onPressed: () => Get.snackbar(
              '',
              '',
              colorText: Colors.white,
              backgroundColor: Colors.black54,
              dismissDirection: SnackDismissDirection.HORIZONTAL,
              duration: Duration(
                milliseconds: 2000,
              ),
              titleText: Text(
                'Completed',
                style: TextStyle(
                  fontSize: _size.width / 24.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              messageText: Text(
                'Deleted all messages with strangers!',
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
            ),
            icon: Icon(
              Feather.trash,
              size: _size.width / 16.0,
            ),
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('chatrooms')
              .where('id1', isEqualTo: user.uid)
              .where('hashtag', whereIn: _hashtags)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snap1) {
            if (!snap1.hasData) {
              return Loading();
            }

            return StreamBuilder(
              stream: Firestore.instance
                  .collection('chatrooms')
                  .where('id2', isEqualTo: user.uid)
                  .where('hashtag', whereIn: _hashtags)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snap2) {
                if (!snap2.hasData) {
                  return Loading();
                }

                List<DocumentSnapshot> docs = snap1.data.documents;
                docs.addAll(snap2.data.documents);

                // Filter Single Room
                docs
                    .where((doc) {
                      return doc['id1'] == doc['id2'];
                    }) // filter keys
                    .toList() // create a copy to avoid concurrent modifications
                    .forEach(docs.remove);

                // Sort By Time
                for (int i = 0; i < docs.length - 1; i++) {
                  for (int j = 0; j < docs.length - 1 - i; j++) {
                    Timestamp t1 = docs[j]['publishAt'];
                    Timestamp t2 = docs[j + 1]['publishAt'];
                    if (t1.compareTo(t2) == -1) {
                      DocumentSnapshot temp = docs[j];
                      docs[j] = docs[j + 1];
                      docs[j + 1] = temp;
                    }
                  }
                }

                print(docs.length);

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return Container();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _filterBottomSheet(context) {
    final Size _size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            12.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Text(
                "Filter Conversations",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: _size.width / 24.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade400,
              thickness: .25,
              height: .25,
              indent: 22.0,
              endIndent: 20.0,
            ),
            SizedBox(
              height: 12.0,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'From',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: _size.width / 25.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: GestureDetector(
                    onTap: () async {
                      _selectDateFrom(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 18.0,
                        right: 12.0,
                        top: 15.0,
                        bottom: 15.0,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        color: Colors.grey.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFABBAD5),
                            spreadRadius: .8,
                            blurRadius: 2.0,
                            offset:
                                Offset(0, 2.0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _from,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: _size.width / 28.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Feather.calendar,
                            size: _size.width / 20,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'To',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: _size.width / 25.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: GestureDetector(
                    onTap: () async {
                      await _selectDateTo(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 18.0,
                        right: 12.0,
                        top: 15.0,
                        bottom: 15.0,
                      ),
                      margin: EdgeInsets.all(
                        12.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        color: Colors.grey.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFABBAD5),
                            spreadRadius: .8,
                            blurRadius: 2.0,
                            offset:
                                Offset(0, 2.0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _to,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: _size.width / 28.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Feather.calendar,
                            size: _size.width / 20.0,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Hashtag',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: _size.width / 25.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    padding: EdgeInsets.only(left: 18.0, right: 12.0),
                    margin: EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      color: Colors.grey.shade50,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFABBAD5),
                          spreadRadius: .8,
                          blurRadius: 2.0,
                          offset: Offset(0, 2.0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField(
                        icon: Icon(
                          Feather.hash,
                          size: _size.width / 20.0,
                          color: Colors.grey.shade700,
                        ),
                        iconEnabledColor: Colors.grey.shade800,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        value: _hashtag,
                        items: _hashtags0.map((hashtag) {
                          return DropdownMenuItem(
                              value: hashtag,
                              child: Text(
                                hashtag.substring(1),
                                style: TextStyle(
                                  fontSize: _size.width / 25.0,
                                  color: Colors.grey.shade800,
                                ),
                              ));
                        }).toList(),
                        onChanged: (val) {
                          setState(
                            () {
                              _hashtag = val;
                              _hashtags.clear();
                              switch (val) {
                                case 'All':
                                  _hashtags.addAll(_hashtags0);
                                  break;
                                case 'Talk':
                                  _hashtags.addAll(_hashtags1);
                                  break;
                                case 'Love':
                                  _hashtags.addAll(_hashtags2);
                                  break;
                                case 'LGBT':
                                  _hashtags.addAll(_hashtags3);
                                  break;
                                case '18+':
                                  _hashtags.addAll(_hashtags4);
                                  break;
                                default:
                                  break;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
          ],
        ),
      ),
    );
  }
}
