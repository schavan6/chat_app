import 'package:fanpage/services/auth.dart';
import 'package:flutter/material.dart';

class LogoutModal extends StatelessWidget {
  final AuthBase auth;

  const LogoutModal({Key key, @required this.auth}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
          children: [
            const Text('Do you want to log out?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () => _signOut(context),
                )),
                const SizedBox(
                  width: 8,

                ),
                (ElevatedButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.of(context).pop(),
                )),
              ],
            )
          ],
        ),


    );

  }
}
