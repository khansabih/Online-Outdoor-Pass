import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';
import 'teacher_sign_up.dart';
import 'package:outdoor_pass/TeacherMainPage/teachers_activity.dart';

class teacher_login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new teacher_loginState();
  }

}

class teacher_loginState extends State<teacher_login>{

  final TextEditingController _teacherReg = new TextEditingController();
  final TextEditingController _teacherPassword = new TextEditingController();

  int _loading=0;

  Future signInTheUser()async{

    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '${_teacherReg.text.toString().trimLeft().trimRight()}@teacheratmuj.com',
        password: _teacherPassword.text)

        .then((newTeacher){

      Navigator.of(context).pop();
      Navigator.of(context)
          .pushReplacement(new MaterialPageRoute(builder:
          (BuildContext context)=>new teachers_activity(
            teacherID: '${newTeacher.user.uid}',
        )
      ));

      setState(() {
        _loading=0;
      });

    }).catchError((error){
      setState(() {
        _loading=0;
      });

      Fluttertoast.showToast(
          msg: "${error}",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.blue.withOpacity(0.8),
          textColor: Colors.white
      );
    });

  }

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
        child: Center(
          child: Container(
            height: 375.0,
            margin: EdgeInsets.all(20.0),
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
            child: Container(
              margin: EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  TextField(
                    controller: _teacherReg,
                    decoration: InputDecoration(
                        hintText: "TEACHER ID",
                        hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white
                            )
                        )
                    ),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  TextField(
                    controller: _teacherPassword,
                    decoration: InputDecoration(
                        hintText: "PASSWORD",
                        hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white
                            )
                        )
                    ),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal
                    ),
                    obscureText: true,
                  ),

                  Padding(padding: EdgeInsets.all(15.0)),

                  (_loading==0)?GestureDetector(
                    child:Container(
                        height: 45.0,
                        width:MediaQuery.of(context).size.width*(1/3),
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 5.0
                              )
                            ]
                        ),
                        child:Center(
                          child:Text('LOGIN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal
                            ),
                          ),
                        )
                    ),
                    onTap: () async{
                      if(_teacherReg.text.toString().trimLeft().trimRight().length!=0 &&
                          _teacherPassword.text.toString().trimLeft().trimRight().length!=0
                      ){
                        setState(() {
                          _loading = 1;
                        });
                        await signInTheUser();
                      }
                      else{
                        Fluttertoast.showToast(
                            msg: "It seems you might not have filled some fields",
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_LONG,
                            backgroundColor: Colors.white.withOpacity(0.75),
                            textColor: Colors.black
                        );
                      }
                    },
                  ):Container(
                    height: 50.0,
                    width: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          Colors.white
                      ),
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  (_loading==0)?GestureDetector(
                    child: Container(
                      width: 200.0,
                      height: 50.0,
                      margin: EdgeInsets.all(10.0),
                      child: Text("Don't have an account?Sign up",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.normal
                        ),
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (BuildContext context)=>new teachers_sign_up()
                          )
                      );
                    },
                  ):Container()

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}