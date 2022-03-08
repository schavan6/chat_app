
import 'package:fanpage/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fanpage/models/user.dart' as u;
import '../models/convo.dart';
import './home_builder.dart';
import '../services/database.dart';

class ConversationProvider extends StatelessWidget {
  const ConversationProvider({
    Key key,
    @required this.auth,
  }) : super(key: key);

  final AuthBase auth;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Convo>>.value(
        value: Database.streamConversations(auth.currentUser.uid),
        catchError: (_, __) => null,
        child: ConversationDetailsProvider(auth: auth));

  }
}

class ConversationDetailsProvider extends StatelessWidget {
  const ConversationDetailsProvider({
    Key key,
    @required this.auth,
  }) : super(key: key);

  final AuthBase auth;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<u.User>>.value(
        value: Database.getUsersByList(
            getUserIds(Provider.of<List<Convo>>(context))),
        catchError: (_, __) => null,
        child: HomeBuilder(auth: auth));
  }

  List<String> getUserIds(List<Convo> _convos) {
    final List<String> users = <String>[];
    if (_convos != null) {
      for (Convo c in _convos) {
        c.userIds[0] != auth.currentUser.uid
            ? users.add(c.userIds[0])
            : users.add(c.userIds[1]);
      }
    }
    //print(users);
    return users;
  }
}