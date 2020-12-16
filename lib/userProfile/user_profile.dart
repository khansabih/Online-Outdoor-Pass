import 'package:flutter/material.dart';
import 'package:outdoor_pass/sign_up/sign_up_page.dart';
import 'package:outdoor_pass/sign_up/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_pass/sign_up/welcom_screen.dart';
import 'update_profile.dart';

class user_profile extends StatefulWidget{

  final String user_Name,user_block,user_branch,user_course,user_mobile,user_registration_no,user_room,user_profile_pic;

  const user_profile({Key key, this.user_Name, this.user_block, this.user_branch, this.user_course, this.user_mobile, this.user_registration_no, this.user_room, this.user_profile_pic}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new user_profileState();
  }

}

class user_profileState extends State<user_profile> with TickerProviderStateMixin{

  bool edit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        child: Container(
          margin: EdgeInsets.only(top:50.0,bottom: 40.0,left: 20.0,right: 20.0),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
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
            child: Container(
              margin: EdgeInsets.only(left: 20.0,right: 20.0),
              child: ListView(
                children: <Widget>[

                  //For the user profile pic
                  Container(
//                      height: 150.0,
//                      width: 150.0,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (widget.user_profile_pic!='null')?CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider('${widget.user_profile_pic}'),
                            radius: 40.0,
                          ):CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.yellow.withOpacity(0.85),
                            foregroundColor: Colors.yellow.withOpacity(0.85),
                            child: Center(
                              child: Text('${widget.user_Name}'.substring(0,1),
                                style: TextStyle(
                                    color: Colors.black
                                ),
                              ),
                            ),
                          ),


                          GestureDetector(
                            child: Icon(Icons.power_settings_new,color: Colors.yellow.withOpacity(0.85),size: 30.0,),
                            onTap: (){
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(
                                    builder: (BuildContext context)=>new welcome_screen()
                                )
                              );
                            },
                          )

                        ],
                      )
                  ),

                  Padding(padding: EdgeInsets.all(7.0),),

                  //To display the name
                  Text('${widget.user_Name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 27.0,
                      fontStyle: FontStyle.normal
                    ),
                  ),

                  Text('${widget.user_registration_no}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(7.0),),

                  Divider(indent: 0.0,height:15.0,color: Colors.white,),

                  Padding(padding: EdgeInsets.all(7.0)),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Icon(Icons.local_library, size: 18.0, color: Colors.white,),
                      Text(' College details ',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                            fontStyle: FontStyle.normal
                        ),
                      ),

                    ],
                  ),

                  Padding(padding: EdgeInsets.all(5.0)),

//                  Text('Registration - ${widget.user_registration_no}',
//                    style: TextStyle(
//                        color: Colors.white,
//                        fontWeight: FontWeight.w300,
//                        fontSize: 20.0,
//                        fontStyle: FontStyle.normal
//                    ),
//                  ),

                  Text('Branch - ${widget.user_branch}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Text('Course - ${widget.user_course}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  //Padding(padding: EdgeInsets.all(5.0)),



                  Padding(padding: EdgeInsets.all(7.0),),

                  Divider(indent: 0.0,height:15.0,color: Colors.white,),

                  Padding(padding: EdgeInsets.all(7.0)),


                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Icon(Icons.call, size: 18.0, color: Colors.white,),
                      Text(' Contact details ',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                            fontStyle: FontStyle.normal
                        ),
                      ),

                    ],
                  ),

                  Padding(padding: EdgeInsets.all(5.0)),

                  Text('Mobile - ${widget.user_mobile}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(7.0),),

                  Divider(indent: 0.0,height:15.0,color: Colors.white,),

                  Padding(padding: EdgeInsets.all(7.0)),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Icon(Icons.business, size: 18.0, color: Colors.white,),
                      Text(' Hostel address ',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          fontStyle: FontStyle.normal
                      ),
                    ),

                    ],
                  ),

                  Padding(padding: EdgeInsets.all(5.0)),

                  Text('Block - ${widget.user_block}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Text('Room - ${widget.user_room}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(left:10.0, right:10.0, bottom: 10.0),
                    child: FloatingActionButton(
                      onPressed: (){
                        Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (BuildContext context)=>new update_profile(
                                user_Name: '${widget.user_Name}',
                                user_block: '${widget.user_block}',
                                user_profile_pic: '${widget.user_profile_pic}',
                                user_branch: '${widget.user_branch}',
                                user_course: '${widget.user_course}',
                                user_mobile: '${widget.user_mobile}',
                                user_registration_no: '${widget.user_registration_no}',
                                user_room: '${widget.user_room}',
                              )
                          )
                        );
                      },
                      child: Center(
                        child: Icon(Icons.edit,color: Colors.black,),),
                        backgroundColor: Colors.yellow.withOpacity(0.85),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}