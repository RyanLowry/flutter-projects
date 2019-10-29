
import 'package:database_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'database/model/user.dart';

class UserDialog{
  final fnameController = new TextEditingController();
  final lnameController = new TextEditingController();


  Widget buildDialog(BuildContext context,_myHomePageState){
    return new AlertDialog(
      title: new Text("Add User"),
      content: new SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextFormField(
              controller: fnameController,
              decoration: new InputDecoration(
                hintText: "First Name"
              ),
            ),
            new TextFormField(
              controller: lnameController,
              decoration: new InputDecoration(
                  hintText: "Last Name"
              ),
            ),
            new IconButton(icon: Icon(Icons.add_box), onPressed: (){
              addUser();
              _myHomePageState.updateData();
              Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }
  Future addUser() async{
    var db = new DatabaseHelper();
    var user = new User(firstName:fnameController.text,lastName:lnameController.text);
    await db.insertUser(user);

  }
}