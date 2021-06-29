import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:matri_app/photo_widget.dart';
import 'package:matri_app/user/message.dart';
import 'package:matri_app/widgets/message_widget.dart';
import 'package:uuid/uuid.dart';
import 'user/user.dart';
class Messaging_page extends StatefulWidget {
  final Usersclass currentuser,selectedUser;
  Messaging_page({this.currentuser,this.selectedUser});


  @override
  _Messaging_pageState createState() => _Messaging_pageState();
}

class _Messaging_pageState extends State<Messaging_page> {

  TextEditingController _messageTextController=TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage=FirebaseStorage.instance;
  String uuid=Uuid().v4();
  bool isValid =false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messageTextController.text="";
    _messageTextController.addListener(() {
      setState(() {
        isValid=_messageTextController.text.isEmpty?false:true;
      });
    });
  }
  /*bool isPopulated(){
    return _messageTextController.text.isNotEmpty;
  }
  bool isSubmitButtonEnabled()
  {
    return isPopulated();
  }*/

  void _onFormSubmitted(){
    print("message Submitted "+widget.currentuser.uid);
    String senderName, senderId, selectedUserId, text, photourl;
    File photo;
    Timestamp timestamp;
    Message sending_message=Message(
      senderName: widget.currentuser.name,
      text: _messageTextController.text,
      senderId: widget.currentuser.uid,
      selectedUserId: widget.selectedUser.uid,
      photo: null,
      photourl: null,

    );
    sendMessage(message: sending_message);
    _messageTextController.clear();
  }



  Future sendMessage({Message message}) async{
    print('lolo '+message.senderName);
    DocumentReference messageRef=_firestore.collection('messages').doc();

    CollectionReference senderRef=_firestore.collection('users').doc(message.senderId).collection('chats').doc(message.selectedUserId).collection('messages');
    CollectionReference sendUserRef=_firestore.collection('users').doc(message.selectedUserId).collection('chats').doc(message.senderId).collection('messages');

    if(message.photo != null)
    {
      var snapshot=await FirebaseStorage.instance.ref().child('messages').child(messageRef.id).child(uuid).putFile(message.photo).whenComplete(() => null);
      await snapshot.ref.getDownloadURL().then((photoUrl) async{
        await messageRef.set({
          'senderName':message.senderName,
          'senderId':message.senderId,
          'text':null,
          'photoUrl':photoUrl,
          'timestamp':DateTime.now(),
        });
      });

      senderRef.doc(messageRef.id).set({'timestamp':DateTime.now()});

      sendUserRef.doc(messageRef.id).set({'timestamp':DateTime.now()});

      _firestore.collection('users').doc(message.senderId).collection('chats').doc(message.selectedUserId).update(
          {'timestamp':DateTime.now()});

      _firestore.collection('users').doc(message.selectedUserId).collection('chats').doc(message.senderId).update(
          {'timestamp':DateTime.now()});
    }
    if(message.text!=null)
    {
      print('yes');
      await messageRef.set({
        'senderName':message.senderName,
        'senderId':message.senderId,
        'text':message.text,
        'photoUrl':null,
        'timestamp':DateTime.now(),
      });
      senderRef.doc(messageRef.id).set({'timestamp':DateTime.now()});

      sendUserRef.doc(messageRef.id).set({'timestamp':DateTime.now()});
     /* await _firestore.collection('users').doc(message.senderId).collection('chats').doc(message.selectedUserId).update(
          {'timestamp':DateTime.now()});
      await _firestore.collection('users').doc(message.selectedUserId).collection('chats').doc(message.senderId).update(
          {'timestamp':DateTime.now()});*/

    }



  }
  Future<int> buildd() async
  {
    print('jjjjjj'+widget.currentuser.uid+" "+widget.selectedUser.uid);
     return 1;
  }
  Stream<QuerySnapshot> getMessages({currentUserId,selectedUserId}){
    print('j');
    return _firestore.collection('users').doc(currentUserId).collection('chats').doc(selectedUserId).collection('messages').orderBy('timestamp',descending: false).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5D8FDE),
        elevation: size.height*0.2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipOval(
              child: Container(
                height: size.height*0.06,
                width: size.height*0.06,
                child: Photo_widget(photolink: widget.selectedUser.photo,
                ),
              ),
            ),
            SizedBox(width: size.width*0.03,),
            Expanded(child: Text(widget.selectedUser.name),)
          ],
        ),
      ),
      body: FutureBuilder(
        future: buildd(),
        builder: ( context,snap){
          if(snap.data!=null)
            {
              Stream<QuerySnapshot> messageStream=_firestore.collection('users').doc(widget.currentuser.uid).collection('chats').orderBy('timestamp',descending: true).snapshots();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<QuerySnapshot>(stream:getMessages(currentUserId: widget.currentuser.uid,selectedUserId: widget.selectedUser.uid),builder: (context,snapshot){
                    if(!snapshot.hasData)
                      {
                        return Text("Start the conversations",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),);
                      }
                    if(snapshot.data.docs.isNotEmpty)
                      {
                        return Expanded(child: Column(children: [
                          Expanded(child: ListView.builder(scrollDirection:Axis.vertical,itemBuilder:(BuildContext context,int index){
                            return message_widget(currentUserId: widget.currentuser.uid,messageId: snapshot.data.docs[index].id,);
                          } ,
                          itemCount: snapshot.data.docs.length,))
                        ],));
                      }
                    else{
                      return Center(
                        child: Text("start the convo?",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                      );
                    }
                  }),
                  Container(
                    width: size.width,
                    height: size.height*0.06,
                    color: Colors.orange,
                    child: Row(
                      children: [
                        GestureDetector(onTap: ()async{
                          FilePickerResult result=await FilePicker.platform.pickFiles(type: FileType.image);
                          if(result!=null)
                            {
                              File photo = File(result.files.single.path);
                              sendMessage(message: Message(text: null,
                              senderName: widget.currentuser.name,
                              senderId: widget.currentuser.uid,
                              photo: photo,
                              selectedUserId: widget.selectedUser.uid));
                            }

                        },
                          child: Padding(padding: EdgeInsets.symmetric(horizontal: size.height*0.005),
                          child: Icon(Icons.add,
                          color: Colors.white,
                              size: size.height*0.04,),),
                        ),
                        Expanded(child: Container(height: size.height*0.05,
                        padding: EdgeInsets.all(size.height*0.01),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(size.height*0.04),

                        ),
                        child: Center(
                          child: TextField(
                            controller: _messageTextController,
                            textInputAction: TextInputAction.send,
                            maxLines: null,
                            decoration: null,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.white10,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),)),
                        GestureDetector(
                          onTap: isValid?_onFormSubmitted:null,
                          child: Padding(padding: EdgeInsets.symmetric(horizontal: size.height*0.01),
                          child: Icon(
                            Icons.send,
                            color: isValid?Colors.white:Colors.grey,
                          ),),
                        )
                      ],
                    ),
                  )
                ],
              );

            }
          return Container();
        },
      ),

    );
  }
}
