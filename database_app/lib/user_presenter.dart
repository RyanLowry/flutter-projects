

import 'package:database_app/database/database_helper.dart';

import 'database/model/user.dart';

class UserPresenter{
  var _view;
  var db =  new DatabaseHelper();

  UserPresenter(this._view);

  void delete(User user){
    db.deleteUser(user.id);
    updateData();

  }
  Future<List<User>> getUsers(){
    return db.getAllUsers();
  }

  updateData(){
    _view.updateData();
  }

}