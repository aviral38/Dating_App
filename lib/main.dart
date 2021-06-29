import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:matri_app/age_notifier.dart';
import 'package:matri_app/distance_provider.dart';
import 'package:matri_app/first_page.dart';
import 'package:matri_app/user/user.dart';
import 'package:provider/provider.dart';
import 'main_page.dart';
import 'signup.dart';
import 'login.dart';
import 'match_page.dart';
import 'package:matri_app/profile_page.dart';
import 'message_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  Future<Usersclass> getLogin() async
  {
    Usersclass currentUser=new Usersclass();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('email')==false)
      {
        return currentUser;
      }
    String email = prefs.getString('email');
    String password=prefs.getString('password');
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).onError((error, stackTrace) {print("err is "+error.toString());});

    String uid=_firebaseAuth.currentUser.uid;

    await _firestore.collection('users').doc(uid).get().then((user) {
      currentUser.name = user['name'];
      currentUser.photo = user['photourl'];
      currentUser.gender = user['gender'];
      currentUser.interested = user['interestedIn'];
      currentUser.uid=uid;
      currentUser.age=user['age'];
      currentUser.location=user['location'];
    });
    return currentUser;
  }
  FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Age_provider>(
          create: (context) => Age_provider(),
        ),
        ChangeNotifierProvider<Distance_provider >(
          create: (context) => Distance_provider() ,
        ),
      ],
      child: FutureBuilder(
        future: getLogin(),
        builder:(context,snapshot) {
          if(snapshot.data!=null)
            {
              if(snapshot.data.name==null)
                {
                  return MaterialApp(
                    initialRoute: '/first',
                    routes: {
                      '/':(context)=>Signup(),
                      '/first':(context)=>First_page(),
                      '/login':(context)=>Login(),
                      '/profile':(context)=>Profile_page(),
                      '/match':(context)=>Matching(),
                      '/message':(context)=>messages(),
                    },
                  );
                }
              else
                {
                  return MaterialApp(
                    initialRoute: '/main_page',
                    routes: {
                      '/':(context)=>Signup(),
                      '/first':(context)=>First_page(),
                      '/login':(context)=>Login(),
                      '/profile':(context)=>Profile_page(),
                      '/match':(context)=>Matching(),
                      '/message':(context)=>messages(),
                      '/main_page':(context)=>main_page(user: snapshot.data,),
                    },
                  );
                }
            }
          return CircularProgressIndicator(
            backgroundColor: Colors.deepOrange,
          );}
      ),
    );
  }
}

