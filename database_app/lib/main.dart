import 'package:database_app/user_dialog.dart';
import 'package:database_app/user_list.dart';
import 'package:database_app/user_presenter.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'database_app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'database_app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserPresenter userPresenter;
  Future _displayUserDialog() async{
    showDialog(
      context:context,
      builder:(BuildContext context) =>
        new UserDialog().buildDialog(context,this)
    );
  }
  @override
  void initState(){
    super.initState();
    userPresenter = new UserPresenter(this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new FutureBuilder(
        future: userPresenter.getUsers(),
        builder: (context,build){
          if(build.hasError){
          print(build.hasError);
          }
          var data = build.data;
          return build.hasData ? new UserList(tasks:data,presenter:userPresenter) : new Center();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayUserDialog,
        tooltip: "Add user",
        child:Icon(Icons.add),
      ),
    );
  }

  void updateData(){
    setState(() {

    });
  }
}