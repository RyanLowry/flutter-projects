import 'package:database_app/user_presenter.dart';
import 'package:flutter/material.dart';
import 'database/model/user.dart';

class UserList extends StatelessWidget{
  List<User> tasks;
  UserPresenter presenter;

  UserList({
    this.tasks,
    this.presenter,
    Key key,
  }) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: tasks != null? tasks.length : 0,
        itemBuilder: (ctx,i){
          return new Card(
            child:new Container(
              child:new Center(
                child:new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Column(
                        children: <Widget>[
                          new Container(
                            child:new Text(getTaskName(tasks[i].firstName)),
                          ),
                          new Container(
                            child:new Text(getTaskName(tasks[i].lastName)),
                          ),

                        ],
                      ),
                    ),
                    new Column(
                      children: <Widget>[
                        new IconButton(icon: Icon(Icons.delete), onPressed: (){
                          delete(tasks[i]);
                        }),
                      ],
                    )
                  ],
                ),

              ),
            ),

          );
        });
  }
  String getTaskName(str){
    if(str == null){
      return 'null';
    }
    return str;
  }

  void delete(User user){
    presenter.delete(user);
  }

}