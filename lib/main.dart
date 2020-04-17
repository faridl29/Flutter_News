import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_news/constant/constantFile.dart';
import 'package:flutter_news/mainMenu.dart';
import 'package:flutter_news/register.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus {notSignIn, signIn}

class _LoginState extends State<Login> {

  LoginStatus _loginStatus = LoginStatus.notSignIn;

  String email, password;
  final _key = new GlobalKey<FormState>();

  bool secureText = true;

  showHide(){
    setState(() {
      secureText = !secureText;
    });
  }

  void check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final response = await http.post(
        BaseUrl.login,
        body: {"email": email, "password": password});

    final data = jsonDecode(response.body);
    print(data);

    String usernameApi, emailApi, idUserApi;
    
    if(data['error'] == false){
      setState(() {
        _loginStatus = LoginStatus.signIn;
        usernameApi = data['username'];
        emailApi = data['email'];
        idUserApi = data['id_user'];
        savePref(data['error'], usernameApi, emailApi, idUserApi);
      });
    }
  }

  savePref(bool value, String username, String email, String id_user) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setBool("sudahLogin", !value);
      preferences.setString("username", username);
      preferences.setString("email", email);
      preferences.setString("id_user", id_user);
      preferences.commit();
    });
  }

  var value;
  cekLogin() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getBool("sudahLogin");
      _loginStatus = value == true ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setBool("sudahLogin", false);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    cekLogin();  
  }

  @override
  Widget build(BuildContext context) {

    switch(_loginStatus){
      case LoginStatus.notSignIn:
        break;
    
      case LoginStatus.signIn:
        return MainMenu(signOut);
        break;
    }

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert email!";
                }
              },
              onSaved: (e) => email = e,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert password!";
                }
              },
              obscureText: secureText,
              onSaved: (e) => password = e,
              decoration: InputDecoration(
                labelText: "password", 
                suffixIcon: IconButton(
                  onPressed: showHide, 
                  icon: Icon(
                    secureText ? Icons.visibility_off : Icons.visibility
                  ),
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("LOGIN"),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Register()));
              },
              child: Text("Create new account", textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }
}
