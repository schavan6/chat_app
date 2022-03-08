import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:chat_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:fanpage/providers/newMessageProvider.dart';
import 'package:fanpage/models/user.dart' as u;
import '../models/convo.dart';
import '../services/auth.dart';
import 'convoWidget.dart';

class HomeBuilder extends StatelessWidget {

  const HomeBuilder({Key key, @required this.auth}) : super(key: key);
  final AuthBase auth;
  @override
  Widget build(BuildContext context) {
    final User firebaseUser =auth.currentUser;
    final List<Convo> _convos = Provider.of<List<Convo>>(context);
    final List<u.User> _users = Provider.of<List<u.User>>(context);
    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  onPressed: () => auth.signOut(),
                  icon: const Icon(Icons.first_page, size: 30)),
              Text(firebaseUser.displayName != null ?firebaseUser.displayName : " " , style: TextStyle(fontSize: 18)),
              IconButton(
                  onPressed: () => createNewConvo(context),
                  icon: const Icon(Icons.add, size: 30))
            ],
          )),
      body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: getWidgets(context, firebaseUser, _convos, _users))
    );
  }

  void createNewConvo(BuildContext context) {

    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NewMessageProvider(auth: auth,)));
  }

  Map<String, u.User> getUserMap(List<u.User> users) {
    final Map<String, u.User> userMap = Map();
    for (u.User usr in users) {
      userMap[usr.id] = usr;
    }
    return userMap;
  }

  List<Widget> getWidgets(
      BuildContext context, User user, List<Convo> _convos, List<u.User> _users) {

    final List<Widget> list = <Widget>[];
    print(_users);
    if (_convos != null && _users != null && user != null) {

      final Map<String, u.User> userMap = getUserMap(_users);
      for (Convo c in _convos) {
        if (c.userIds[0] == user.uid) {
          list.add(ConvoListItem(
              user: user,
              peer: userMap[c.userIds[1]],
              lastMessage: c.lastMessage));
        } else {
          list.add(ConvoListItem(
              user: user,
              peer: userMap[c.userIds[0]],
              lastMessage: c.lastMessage));
        }
      }
    }

    return list;
  }
}