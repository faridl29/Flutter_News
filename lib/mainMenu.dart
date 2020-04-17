import 'package:flutter/material.dart';
import 'package:flutter_news/viewTab/category.dart';
import 'package:flutter_news/viewTab/home.dart';
import 'package:flutter_news/viewTab/news.dart';
import 'package:flutter_news/viewTab/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;

  MainMenu(this.signOut);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String username, email;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username");
      email = preferences.getString("email");
    });
  }

  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
          child: Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.lock_open),
            )
          ],
          centerTitle: true,
          title: Text("Flutter News"),
        ),
        body: TabBarView(
          children: <Widget>[
            Home(),
            News(),
            Category(),
            Profile()
          ],
          // child: Text("username : $username \n email: $email"),
        ),
        bottomNavigationBar: TabBar(
          indicatorColor: Colors.transparent,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: <Widget>[
          Tab(
            icon: Icon(Icons.home),
            text: "Home",
          ),
          Tab(
            icon: Icon(Icons.new_releases),
            text: "News",
          ),
          Tab(
            icon: Icon(Icons.category),
            text: "Category",
          ),
          Tab(
            icon: Icon(Icons.perm_contact_calendar),
            text: "Profile",
          ),
        ]),
      ),
    );
  }
}
