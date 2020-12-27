import 'package:flutter/material.dart';
import 'package:whoru/src/animation/fade_animation.dart';
import 'package:whoru/src/services/auth.dart';
import 'package:whoru/src/widgets/loading.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleView;

  RegisterPage({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  FocusNode textFieldFocus = FocusNode();
  String email = '';
  String password = '';

  bool hidePassword = true;
  bool loading = false;

  hideKeyboard() => textFieldFocus.unfocus();

  @override
  Widget build(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height;
    final sizeWidth = MediaQuery.of(context).size.width;

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: sizeHeight / 2.0,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: sizeWidth * 0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              FadeAnimation(
                                  1.7,
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color:
                                                          Colors.grey[200]))),
                                          child: TextFormField(
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: sizeWidth / 24,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            validator: (val) => val.length == 0
                                                ? 'Enter your Email'
                                                : null,
                                            onChanged: (val) =>
                                                email = val.trim(),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Email",
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: sizeWidth / 24,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color:
                                                          Colors.grey[200]))),
                                          child: TextFormField(
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: sizeWidth / 24,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            validator: (val) => val.length < 6
                                                ? 'Password least 6 characters'
                                                : null,
                                            onChanged: (val) =>
                                                password = val.trim(),
                                            obscureText: hidePassword,
                                            focusNode: textFieldFocus,
                                            textAlign: TextAlign.justify,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Password",
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: sizeWidth / 24,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          child: TextFormField(
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: sizeWidth / 24,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            validator: (val) => val != password
                                                ? 'Those passwords didn\'t match. Try again.'
                                                : null,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "re-Type Password",
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: sizeWidth / 24,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                height: 32,
                              ),
                              FadeAnimation(
                                  1.9,
                                  GestureDetector(
                                    onTap: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        dynamic result = await _auth
                                            .registerWithEmailAndPassword(
                                                email, password);
                                        if (result == null) {
                                          setState(() {
                                            loading = false;
                                          });
                                        } else {}
                                      }
                                    },
                                    child: Container(
                                      height: sizeHeight * 0.07,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        color: Colors.blue,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Register",
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(.88),
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              FadeAnimation(
                                  2,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Already have an account\t?\b",
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w400,
                                              fontSize: sizeWidth / 30)),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            widget.toggleView();
                                          });
                                        },
                                        child: Text("Login now",
                                            style: TextStyle(
                                                color: Colors.blue[500],
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: sizeWidth / 28)),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
