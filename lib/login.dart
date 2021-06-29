import 'dart:ui';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:matri_app/main_page.dart';
import 'package:matri_app/message_page.dart';
import 'package:matri_app/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email,password;
  FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool show_spinner=false;
  Future<void> signIn(String email,String password) async
  {
    print(email+"  "+password);
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).onError((error, stackTrace) {print("err is "+error.toString());});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
    String uid=_firebaseAuth.currentUser.uid;
    print("uid isn "+uid);
    if(uid!=null)
      {
        Usersclass currentUser=new Usersclass();
        await _firestore.collection('users').doc(uid).get().then((user) {
          currentUser.name = user['name'];
          currentUser.photo = user['photourl'];
          currentUser.gender = user['gender'];
          currentUser.interested = user['interestedIn'];
          currentUser.uid=uid;
          currentUser.age=user['age'];
          currentUser.location=user['location'];
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => main_page(user: currentUser,),
            //builder: (context) => messages(userid: uid),
          ),
        );
        //Navigator.pushNamed(context, '/match');
      }
    //Position position=await _determinePosition();
    //print(position.latitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return Material(
      child: ModalProgressHUD(
        inAsyncCall: show_spinner,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('images/background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Center(
              child: ListView(
                padding: EdgeInsets.all(40),
                children: [
                  SizedBox(height: size.height*0.07,),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 40,
                      color: const Color(0xffffffff),
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: size.height*0.07,),
                  Text(
                    'EMAIL ADDRESS',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 22,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: size.height*0.03,),
                  Container(
                    height: 20,

                    child: TextField(
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 17,
                        color: const Color(0xa6ffffff),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your Email',
                        hintStyle: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 17,
                          color: const Color(0xa6ffffff),
                        ),
                      ),
                      onChanged: (value)
                      {
                        setState(() {
                          email=value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height*0.07,),
                  Text(
                    'PASSWORD',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 22,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: size.height*0.03,),
                  Container(
                    height: 20,
                    child: TextField(
                      onChanged: (value){
                        setState(() {
                          password=value;
                        });
                      },
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 17,
                        color: const Color(0xa6ffffff),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your Email',
                        hintStyle: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 17,
                          color: const Color(0xa6ffffff),
                        ),
                      ),
                    ),
                  ),
              SizedBox(height: size.height*0.07,),
              Center(
                child: MaterialButton(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    color: Color(0xffF24E86),
                    onPressed: () async {
                      setState(() {
                        show_spinner=true;
                      });
                      signIn(email, password);
                    }),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      Material(
      color: Colors.orange,
      child: Column(
        children: [
          SizedBox(height: 100,),
          Row(children: [
            Text("Email"),
            Container(
              height: 20,
              width: 250,
              child: TextField(
                onChanged: (value)
                {
                  setState(() {
                    email=value;
                  });
                },
                cursorWidth: 20,
                decoration: InputDecoration(
                  hintText: 'Enter your Email',
                ),
              ),
            ),
          ],),
          SizedBox(height: 30,),
          Row(children: [
            Text("Password"),
            Container(
              height: 20,
              width: 250,
              child: TextField(
                onChanged: (value){
                  setState(() {
                    password=value;
                  });
                },
                cursorWidth: 20,
                decoration: InputDecoration(
                  hintText: 'Enter your Password',
                ),
              ),
            ),
          ],),
          SizedBox(height: 30,),
          Row(children: [
            SizedBox(width: 100,),
            MaterialButton(child:Text('Submit'),color: Colors.white,onPressed: (){signIn(email, password);})
          ],)
        ],
      ),
    );
  }
}
