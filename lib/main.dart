import 'package:flutter/material.dart';
import 'package:outdoor_pass/ChiefWardenMainPage/chiefWardenMainActivity.dart';
import 'package:outdoor_pass/sign_up/login_page.dart';
import 'package:outdoor_pass/sign_up/sign_up_page.dart';
import 'package:outdoor_pass/sign_up/welcom_screen.dart';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outdoor_pass/TeacherMainPage/teachers_activity.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MaterialApp(
    title: "Online Outdoor pass",
    home: FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else if (snapshot.data == null)
                return welcome_screen();
              else{
                // ignore: missing_return
                if(snapshot.data.email.contains('teacheratmuj')){
                  return teachers_activity(
                    teacherID: '${snapshot.data.uid}',
                  );
                }
                // ignore: missing_return
                else if(snapshot.data.email.contains('manipal')){
                  return myActivitiesPage(
                    userID: '${snapshot.data.uid}',
                  );
                }
                else if(snapshot.data.email.contains('wardenatmuj')){
                  return chiefWardenMainActivity(
                    WardenID: '${snapshot.data.uid}',
                  );
                }
              }
          }
        }),
    debugShowCheckedModeBanner: false,
  ));
}