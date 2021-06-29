import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:matri_app/user/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'main_page.dart';

class Profile_page extends StatefulWidget {
  const Profile_page({Key key}) : super(key: key);

  @override
  _Profile_pageState createState() => _Profile_pageState();
}

class _Profile_pageState extends State<Profile_page> {
  String name;
  Usersclass currentUser=new Usersclass();
  DateTime age;
  String gender_val = 'male';
  String interest_val = "female";
  Position position;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  File photo;
  Image img = Image(image: AssetImage('images/craig.png'));
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



  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Future<void> profileSetup(
      File photo,
      String userId,
      String name,
      String gender,
      String InterestedIn,
      DateTime age,
      GeoPoint location) async {
    print(userId + " " + name);
    print(photo.toString());
    print(age.toString());
    print(location.longitude);
    FirebaseStorage storageUploadTask;
    /*var url = FirebaseStorage.instance
        .ref()
        .child('userPhotos')
        .child(userId)
        .child(userId)
        .putFile(photo)
        .snapshot
        .ref
        .getDownloadURL();*/
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('userPhotos')
        .child(userId)
        .child(userId)
        .putFile(photo)
        .whenComplete(() => null);
    String url = await snapshot.ref.getDownloadURL();
    currentUser.name = name;
    currentUser.gender = gender_val;
    currentUser.photo=url;
    currentUser.interested = InterestedIn;
    currentUser.uid=userId;
    currentUser.location=location;
    await firestore.collection('users').doc(userId).set({
      'uid': userId,
      'photourl': url,
      'name': name,
      'location': location,
      'gender': gender,
      'interestedIn': InterestedIn,
      'age': age
    });
  }
  Future<void> dialog(var a) async{
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(a),
            elevation: 24.0,
          );
        });
  }
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool show_spinner=false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: ModalProgressHUD(
        inAsyncCall: show_spinner,
        child: Container(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              child: Center(
                child: ListView(
                  padding: EdgeInsets.all(40),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          FilePickerResult result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );
                          if (result != null) {
                            photo = File(result.files.single.path);
                          } else {
// User canceled the picker
                          }
                          setState(() {

                          });
                        },
                        child: ClipOval(
                            child: Container(
                                height: size.height * 0.25,
                                width: size.height * 0.25,
                                child: photo == null
                                    ? Image(
                                        image: AssetImage('images/craig.png'),
                                      )
                                    : Image(image: FileImage(photo)),),),
                      ),
                    ),
                    SizedBox(height: size.height*0.07,),
                    Text(
                      'Your Name',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        color: const Color(0xffffffff),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 17,
                          color: const Color(0xa6ffffff),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your Name',
                          hintStyle: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 17,
                            color: const Color(0xa6ffffff),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height*0.04,),
                    Text(
                      'Your Gender',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        color: const Color(0xffffffff),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Center(
                      child: DropdownButton(
                        dropdownColor: Colors.blue,
                        iconSize: 40,
                        iconDisabledColor: Colors.orange,
                        iconEnabledColor: Colors.white,
                        items: <String>['male', 'female']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: gender_val,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        onChanged: (val) {
                          setState(() {
                            gender_val = val;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: size.height*0.04,),
                    Text(
                      'Interested In',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        color: const Color(0xffffffff),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Center(
                      child: DropdownButton(
                        dropdownColor: Colors.blue,
                        iconSize: 40,
                        iconDisabledColor: Colors.orange,
                        iconEnabledColor: Colors.white,
                        items: <String>['male', 'female']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: interest_val,
                        style:
                        const TextStyle(color: Colors.white, fontSize: 20),
                        onChanged: (val) {
                          setState(() {
                            interest_val = val;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: size.height*0.04,),
                    Text(
                      'Your Birthday',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        color: const Color(0xffffffff),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Center(
                      child: MaterialButton(
                          color: Color(0xffF24E86),
                          child: Text('open calender'),
                          onPressed: () {
                            DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              minTime: DateTime(1900, 1, 1),
                              maxTime:
                              DateTime(DateTime.now().year - 19, 1, 1),
                              onConfirm: (date) {
                                setState(() {
                                  age = date;
                                });
                              },
                            );
                          }),
                    ),
                    SizedBox(height: size.height*0.04,),
                    Center(
                      child: FlatButton(color: Color(0xffF24E86),
                      onPressed: ()async{
                        if (photo == null)
                          {
                            dialog('please choose a profile picture');
                          }

                        position = await _determinePosition().onError((error, stackTrace) { dialog(error.toString());});
                        print(position.toString());
                        GeoPoint pos=new GeoPoint(position.latitude, position.longitude);

                        String uid = _firebaseAuth.currentUser.uid;
                        setState(() {
                          show_spinner=true;
                        });
                        await profileSetup(
                            photo, uid, name, gender_val, interest_val, age, pos);



                      Navigator.push(context,MaterialPageRoute(builder: (context) => main_page(user: currentUser,),),);

                      }, child: Center(child: Text(
                        'Start Matching',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 24,
                          color: const Color(0xffffffff),
                        ),
                        textAlign: TextAlign.left,
                      ),)),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('images/background.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

/*
Material(
color: Colors.orange,
child: ListView(
children: [
Container(
child: TextField(
onChanged: (value) {
setState(() {
name = value;
});
},
),
),
DropdownButton(
items: <String>['male', 'female']
    .map<DropdownMenuItem<String>>((String value) {
return DropdownMenuItem<String>(
value: value,
child: Text(value),
);
}).toList(),
value: gender_val,
style: const TextStyle(color: Colors.deepPurple),
onChanged: (val) {
setState(() {
gender_val = val;
});
},
),
DropdownButton(
iconSize: 20,
items: <String>['male', 'female']
    .map<DropdownMenuItem<String>>((String value) {
return DropdownMenuItem<String>(
value: value,
child: Text(value),
);
}).toList(),
value: interest_val,
style: const TextStyle(color: Colors.deepPurple),
onChanged: (val) {
setState(() {
interest_val = val;
});
},
),
MaterialButton(color: Colors.blueAccent,
onPressed: () {
DatePicker.showDatePicker(
context,
showTitleActions: true,
minTime: DateTime(1900, 1, 1),
maxTime: DateTime(DateTime.now().year - 19, 1, 1),
onConfirm: (date) {
setState(() {
age = date;
});
},
);
}),

MaterialButton(
color: Colors.white,
onPressed: () async {
FilePickerResult result = await FilePicker.platform.pickFiles(
type: FileType.image,
);
if (result != null) {
photo = File(result.files.single.path);
} else {
// User canceled the picker
}
}),
MaterialButton(
color: Colors.white,
onPressed: () async {
position = await _determinePosition();
print(position.toString());
GeoPoint pos=new GeoPoint(position.latitude, position.longitude);

String uid = _firebaseAuth.currentUser.uid;
await profileSetup(
    photo, uid, name, gender_val, interest_val, age, pos);
Navigator.pushNamed(context, '/match');
}),
],
),
);
*/
