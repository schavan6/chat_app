import 'package:fanpage/app/sign_in/logout_modal.dart';
import 'package:fanpage/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, @required this.auth}) : super(key: key);
  final AuthBase auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _bodyController = TextEditingController();
  final CollectionReference _messages =
      FirebaseFirestore.instance.collection('messages');
  dynamic isAdmin = false;

  Stream dataList;

  @override
  void initState() {
    String currentEmail = widget.auth.currentUser.email;
    dataList = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentEmail)
        .snapshots();

    super.initState();
  }


  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      child: const Text('Post'),
                      onPressed: () async {
                        final String message = _bodyController.text;

                        if (message != null) {
                          await _messages.add({
                            "body": message,
                            "post_time": DateTime.now().millisecondsSinceEpoch
                          });

                          // Clear the text fields
                          _bodyController.text = '';

                          // Hide the bottom sheet
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop()
                    )
                  ],
                )

              ],
            ),
          );
        });
  }

  Future<void> _signOut() async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        //fullscreenDialog: true,
        builder: (context) => LogoutModal(auth: widget.auth)
      ),
    );
  }

  Widget _getFAB() {
    return StreamBuilder(
      stream: dataList,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return Text('Error: ${asyncSnapshot.error}');
        }

        switch (asyncSnapshot.connectionState) {
          case ConnectionState.none:
            return const Text('No data');
          case ConnectionState.waiting:
            return const Text('Awaiting...');
          case ConnectionState.active:
            print(asyncSnapshot.data.docs);
            if (asyncSnapshot.hasData && asyncSnapshot.data.docs.length >0) {
              final isAdmin =
                  asyncSnapshot.data.docs[0]['role'] == 'admin' ? true : false;
              if (isAdmin) {
                return FloatingActionButton(
                  onPressed: () => _createOrUpdate(),
                  child: const Icon(Icons.add),
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }

            break;
          case ConnectionState.done:
            if (asyncSnapshot.hasData && asyncSnapshot.data.docs.length >0) {
              final isAdmin =
                  asyncSnapshot.data.docs[0]['role'] == 'admin' ? true : false;
              if (isAdmin) {
                return FloatingActionButton(
                  onPressed: () => _createOrUpdate(),
                  child: const Icon(Icons.add),
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
            break;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //setIsAdmin();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _messages.orderBy('post_time').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['body']),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: _getFAB(),
    );
  }
}
