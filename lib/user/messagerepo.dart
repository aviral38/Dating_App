/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:matri_app/user/message.dart';
import 'package:uuid/uuid.dart';
class Messagerepo{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage=FirebaseStorage.instance;
  String uuid=Uuid().v4();

  Future sendMessage({Message message}) async{
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
        await messageRef.set({
          'senderName':message.senderName,
          'senderId':message.senderId,
          'text':message.text,
          'photoUrl':null,
          'timestamp':DateTime.now(),
        });
        senderRef.doc(messageRef.id).set({'timestamp':DateTime.now()});

        sendUserRef.doc(messageRef.id).set({'timestamp':DateTime.now()});
        await _firestore.collection('users').doc(message.senderId).collection('chats').doc(message.selectedUserId).update(
            {'timestamp':DateTime.now()});
        await _firestore.collection('users').doc(message.selectedUserId).collection('chats').doc(message.senderId).update(
            {'timestamp':DateTime.now()});

      }

    var snapshot=await FirebaseStorage.instance.ref().child('userPhotos').child(userId)
        .child(userId)
        .putFile(photo).whenComplete(() => null);
    String url=await snapshot.ref.getDownloadURL();

  }

  Stream<QuerySnapshot> getMessages({currentUserId,selectedUserId}){
    _firestore.collection('users').doc(currentUserId).collection('chats').doc(selectedUserId).collection('messages').orderBy('timestamp',descending: false).snapshots();
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







  Stream<QuerySnapshot> getChats({userId}){
    return _firestore.collection('users').doc(userId).collection('chats').orderBy('timestamp',descending: true).snapshots();
  }

  Future deleteChat({currentUserId,selectedUserId}) async{
    return await _firestore.collection('users').doc(currentUserId).collection('chats').doc(selectedUserId).delete();
  }

  Fututre<User> getUserDetail({userId}) async{
    User _user=User();

    await _firestore.collection('users').doc(userId).get().then((user){
      _user.uid=user.id;
      _user.name=user['name'];....same
    });
  }

  Future<Message> getLastMessage({currentUserId,selectedUserId}) async{
    Message _message=Message();


    await _firestore.collection('users').doc(currentUserId).collection('chats').doc(selectedUserId).collection('messages').orderBy('timestamp',descending: true).snapshots().first.then((document) async{
      await _firestore.collection('messages').doc(document.docs.first.id).get().then((message){
        _message.text=message['text'];
        _message.photourl=message['photourl'];
        _message.timestamp=message['timestamp'];
      });
    });

    return _message;
  }



  
}*/