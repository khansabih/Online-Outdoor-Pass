import 'package:flutter/material.dart';
import 'sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';
import 'login_page.dart';
import 'package:outdoor_pass/TeachersPortal/teacher_login.dart';
import 'package:outdoor_pass/chiefwardenPortal/chiefWarden_sign_in.dart';

class welcome_screen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new welcome_screenState();
  }

}

class welcome_screenState extends State<welcome_screen>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('images/background.jpg'),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.overlay)
            )
        ),
        child: Container(
          margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*(1/4),
            left: 30.0,
            right: 30.0
          ),
          child: ListView(
            children: <Widget>[

              //Tile to show teachers portal
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left:5.0,right: 5.0,top: 6.5,bottom: 10.0),
//                    padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Colors.black.withOpacity(0.24),
                  ),
                  child: Container(
                    //margin: EdgeInsets.all(7.5),
                    height: 75.0,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        backgroundBlendMode: BlendMode.overlay,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            //blurRadius: 5.0
                          )
                        ]
                    ),
                    child: Center(
                      child: Text('TEACHERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context)=>new teacher_login()
                      )
                  );
                },
              ),

//                  Padding(padding: EdgeInsets.all(10.0),),

              //Tile to show student portal
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left:5.0,right: 5.0,top: 6.5,bottom: 10.0),
//                    padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Colors.black.withOpacity(0.24),
                  ),
                  child: Container(
                    //margin: EdgeInsets.all(7.5),
                    height: 75.0,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        backgroundBlendMode: BlendMode.overlay,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            //blurRadius: 5.0
                          )
                        ]
                    ),
                    child: Center(
                      child: Text('STUDENTS',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context)=>new login_page()
                      )
                  );
                },
              ),

              //Tile to show Chief warden portal
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left:5.0,right: 5.0,top: 6.5,bottom: 5.0),
//                    padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: Colors.black.withOpacity(0.24)
                  ),
                  child: Container(
                    //margin: EdgeInsets.all(7.5),
                    height: 75.0,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        backgroundBlendMode: BlendMode.overlay,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            //blurRadius: 5.0
                          )
                        ]
                    ),
                    child: Center(
                      child: Text('CHEIF WARDEN',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context)=>new chiefWarden_sign_in()
                      )
                  );
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}