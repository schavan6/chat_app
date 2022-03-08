import 'package:flutter/material.dart';
import 'package:fanpage/models/user.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fanpage/services/database.dart';
class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen(
      {@required this.uid, @required this.contact, @required this.convoID});
  final String uid, convoID;
  final User contact;

  @override
  _NewConversationScreenState createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  bool isRated = false;
  double rating = 0;
  int reviews = 0;
  int _value = 1;
  DocumentSnapshot document;
  @override
  void initState(){
    _getRating();
    super.initState();
  }
  void _getRating() async{
    document = await FirebaseFirestore.instance.collection('users').doc(widget.contact.id).get();
    //print("constructor:");
    //print(document.data()['rating']);
    reviews = await document.data()['reviews'];
    rating = await document.data()['rating'] as double;


  }
  void _onValueChange(int value) {
    setState(() {
      _value = value;

    });
  }
  _ratePeer(int value){
    double new_rating = ((rating + value) / (reviews+1));
    print("rate:");
    print(document);
    document.reference.set(<String, dynamic>{
      'rating': new_rating,
      'reviews': reviews+1

    },SetOptions(merge: true));
    isRated = true;
    rating = new_rating;

  }
  Widget _showRatingPopup(){
    return
       MyDialog(
        onValueChange: _onValueChange,
        initialValue: _value,
         ratePeer :_ratePeer
       );


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
        AppBar(
            actions: [isRated ? IconButton(
              icon: const Icon(Icons.star, color: Colors.black),
              onPressed: () => {},
            ):IconButton(
              icon: const Icon(Icons.star_border, color: Colors.black),
              onPressed: () => {
                showDialog(
                context: context,
                builder: (BuildContext context) => _showRatingPopup()
                )
              }
            )],
            automaticallyImplyLeading: true, title: Text(widget.contact.name + " (" + rating.toString() + ")")),
        body: ChatScreen(uid: widget.uid, convoID: widget.convoID, contact: widget.contact));
  }
}
class MyDialog extends StatefulWidget {
  const MyDialog({this.onValueChange, this.initialValue, this.ratePeer});

  final int initialValue;
  final void Function(int) onValueChange;
  final void Function(int) ratePeer;

  @override
  State createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  int _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Dialog"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          //textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            widget.ratePeer(_selectedId);
            Navigator.of(context).pop();
          },
          //textColor: Theme.of(context).primaryColor,
          child: const Text('Rate'),
        ),
      ],
      content: Column(
        children: <Widget>[
          for (int i = 1; i <= 5; i++)
            ListTile(
              title: Text(
                '$i Star',
                //style: Theme.of(context).textTheme.subtitle1.copyWith(color: i == 5 ? Colors.black38 : shrineBrown900),
              ),
              leading: Radio<int>(
                value: i,
                groupValue: _selectedId,
                onChanged: (int value) {
                  setState(() {
                    _selectedId = value;
                  });
                  widget.onValueChange(value);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {@required this.uid, @required this.convoID, @required this.contact});
  final String uid, convoID;
  final User contact;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String uid, convoID;
  User contact;
  List<DocumentSnapshot> listMessage;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    convoID = widget.convoID;
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(),
              buildInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              // Edit text
              Flexible(
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        autofocus: true,
                        maxLines: 5,
                        controller: textEditingController,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type your message...',
                        ),
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.send, size: 25),
                  onPressed: () => onSendMessage(textEditingController.text),
                ),
              ),
            ],
          ),
        ),
        width: double.infinity,
        height: 100.0);
  }

  Widget buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(convoID)
            .collection(convoID)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage = snapshot.data.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) =>
                  buildItem(index, snapshot.data.docs[index]),
              itemCount: snapshot.data.docs.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (!document['read'] && document['idTo'] == uid) {
      print(document['read']);
      Database.updateMessageRead(document, convoID);
    }

    if (document['idFrom'] == uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Bubble(
                  color: Colors.blueGrey,
                  elevation: 0,
                  padding: const BubbleEdges.all(10.0),
                  nip: BubbleNip.rightTop,
                  child: Text(document['content'], style: TextStyle(color: Colors.white))),
              width: 200)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {

      // Left (peer message)
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                child: Bubble(
                    color: Colors.grey,
                    elevation: 0,
                    padding: const BubbleEdges.all(10.0),
                    nip: BubbleNip.leftTop,
                    child: Text(document['content'], style: TextStyle(color: Colors.blueGrey))),
                width: 200.0,
                margin: const EdgeInsets.only(left: 10.0),
              )
            ])
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }
  void onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();
      content = content.trim();
      Database.sendMessage(convoID, uid, contact.id, content,
          DateTime.now().millisecondsSinceEpoch.toString());
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

}




