import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fanpage/models/user.dart' as u;
import 'package:fanpage/app/userRow.dart';

import '../services/auth.dart';

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({Key key, @required this.auth}) : super(key: key);
  final AuthBase auth;

  @override
  Widget build(BuildContext context) {
    //final FirebaseUser user = Provider.of<FirebaseUser>(context);
    final User user = auth.currentUser;
    final List<u.User> userDirectory = Provider.of<List<u.User>>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Select Contact')),
      body: userDirectory != null
          ? ListView(
          shrinkWrap: true, children: getListViewItems(userDirectory, user))
          : Container(),
    );
  }

  List<Widget> getListViewItems(List<u.User> userDirectory, User user) {
    final List<Widget> list = <Widget>[];
    //print("self uid: "+user.uid);
    for (u.User contact in userDirectory) {
      //print( contact.id);
      if (contact.id != user.uid) {

        list.add(UserRow(uid: user.uid, contact: contact));
        list.add(Divider(thickness: 1.0));
      }
    }
    return list;
  }
}