import 'package:flutter/material.dart';
import 'package:flutter_news/constant/constantFile.dart';
import 'package:flutter_news/constant/newsModel.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:path/path.dart' as path;

class EditNews extends StatefulWidget {
  final NewsModel model;
  final VoidCallback reload;

  EditNews(this.model, this.reload);

  @override
  _EditNewsState createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNews> {

  final _key = new GlobalKey<FormState>();

  File _imageFile;
  String title, content, description, id_user;
  TextEditingController txtTitle, txtContent, txtDescription;

  setup() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id_user = preferences.getString("id_user");
    });

    txtTitle = TextEditingController(text: widget.model.title);
    txtContent = TextEditingController(text: widget.model.content);
    txtDescription = TextEditingController(text: widget.model.description);
  }

  check(){
    final form = _key.currentState;
    if(form.validate()){
        form.save();
        submit();
    } else {

    }
  }

  submit() async{
    try{
        var uri = Uri.parse(BaseUrl.edit);
        var request = http.MultipartRequest("Post", uri);
        
        request.fields['title'] = title;
        request.fields['content'] = content;
        request.fields['description'] = description;
        request.fields['id_user'] = id_user;
        request.fields['id_news'] = widget.model.id_news;

        var stream = http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        var length = await _imageFile.length();

        request.files.add(http.MultipartFile('image', stream, length, filename: path.basename(_imageFile.path)));

        var response = await request.send();

        if(response.statusCode > 2){
          print("Image upload ");
          setState(() {
            widget.reload;
            Navigator.pop(context);
          });
        } else {
          print("Image failed");
        }

    } catch (e) {

    }
  }

  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);
    setState(() {
      _imageFile = image;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
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
            Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  _pilihGallery();
                },
                child: _imageFile == null
                    ? Image.network(BaseUrl.images + widget.model.image)
                    : Image.file(_imageFile),
              ),
            ),
            TextFormField(
              controller: txtTitle,
              onSaved: (e) => title = e,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextFormField(
              controller: txtContent,
              onSaved: (e) => content = e,
              decoration: InputDecoration(labelText: "Content"),
            ),
            TextFormField(
              controller: txtDescription,
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
