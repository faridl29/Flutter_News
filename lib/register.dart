import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_news/constant/constantFile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username, email, password;

  final _key = new GlobalKey<FormState>();

  bool secureText = true;

  showHide() {
    setState(() {
      secureText = !secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    final response = await http.post(
        BaseUrl.register,
        body: {"username": username, "email": email, "password": password});

    final data = jsonDecode(response.body);

    if(data['error'] == false){
      setState(() {
        Navigator.pop(context);
      });
    } else {   
      print(data);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  return "Please insert username!";
                }
              },
              onSaved: (e) => username = e,
              decoration: InputDecoration(labelText: "Username"),
            ),
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
                      secureText ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}
