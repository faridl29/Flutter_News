import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_news/constant/constantFile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class AddNews extends StatefulWidget {
  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  File _imageFile;
  String title, content, description, id_user;

  final _key = new GlobalKey<FormState>();

  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);
    setState(() {
      _imageFile = image;
    });
  }

  check(){
    final form = _key.currentState;
    if(form.validate()){
      form.save();
      submit();
    }
  }

  submit() async{
    try{
      var stream = http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      var uri = Uri.parse(BaseUrl.news);
      var request = http.MultipartRequest("Post", uri);
      request.files.add(http.MultipartFile('image', stream, length, filename: path.basename(_imageFile.path)));

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['description'] = description;
      request.fields['id_user'] = id_user;

      var response = await request.send();

      if(response.statusCode > 2){
        print("Image upload ");
        setState(() {
          Navigator.pop(context);
        });
      } else {
        print("Image failed");
      }

    } catch (e){
      debugPrint("error $e ");
    }
  }

  getPref() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_user = preferences.getString("id_user");

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
    var placeholder = Container(
      width: double.infinity,
      height: 150,
      child: Image.asset('./image/placeholder.png'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Add News"),
        centerTitle: true,
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  _pilihGallery();
                },
                child: _imageFile == null
                    ? placeholder
                    : Image.file(_imageFile, fit: BoxFit.fill),
              ),
            ),
            TextFormField(
              onSaved: (e) => title = e,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextFormField(
              onSaved: (e) => content = e,
              decoration: InputDecoration(labelText: "Content"),
            ),
            TextFormField(
              onSaved: (e) => description = e,
              decoration: InputDecoration(labelText: "Description"),
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
