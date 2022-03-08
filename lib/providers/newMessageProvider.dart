import 'package:fanpage/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fanpage/models/user.dart' as u;
import 'package:fanpage/services/database.dart';
import 'package:fanpage/app/newMessageScreen.dart';

class NewMessageProvider extends StatelessWidget {
  const NewMessageProvider({Key key, @required this.auth}) : super(key: key);
  final AuthBase auth;
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<u.User>>.value(
      value: Database.streamUsers(),
      initialData: [],
      child: NewMessageScreen(auth: auth,),
    );
  }
}