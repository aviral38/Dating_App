
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:matri_app/age_notifier.dart';
import 'package:matri_app/distance_provider.dart';
import 'package:matri_app/user/user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'user/use.dart';
import 'package:matri_app/widgets/profile.dart';
class Matching extends StatefulWidget {
  final Usersclass current_user;
  Matching({this.current_user});

  @override
  _MatchingState createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {
  Future<Usersclass> get_otheruser(int dis,int minage,int maxage) async{
    String uid=_firebaseAuth.currentUser.uid;
    idd=uid;
    m=await getUser2(uid,dis,minage,maxage);

    //print(m.name);
    /*if(m.name==null)
    {
      print("no user left");
    }
    else{
      print(m.name);
    }*/
    return m;

  }
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Usersclass m=new Usersclass();
  String idd;



  Future<Usersclass> getUser2(String userid,int dis,int minage,int maxage) async {
   // print('kkkkkk '+minage.toString());
    bool iserror=false;
    Usersclass _user=new Usersclass();
    List<String> chosenList = await getselectedList(userid);
    List<String> leftSwipeList = await getLeftSwipeList(userid);
    Usersclass currentuser=new Usersclass();
    currentuser = await getCurrentUser(userid);
    await _firestore.collection('users').get().then((users) {
      for (var user in users.docs) {
        Timestamp age_user=user['age'];
        int ager=DateTime.now().year-age_user.toDate().year;
        GeoPoint p=user['location'];
        int diff=(Geolocator.distanceBetween(widget.current_user.location.latitude, widget.current_user.location.longitude, p.latitude, p.longitude)/1000).toInt();
        if ((chosenList.contains(user['uid'])==false) &&(leftSwipeList.contains(user['uid'])==false) && (user['uid'] != userid) &&
            (currentuser.interested == user['gender']) && (diff<=dis) && (ager>=minage) && (ager<=maxage) &&
            (user['interestedIn'] == currentuser.gender)) {
          print(user['name']);
          _user.uid = user['uid'];
          _user.name = user['name'];
          _user.photo = user['photourl'];
          _user.age = user['age'];
          _user.location = user['location'];
          _user.gender = user['gender'];
          _user.interested = user['interestedIn'];
          break;
        }

      }
      print('My bae '+_user.name);

    }).onError((error, stackTrace) {iserror=true;});
    return _user;
  }


  Future<Usersclass> getCurrentUser(String userid) async
  {
    Usersclass currentUser=new Usersclass();
    await _firestore.collection('users').doc(userid).get().then((user) {
      currentUser.name = user['name'];
      currentUser.photo = user['photourl'];
      currentUser.gender = user['gender'];
      currentUser.interested = user['interestedIn'];
    });
    return currentUser;
  }


  Future<Usersclass> getUser(String userid) async {
    bool iserror=false;
    Usersclass _user=new Usersclass();
    List<String> chosenList = await getselectedList(userid);
    List<String> leftSwipeList = await getLeftSwipeList(userid);
    Usersclass currentuser=new Usersclass();
    currentuser = await getCurrentUser(userid);
    await _firestore.collection('users').get().then((users) {
      for (var user in users.docs) {
        if ((chosenList.contains(user['uid'])==false) &&(leftSwipeList.contains(user['uid'])==false) && (user['uid'] != userid) &&
            (currentuser.interested == user['gender']) &&
            (user['interestedIn'] == currentuser.gender)) {
          print(user['name']);
          _user.uid = user['uid'];
          _user.name = user['name'];
          _user.photo = user['photourl'];
          _user.age = user['age'];
          _user.location = user['location'];
          _user.gender = user['gender'];
          _user.interested = user['interestedIn'];
          break;
        }

      }
      print('My bae '+_user.name);

    }).onError((error, stackTrace) {iserror=true;});
    return _user;
  }
  Future<void> checking(String userid) async{

    await _firestore.collection('users').get().then((users) {
      for (var user in users.docs) {
        print('hr ');
        print(user['name']);
      }
    });
  }



  Future getChosenList(String userid) async {
    List<String> chosenList = [];
    await _firestore.collection('users')
        .doc(userid)
        .collection('chosenList')
        .get()
        .then((document) {
      for (var doc in document.docs) {
        if (document.docs != null) {
          chosenList.add(doc.id);
        }
      }
    });
    return chosenList;
  }

  Future getLeftSwipeList(String userid) async {
    List<String> leftSwipeList = [];
    await _firestore.collection('users')
        .doc(userid)
        .collection('LeftSwipe')
        .get()
        .then((document) {
      for (var doc in document.docs) {
        if (document.docs != null) {
          leftSwipeList.add(doc.id);
        }
      }
    });
    return leftSwipeList;
  }

  Future getselectedList(String userid) async {
    List<String> chosenList = [];
    await _firestore.collection('users')
        .doc(userid)
        .collection('selectedList')
        .get()
        .then((document) {
      for (var doc in document.docs) {
        if (document.docs != null) {
          chosenList.add(doc.id);
        }
      }
    });
    return chosenList;
  }
  Future <bool> ismatch(String currentUserId,String selectUserId) async{
    bool match=false;
    await _firestore.collection('users').doc(selectUserId).collection(
        'selectedList').get().then((users){
          for(var user in users.docs)
            {
              if(user.id==currentUserId)
                {
                  match=true;
                }
            }
    } );
    return match;

  }
  chooseUser(currentUserId, selectUserId, name, photoUrl) async {
    await _firestore.collection('users').doc(currentUserId).collection(
        'selectedList').doc(selectUserId).set({
      'name': name,
      'photoUrl': photoUrl,
    });
  }
  Future<void> matched(currentUserId, selectUserId, currentUserName, currentUserphotoUrl,selectUserName,selectUserphotourl) async {
    print('yess');
    await _firestore.collection('users').doc(currentUserId).collection(
        'matchedList').doc(selectUserId).set({
      'name': selectUserName,
      'photoUrl': selectUserphotourl,
      'timestamp':Timestamp.now(),
    });
    await _firestore.collection('users').doc(selectUserId).collection(
        'matchedList').doc(currentUserId).set({
      'name': currentUserName,
      'photoUrl': currentUserphotoUrl,
      'timestamp':Timestamp.now(),
    });
    print('yess1234');
  }
  Future<void> swipedLeft(String currentUserId,String selectUserId) async{
    await _firestore.collection('users').doc(currentUserId).collection(
        'LeftSwipe').doc(selectUserId).set({'id':selectUserId,});
  }

  void onDragEnd(DraggableDetails details,Usersclass user) async
  {
    final minimumDrag=100;
    if(details.offset.dx>minimumDrag)
      {
        setState(() {
          show_spinner=true;
        });
        await chooseUser(idd, user.uid, user.name, user.photo);
        bool match=await ismatch(idd,user.uid);

        if(match==true)
          {
            Usersclass currentuser=new Usersclass();
            currentuser = await getCurrentUser(idd);
            await matched(idd, user.uid, currentuser.name, currentuser.photo, user.name, user.photo);

          }
        setState(() {
          show_spinner=false;
        });
      }
    else if(details.offset.dx<minimumDrag)
      {
        //user is liked
        setState(() {
          show_spinner=true;
        });
        swipedLeft(idd, user.uid);
        setState(() {
          show_spinner=false;
        });
      }
    setState(() {

    });
  }
  bool show_spinner=false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Material(
      color: Colors.white,
      child: ModalProgressHUD(
        inAsyncCall: show_spinner,
        child: Consumer<Distance_provider>(
          builder: (context,distance,child){
            return Consumer<Age_provider>(
              builder: (context,age,child){
                return FutureBuilder(
                  future: get_otheruser(distance.distance,age.minage,age.maxage),
                  builder: (context,snapshot) {
                    if(snapshot.data!=null)
                    {
                      Usersclass _user=new Usersclass();
                      _user=snapshot.data;
                      //print(widget.current_user.location.latitude.toString());


                      if(snapshot.data.name==null)
                      {
                        return Center(child: Text("No more user "));
                      }
                      else
                      {
                        int distance=(Geolocator.distanceBetween(widget.current_user.location.latitude, widget.current_user.location.longitude, _user.location.latitude, _user.location.longitude)/1000).toInt();
                        return ListView(
                          children: [
                            Column(
                              children: [
                                profileWidget(
                                  padding: height*0.035,
                                  photoHeight: height*0.8,
                                  photo: m.photo,
                                  clipRadius: height*0.02,
                                  containerHeight: height*0.3,
                                  containerWidth: width*0.9,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: height*0.02),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: height*0.07,),
                                        Text(" "+_user.name.toUpperCase()+", "+(DateTime.now().year-_user.age.toDate().year).toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: height*0.04
                                          ),),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.white,
                                            ),
                                            Text(distance.toString()+" km away",style: TextStyle(
                                                color: Colors.white,
                                                fontSize: height*0.03
                                            ),),

                                          ],
                                        ),
                                        Text(_user.gender,style: TextStyle(fontSize: height*0.03,color: Colors.white),),
                                        SizedBox(height: height*0.03,),
                                        Row(children: [
                                          Container(
                                            width: width*0.35,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50.0),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0x4d000000),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 50,
                                                ),
                                              ],
                                            ),
                                            child: FlatButton(child: Text(
                                              'Decline',
                                              style: TextStyle(
                                                fontFamily: 'Sen',
                                                fontSize: height*0.02,
                                                color: Color(0xffEC498A),
                                                fontWeight: FontWeight.w700,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                              onPressed: (){
                                                setState(() {
                                                  show_spinner=true;
                                                });
                                                swipedLeft(widget.current_user.uid, _user.uid);
                                                setState(() {
                                                  show_spinner=false;
                                                });
                                              },),
                                          ),
                                          SizedBox(width: width*0.07,),
                                          Container(
                                            width: width*0.35,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50.0),
                                              gradient: LinearGradient(

                                                colors: [const Color(0xffec498a), const Color(0xffc51f61)],
                                                stops: [0.0, 1.0],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0x4d000000),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 50,
                                                ),
                                              ],
                                            ),
                                            child: FlatButton(
                                              onPressed: ()async{
                                                setState(() {
                                                  show_spinner=true;
                                                });
                                                await chooseUser(widget.current_user.uid, _user.uid, _user.name, _user.photo);
                                                bool match=await ismatch(widget.current_user.uid,_user.uid);

                                                if(match==true)
                                                {

                                                  await matched(widget.current_user.uid, _user.uid, widget.current_user.name, widget.current_user.photo, _user.name, _user.photo);

                                                }

                                                setState(() {
                                                  show_spinner=false;
                                                });
                                              },
                                              child: Text(
                                                'Connect',
                                                style: TextStyle(
                                                  fontFamily: 'Sen',
                                                  fontSize: height*0.02,
                                                  color: const Color(0xffffffff),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                        ],)

                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        );
                      }
                    }
                    return Column(
                        children: [
                          Container(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.orange,
                              strokeWidth: 10,
                            ),
                            height: height/2,
                            width: width,
                          ),
                        ]
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
    return Material(child: Column(
      children: [
        Center(child: MaterialButton(color: Colors.blue,onPressed: ()async{
          String uid=_firebaseAuth.currentUser.uid;
          //await getUser(uid);
          //Usersclass g=new Usersclass();

           //g=await getCurrentUser(uid);
          m=await getUser(uid);
          //g=getUser(uid) as Usersclass;
          //await checking(uid);
          //await getUser(uid);

          //print(m.name);
          if(m.name==null)
            {
              print("no user left");
            }
          else{
            print(m.name);
          }
          print("done");

        },),
        ),
        MaterialButton(color:Colors.orange,onPressed: ()async{
          String uid=_firebaseAuth.currentUser.uid;
          //print(m.uid);
          //await choosingUser(uid, m.uid, m.name, m.photo);
          List<String> chosenList = await getselectedList(uid);
          print(chosenList);
          print("pjj");
        }),
        if(m.name!=null)
          profileWidget(
            padding: height*0.035,
            photoHeight: height*0.824,
            photo: m.photo,
            clipRadius: height*0.02,
            containerHeight: height*0.3,
            containerWidth: width*0.9,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height*0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height*0.07,),
                  Row(
                    children: [

                    ],
                  )
                ],
              ),
            )
          ),
      ],
    ),
    );

  }
}
