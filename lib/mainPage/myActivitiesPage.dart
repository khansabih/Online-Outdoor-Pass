import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:outdoor_pass/sign_up/login_page.dart';
import 'package:outdoor_pass/sign_up/sign_up_page.dart';
import 'package:outdoor_pass/Outpass/formFilling.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_pass/outpass_display/full_outpass_display.dart';
import 'package:outdoor_pass/userProfile/user_profile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';


class myActivitiesPage extends StatefulWidget{

  final String userID;

  const myActivitiesPage({Key key, this.userID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new myActivitiesPageState();
  }

}

class myActivitiesPageState extends State<myActivitiesPage>{

  String user_id,profile_pic,userName,block,branch,course,mobile,registration_no,room;

  void getUserID() async{
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final user_uid = user.uid;
    setState(() {
      user_id = user_uid;
    });

  }

  void getInfo(){
    Firestore.instance.collection('Users').document('${widget.userID}')
        .get().then((userDoc){
        setState(() {
          profile_pic = userDoc['profile_pic'];
          userName = userDoc['name'];
          block = userDoc['block'];
          branch = userDoc['branch'];
          course = userDoc['course'];
          mobile = userDoc['mobile'];
          registration_no = userDoc['registrationNo'];
          room = userDoc['room'];
        });
    });
  }

  Widget _mainBody(){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Users').
        document('${user_id}')
        .collection('Outpasses')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Center(
            child: new CircularProgressIndicator(
              backgroundColor: Colors.blue.shade900,
            ),
          );
          case ConnectionState.none: return Center(
            child: new CircularProgressIndicator(
              backgroundColor: Colors.blue.shade900,
            ),
          );
          default:
            return Container(
              child: new ListView(
                //shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      GestureDetector(
                        child: Icon(Icons.delete,size: 30.0,color: Colors.white,),
                        onTap: (){
                          Firestore.instance.collection('Users')
                              .document('${user_id}').collection('Outpasses')
                              .document('${document.documentID}')
                              .delete().whenComplete((){
                                Firestore.instance.collection('Teachers')
                                    .document('${document['HODid']}')
                                    .collection('studentOutpasses')
                                    .document('${document.documentID}')
                                    .delete().whenComplete((){
                                   Fluttertoast.showToast(
                                     msg: "Outpass successfully removed",
                                     textColor: Colors.black,
                                     backgroundColor: Colors.white,
                                     gravity: ToastGravity.CENTER
                                   );
                                });
                          }).catchError((error){

                          });
                        },
                      )
                    ],
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left:5.0,right: 5.0,top: 6.5,bottom: 5.0),
//                    padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            color: Colors.white.withOpacity(0.34)
                          ),
                        child: Container(
                          //margin: EdgeInsets.all(7.5),
                          height: 125.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.54),
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Container(
                                height:30.0,
                                width: 165.0,
                                margin: EdgeInsets.only(left: 12.0,top: 7.5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: (document['approved']==true)?Colors.green:
                                  (document['approved']==false && document['stage']!='Cancelled')?Colors.blue:Colors.red
                                ),
                                child: Center(
                                  child: (document['approved']==true)?Text('Approved',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ):Text('${document['stage']}',
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    )
                                  ),
                                ),
                              ),

                              Padding(padding: EdgeInsets.all(3.0)),

                              Container(
                                margin: EdgeInsets.only(left: 5.0,right: 5.0,top: 5.0),
                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        Container(
                                          child: Text('Jaipur,\n'
                                              'Rajasthan',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),

                                        Text('(${document['fromDate']})',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w500,
                                          ),
                                        ),



                                      ],
                                    ),

                                      (document['modeOfTransport']=='Flight')?Hero(tag: "flight${document.documentID}", child: Icon(Icons.flight_takeoff,size: 45.0,color: Colors.black,)):
                                      (
                                          (document['modeOfTransport']=='Bus')?Hero(tag: "bus${document.documentID}", child: Icon(Icons.directions_bus,size: 45.0,color: Colors.black,)):
                                          (
                                              (document['modeOfTransport']=='Car')?Hero(tag: "car${document.documentID}", child: Icon(Icons.directions_car,size: 45.0,color: Colors.black,)):
                                              (
                                                  (document['modeOfTransport']=='Train')?Hero(tag: "train${document.documentID}", child: Icon(Icons.train,size: 45.0,color: Colors.black,)):Icons.clear
                                              )
                                          )
                                      ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('${document['whereCity']},\n'
                                            '${document['whereState']}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),

                                        Text('(${document['toDate']})',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                      ],
                                    )

                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context)=>new full_outpass_display(
                            outpassSnapshot: document,
                            userName:'${userName}',
                            block:'${block}',
                            branch:'${branch}',
                            course:'${course}',
                            mobile:'${mobile}',
                            registration_no:'${registration_no}',
                            room:'${room}',
                            profile:'${profile_pic}',
                            hero_id: '${document.documentID}',
                            whichStage: 1,
                        )));

//                      Navigator.of(context).push(new PageRouteBuilder(
//                        transitionDuration: const Duration(milliseconds:500),
//                        pageBuilder: (BuildContext context,Animation<double> a1,Animation<double> a2){
//                          return new full_outpass_display(
//                            outpassSnapshot: document,
//                            userName:'${userName}',
//                            block:'${block}',
//                            branch:'${branch}',
//                            course:'${course}',
//                            mobile:'${mobile}',
//                            registration_no:'${registration_no}',
//                            room:'${room}',
//                            profile:'${profile_pic}',
//                            hero_id: '${document.documentID}',
//                          );
//                        }
//                      ));

                      },
                    ),
                  );
                }).toList(),
              ),
            );

        }
      },
    );
  }



//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState(){
    getUserID();
    getInfo();
//    _firebaseMessaging.getToken().then((tokenValue){
//      Firestore.instance.collection('NotifyingTokens')
//          .document('${widget.userID}').setData({
//        'notifying_token':'${tokenValue}'
//      });
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(

      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow.withOpacity(0.85),
          child: Center(
            child: Icon(Icons.add,color: Colors.black,),
          ),
          onPressed: (){
            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new formFilling(
              userID: widget.userID,
            )));
          }
      ),

//      drawer: Drawer(
//        child: Container(
//          child: ListView(
//            children: <Widget>[
//              Container(
//                margin: EdgeInsets.all(10.0),
//                child: GestureDetector(
//                  child: Hero(
//                      tag: "p1",
//                      child: (profile_pic!=null)?CircleAvatar(
//                        radius: 18.5,
//                        backgroundImage:CachedNetworkImageProvider('${profile_pic}'),
//                      ):Center(
//                        child:Icon(Icons.account_circle,color: Colors.black,size: 50.0,),
//                      )
//                  ),
//                  onTap: (){
//                    //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new user_profile()));
//                    Navigator.of(context).push(new PageRouteBuilder(
//                        transitionDuration: const Duration(milliseconds:500),
//                        pageBuilder: (BuildContext context,Animation<double> a1,Animation<double> a2){
//                          return new user_profile(
//                            user_Name:'${userName}',
//                            user_block:'${block}',
//                            user_branch:'${branch}',
//                            user_course:'${course}',
//                            user_mobile:'${mobile}',
//                            user_registration_no:'${registration_no}',
//                            user_room:'${room}',
//                            user_profile_pic:'${profile_pic}',
//                          );
//                        }
//                    ));
//
//                  },
//                ),
//              )
//            ],
//          ),
//        ),
//      ),

      body: Stack(
        children: <Widget>[

          Container(
              padding: EdgeInsets.only(top:85.0,left: 20.0,right: 20.0),
              decoration: BoxDecoration(
                //color: Colors.transparent,
                  image: DecorationImage(
                      image: AssetImage('images/background.jpg'),
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(Colors.black45.withOpacity(0.65), BlendMode.overlay)
                  )
              ),
              child:_mainBody(),
          ),

          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              //height: 85.0,
              child: AppBar(
                centerTitle: false,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                toolbarOpacity: 0.0,
                title:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('My Outdoor passes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),

                    //Padding(padding: EdgeInsets.all(10.0)),

                    Container(
                      //margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: Hero(
                            tag: "p1",
                            child: (profile_pic!=null)?CircleAvatar(
                              radius: 18.5,
                              backgroundImage:CachedNetworkImageProvider('${profile_pic}'),
                            ):CircleAvatar(
                              radius: 18.5,
                              backgroundColor: Colors.yellow.withOpacity(0.85),
                              child: Center(
                                child: Text('${userName}'.substring(0,1),
                                  style: TextStyle(
                                    color: Colors.black
                                  ),
                                ),
                              ),
                            )
                        ),
                        onTap: (){
                          //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new user_profile()));
                          Navigator.of(context).push(new MaterialPageRoute(
                              //transitionDuration: const Duration(milliseconds:500),
                              builder: (BuildContext context){
                                return new user_profile(
                                  user_Name:'${userName}',
                                  user_block:'${block}',
                                  user_branch:'${branch}',
                                  user_course:'${course}',
                                  user_mobile:'${mobile}',
                                  user_registration_no:'${registration_no}',
                                  user_room:'${room}',
                                  user_profile_pic:'${profile_pic}',
                                );
                              }
                          ));

                        },
                      ),
                    )
                  ],
                ),
                //centerTitle: false,

//                actions: <Widget>[
//
//                  Container(
//                    //margin: EdgeInsets.all(10.0),
//                    child: GestureDetector(
//                      child: Hero(
//                        tag: "p1",
//                        child: (profile_pic!=null)?CircleAvatar(
//                          radius: 18.5,
//                          backgroundImage:CachedNetworkImageProvider('${profile_pic}'),
//                        ):Icon(Icons.settings,size:100.0,color: Colors.white,)
//                      ),
//                      onTap: (){
//                        //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new user_profile()));
//                        Navigator.of(context).push(new PageRouteBuilder(
//                            transitionDuration: const Duration(milliseconds:500),
//                            pageBuilder: (BuildContext context,Animation<double> a1,Animation<double> a2){
//                              return new user_profile(
//                                user_Name:'${userName}',
//                                user_block:'${block}',
//                                user_branch:'${branch}',
//                                user_course:'${course}',
//                                user_mobile:'${mobile}',
//                                user_registration_no:'${registration_no}',
//                                user_room:'${room}',
//                                user_profile_pic:'${profile_pic}',
//                              );
//                            }
//                        ));
//
//                      },
//                    ),
//                  )
//
//                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}