import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoadingProgess extends StatefulWidget {
  final double progress;
  LoadingProgess({this.progress});
  @override
  State<StatefulWidget> createState() => _LoadingProgessState();
}

class _LoadingProgessState extends State<LoadingProgess> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 24.0,
            ),
            Text(
              'Uploading ${(widget.progress * 100).toStringAsFixed(2)} %',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
