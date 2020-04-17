import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_news/constant/constantFile.dart';
import 'package:flutter_news/constant/newsModel.dart';
import 'package:flutter_news/viewTab/addNews.dart';
import 'package:flutter_news/viewTab/editNews.dart';
import 'package:http/http.dart' as http;

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  final list = new List<NewsModel>();
  var loading = false;

  Future _getData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(BaseUrl.news);

    if (response.contentLength == 2) {
    } else {
      setState(() {
        loading = false;
      });
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new NewsModel(
            api['id_news'],
            api['image'],
            api['title'],
            api['content'],
            api['description'],
            api['date_news'],
            api['id_users'],
            api['username']);

        list.add(ab);
      });

      
    }
  }

  _delete(String id_news) async{
    final response = await http.post(BaseUrl.delete, body: {
      "id_news" : id_news
    });

    final data = jsonDecode(response.body);
    
    if(data['error'] == false){
      _getData();
    }else{
      print(data);
    }
  }

  dialogDelete(String id_news){
    showDialog(context: context,
    builder: (context){
      return Dialog(child: ListView(
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        children: <Widget>[
          Text("Anda yakin ingin menghapus data ini?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(onTap: (){
                Navigator.pop(context);
              }, child: Text("No")),
              SizedBox(width: 20,),
              InkWell(onTap: (){
                _delete(id_news);
              }, child: Text("Yes"))
            ],
          )
        ],
      ),);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News"),
      ),
      body: RefreshIndicator(
        onRefresh: (){
          _getData();
        },
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final x = list[i];
                  return Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image.network(
                              BaseUrl.images + x.image,
                              width: 150,
                              height: 120,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(width: 13, height: 3,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(x.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 3,),
                                  Text(x.date_news)
                                ],
                              ),
                            ),
                            IconButton(icon: Icon(Icons.edit), onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditNews(x, _getData)));
                            }),
                            IconButton(icon: Icon(Icons.delete), onPressed: (){
                              dialogDelete(x.id_news);
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddNews()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
