/*import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
class User_repo{
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  User_repo({
    FirebaseAuth firebaseAuth,
    FirebaseFirestore firestore,
}):_firebaseAuth=firebaseAuth??FirebaseAuth.instance,
  _firestore=firestore??FirebaseFirestore.instance;

  Future<void> signInWithEmail(String email,String password)
  {
    _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }
  Future<bool> isFirstTime(String userId) async{
    bool exist;
    await FirebaseFirestore.instance.collection('users').doc(userId).get().then((user){
      exist=user.exists;
    });
    return exist;
  }

  Future<void> signUpWithEmail(String email,String password) async{
    print(_firebaseAuth);
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async{
    return await _firebaseAuth.signOut();
  }
  Future<bool> isSignedIn() async{
    final currentUser= _firebaseAuth.currentUser;
    return currentUser !=null;
  }
  Future<String> getUser() async{
    return (await _firebaseAuth.currentUser.uid);
  }
  Future<void> profileSetup(
      File photo,
      String userId,
      String name,
      String gender,
      String InterestedIn,
      DateTime age,
      GeoPoint location
      ) async{
    FirebaseStorage storageUploadTask;
    FirebaseStorage.instance.ref().child('userPhotos').child(userId).child(userId).putFile(photo);
    await _firestore.collection('users').doc(userId).set({
      'uid':userId,
      //'photourl':url,
      'name':name,
      'location':location,
      'gender':gender,
      'interestedIn':InterestedIn,
      'age':age
    });
  }



  match()
  {
    String currentuserId,selectedUserId,name,photourl;
  }
}
class SearchRepository{
  FirebaseFirestore _firestore;
  chooseUser(currentUserId,selectUserId,name,photoUrl) async{



    await _firestore.collection('users').doc(selecteduserid).collection('selectedList').document(currentuserid).setData({
      'name':name,
      'photoUrl':photourl,
    });
    return getUser(currentuserid);
  }
  Future getuserInterst(userid) async{
    User currentUser=User();
    await _firestore.collection('users').document(userid).get().then((user){
      currentuser.name=user['name'];
      currentuser.photo=user['photourl'];
      currentUser.gender=user['gender'];
      currentuser.Interes=user['interestedin'];
    });
  }
  passUser(currentuserid,selecteduserid) async{
    await _firestore.collection('users').document(selectedUserId).collection('chosenList').document(currentUserId).setData({});

    await _firestore.collection('users').document(currentUserId).collection('chosenList').document(selectedUserId).setData({});
    
  }
  
  Future getChoosenList(userId) async{
    List<String> chosenList=[];
    await _firestore
    .collection('users')
    .doc(userId)
    .collection('chosenlist')
    .getDocuments()
    .then(
        (docs){
          for(var doc in docs.documents){
            if(docs.documents !=null)
              {
                chosenList.add(doc.documentId);
              }
          }
        }
    );
    return chosenList;
  }

  Future<User> getUser(userid) async{
    User _user=User();
    List<String> chosenList =await getChosenList(userId);
    currentuser=await getUserInterst(userId);
    await _firestore.collection('users').getDocuments().then(users){
      for(var user in users.documents){
        if((!chosenList.contains(user.documentId)) && (user.documentid != userid) && (currenntuser.InterestedIn ==user[gender]&& (user['InterestedIN']==currentuser.gender))
        {
          _user.uid==user.documentId;
          _user.name=user['name'];
          _user.photo=user['photoUrl'];
          _user.age=user['age'];
          _user.location=user['location'];
          +user.gender=user['gender'];
          _user.inrn==
        break;
        })
      }
    });
return user;

  }


  Stream<QuerySnapshot> getMatchedList(userId){
    return _firestore.collection('users').doc(userid).collection('matchedList').snapshots();
  }
  Stream<QuerySnapshot> getSelectedList(userId){
    return _firestore.collection('users').doc(userid).collection('selectedlits').snapshots();
  }
  Future openChat({currentuserid,selecteduserid}) async{
    await _firestore.collection('users').doc(currentuserid).collection('chats').doc(selecteduserid).setData({
      'timestamp':DateTime.now(),

    });
    await _firestore.collection('users').doc(currentuserid).collection('chats').doc(selecteduserid).setData({
      'timestamp':DateTime.now(),

    });
    await _firestore.collection('users').doc(currentuserid).collection('matchedList').doc(selecteduserid).delete();
    await _firestore.collection('users').doc(selecteduserid).collection('matchedList').doc(currentuserid).delete();
  }
  void deleteUser(currentuserid,selecteduserid) async{
    return await _firestore.collection('users').doc(currentuserid).collection('selectedList').doc(selecteduserid).delete();
  }
  Future selectUser(currentUserid, selecteduserid,currentUsername,currentuserphotourl,selectedusername,selecteduserphotourl) async{
    deleteUser(currentUserid,selecteduserid);
    await _firestore.collection('users').doc(currentuserid).collection('matchedList').doc(selecteduserid).setData({
      'name':selectedusername,
      'photousrl':selectedPhototurl,
    });
    return await _firestore.collection('users').doc(selecteduserid).collection('matchedList').doc(currentUserid).setData({
    'name':selectedusername,
    'photousrl':selectedPhototurl,
    });
  }
  {

  }
}*/