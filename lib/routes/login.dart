import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:intl/intl.dart';
import 'package:management_console_mobile/routes/main.dart';
import '../main.dart' as globals;

//Start login page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _myUsername = TextEditingController();
  final _myPassword = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 77.5,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final username = TextFormField(
      controller: _myUsername,
      style: globals.style,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: _myPassword,
      obscureText: true,
      style: globals.style,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff007bff),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (_myUsername.text == "" ||
              _myPassword.text == "" ||
              _myUsername.text == null ||
              _myPassword.text == null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Login Error"),
                  content: new Text("Username or password cannot be empty!"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            _login(_myUsername.text, _myPassword.text, context);
            setState(() {
              isLoading = true;
            });
          }
        },
        child: Text('Login',
            style: globals.style
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  logo,
                  SizedBox(height: 48.0),
                  username,
                  SizedBox(height: 8.0),
                  password,
                  SizedBox(height: 24.0),
                  loginButton,
                  forgotLabel
                ],
              ),
      ),
    );
  }

  void _login(usernameField, passwordField, context) async {
    globals.currentUsername = usernameField;
    encryptFunc(passwordField);

    http.Response response = await http.post(
      'https://lucas-testing.000webhostapp.com',
      body: <String, String>{
        "formname": "login",
        "username": globals.currentUsername,
        "password": globals.currentPassword,
        "datetime": DateFormat("yyyy-MM-dd HH:mm:ss")
            .format(DateTime.now()) // MySql Datetime format
      },
    );

    setState(() {
      isLoading = false;
    });

    if (response.body == "1") {
      globals.privileges = "1";
    } else if (response.body == "0") {
      globals.privileges = "0";
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Login Error"),
            content: new Text(
                "Please check your username and password are correct and that you have an internet connection."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
}

void encryptFunc(password) {
  final key = encrypt.Key.fromUtf8('eb45707674371ce8259b2153c7b6a453');
  final iv = encrypt.IV.fromUtf8('70cd8558247bed84');
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  globals.currentPassword = (encrypter.encrypt(password, iv: iv)).base64;
}

//End Login page

//Start Logout function

void logout(context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
  globals.currentUsername = null;
  globals.currentPassword = null;
  globals.privileges = null;
}

//End Logout function
