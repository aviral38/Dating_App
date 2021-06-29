import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matri_app/photo_widget.dart';
import 'package:matri_app/user/message.dart';
class message_widget extends StatefulWidget {
  final String messageId,currentUserId;

  message_widget({this.messageId,this.currentUserId});

  @override
  _message_widgetState createState() => _message_widgetState();
}

class _message_widgetState extends State<message_widget> {
  Message _message;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future getDetails() async{
    _message=await getMessageDetail(messageId: widget.messageId);
    return _message;
  }
  Future<Message> getMessageDetail({messageId}) async{
    Message _message=Message();
    await _firestore.collection('messages').doc(messageId).get().then((message){
      _message.senderId=message['senderId'];
      _message.senderName=message['senderName'];
      _message.timestamp=message['timestamp'];
      _message.text=message['text'];
      _message.photourl=message['photoUrl'];
    });
    return _message;
  }
  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return FutureBuilder(future:getDetails(),
        builder: (context,snapshot){
      if(!snapshot.hasData)
        {
          return Container();
        }
      else{
        _message=snapshot.data;
        return Column(
          crossAxisAlignment: _message.senderId==widget.currentUserId?CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: [
            _message.text!=null?Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
          direction: Axis.horizontal,
          children: [
            _message.senderId==widget.currentUserId ? Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height*0.01
              ),
              child: Text(_message.timestamp.toDate().hour.toString()+":"+_message.timestamp.toDate().minute.toString()),

            ):Container(),
            Padding(padding: EdgeInsets.all(size.height*0.01),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width*0.7
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _message.senderId==widget.currentUserId ? Colors.orange:Colors.blue,
                  borderRadius: _message.senderId==widget.currentUserId ? BorderRadius.only(topLeft: Radius.circular(size.height*0.02),topRight: Radius.circular(size.height*0.02),bottomLeft: Radius.circular(size.height*0.02)):BorderRadius.only(topRight: Radius.circular(size.height*0.02),topLeft: Radius.circular(size.height*0.02),bottomRight: Radius.circular(size.height*0.02))
                ),
                padding: EdgeInsets.all(size.height*0.01),
                child: Text(
                  _message.text,
                  style: TextStyle(color:_message.senderId==widget.currentUserId?Colors.white:Colors.black),
                ),
              ),
            ),),
            _message.senderId==widget.currentUserId?SizedBox():Padding(padding: EdgeInsets.symmetric(vertical: size.height*0.01),child: Text(_message.timestamp.toDate().hour.toString()+":"+_message.timestamp.toDate().minute.toString()),)
          ],
        ):Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
              children: [
                _message.senderId==widget.currentUserId?Padding(padding: EdgeInsets.symmetric(vertical: size.height*0.01),
                child: Text(_message.timestamp.toDate().hour.toString()+":"+_message.timestamp.toDate().minute.toString()),):Container(),
                Padding(padding: EdgeInsets.all( size.height*0.01),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width*0.7,
                    maxHeight: size.width*0.8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border:Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(size.height*0.02),
                    ),
                    child:ClipRRect(
                      borderRadius: BorderRadius.circular(size.height*0.02),
                      child: Photo_widget(photolink: _message.photourl,),
                    )
                  ),
                ),),
                _message.senderId==widget.currentUserId?SizedBox():Padding(padding: EdgeInsets.symmetric(vertical: size.height*0.01),child: Text(_message.timestamp.toDate().hour.toString()+":"+_message.timestamp.toDate().minute.toString())),
              ],

            )
          ],
        );
      }
        });
  }
}
