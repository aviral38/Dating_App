import 'package:flutter/material.dart';
import 'package:matri_app/photo_widget.dart';
import 'package:matri_app/user/user.dart';
class Prof_page extends StatefulWidget {
  final Usersclass user;
  Prof_page({this.user});

  @override
  _Prof_pageState createState() => _Prof_pageState();
}

class _Prof_pageState extends State<Prof_page> {
  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return Material(
      child: Column(
        children: [
          SizedBox(height: size.height*0.08,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(child: Container(height: size.height*0.20,width: size.height*0.20,
                child: Photo_widget(
                  photolink: widget.user.photo,

                ),),),
            ],
          ),
          Container(
            child: CircleAvatar(backgroundColor:Colors.white,child: Image(image: AssetImage('images/pref.png'),),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12, spreadRadius: 5)],
            ),),


        ],
      ),
    );
  }
}

