import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:outdoor_pass/ChiefWardenMainPage/chiefWardenMainActivity.dart';
import 'package:outdoor_pass/sign_up/login_page.dart';
import 'package:outdoor_pass/sign_up/sign_up_page.dart';
import 'package:outdoor_pass/Outpass/formFilling.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_pass/TeacherMainPage/teachers_activity.dart';


class full_outpass_display extends StatefulWidget{

  final DocumentSnapshot outpassSnapshot;
  final String userName,block,branch,course,mobile,registration_no,room,profile;
  final String hero_id;

  final int whichStage;

  const full_outpass_display({Key key, this.outpassSnapshot, this.userName, this.block, this.branch, this.course, this.mobile, this.registration_no, this.room, this.profile, this.hero_id, this.whichStage}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new full_outpass_displayState();
  }

}

class full_outpass_displayState extends State<full_outpass_display>{

  int updating=0;
  int updatingApproval=0;

  //Only for teachers, to allow disallow the pass
  Future<bool> disapprovePrompt(int n) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            title: (n==0)?Text('Are you sure you want to disapprove the outdoor pass?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17.5,
                fontWeight: FontWeight.w400
              ),
            ):Text('Are you sure you want to approve the outdoor pass?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w400
              ),
            ),

            actions: <Widget>[

              GestureDetector(
                child: Container(
                  width: 100.0,
                  child: Text("No",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                      fontSize: 17.5
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.of(context).pop();
                },
              ),

              GestureDetector(
                  child: Container(
                    width: 100.0,
                    child: Text("Yes",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w400,
                          fontSize: 17.5
                      ),
                    ),
                  ),
                onTap: () async{
                    if(n==0){
                      setState(() {
                        updating=1;
                      });
                      await disapproveOutdoorPass();
                      Navigator.of(context).pop();
                    }
                    if(n==1){
                      setState(() {
                        updatingApproval=1;
                      });
                      await approveOutdoorPass();
                      Navigator.of(context).pop();
                    }
                },
              ),

            ],

          );
        }
    );
  }

  //Only for teachers if they disapprove the outpass
  void disapproveOutdoorPass() async {
    if (widget.whichStage == 2) {
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;

      Firestore.instance.collection('Users')
          .document('${widget.outpassSnapshot['user_id']}')
          .collection('Outpasses').document(
          '${widget.outpassSnapshot.documentID}')
          .updateData({
        'approved': false,
        'transaction': 'finished',
        'stage': 'Cancelled'
      }).whenComplete(() {
        Firestore.instance.collection('Teachers')
            .document('${uid}')
            .collection('studentOutpasses').document(
            '${widget.outpassSnapshot.documentID}')
            .updateData({
          'approved': false,
          'transaction': 'finished',
          'stage': 'Cancelled by HOD'
        }).whenComplete(() {
          setState(() {
            updating = 0;
          });
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder:
                  (BuildContext) =>
              new teachers_activity(
                teacherID: '${uid}',
              ))
          );
          Navigator.of(context).pop();
        });
      }).catchError((error) {
        setState(() {
          updating = 0;
        });
        Fluttertoast.showToast(
            msg: '${error}',
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.white.withOpacity(0.5),
            textColor: Colors.red
        );
      });
    }
    if (widget.whichStage == 3) {
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final uid = user.uid;

      Firestore.instance.collection('Users')
          .document('${widget.outpassSnapshot['user_id']}')
          .collection('Outpasses').document(
          '${widget.outpassSnapshot.documentID}')
          .updateData({
        'approved': false,
        'transaction': 'finished',
        'stage': 'Cancelled'
      }).whenComplete(() {
        Firestore.instance.collection('ChiefWarden')
            .document('${uid}')
            .collection('StudentOutpasses').document(
            '${widget.outpassSnapshot.documentID}')
            .updateData({
          'approved': false,
          'transaction': 'finished',
          'stage': 'Cancelled by Chief Warden'
        }).whenComplete(() {
          Firestore.instance.collection('Teacher')
              .document('${widget.outpassSnapshot['HOD_id']}')
              .collection('StudentOutpasses').document(
              '${widget.outpassSnapshot.documentID}')
              .updateData({
            'approved': false,
            'transaction': 'finished',
            'stage': 'Cancelled by Chief Warden'
          }).whenComplete(() {
            setState(() {
              updating = 0;
            });
            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder:
                    (BuildContext) =>
                new teachers_activity(
                  teacherID: '${uid}',
                ))
            );
            Navigator.of(context).pop();
          });
        }).catchError((error) {
          setState(() {
            updating = 0;
          });
          Fluttertoast.showToast(
              msg: '${error}',
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.white.withOpacity(0.5),
              textColor: Colors.red
          );
        });
      });
    }
  }



  //Only for teachers if they approve the outpass
  void approveOutdoorPass() async{
    if(widget.whichStage==2){
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final teacher_uid = user.uid;

      Firestore.instance.collection('Users')
          .document('${widget.outpassSnapshot['user_id']}')
          .collection('Outpasses').document('${widget.outpassSnapshot.documentID}')
          .updateData({
        'approved':false,
        'stage':'Sent to Chief Warden',
        'transaction':'Finished from teacehrs side'
      }).whenComplete((){
        Firestore.instance.collection('Teachers')
            .document('${teacher_uid}')
            .collection('studentOutpasses').document('${widget.outpassSnapshot.documentID}')
            .updateData({
          'approved':false,
          'stage':'Sent to Chief Warden',
          'transaction':'Finished from teacehrs side'
        }).whenComplete((){
          Firestore.instance.collection('ChiefWarden')
              .document('Imdng0UTAQVHWL5teeFEabMcXJL2')
              .collection('StudentOutpasses')
              .document('${widget.outpassSnapshot.documentID}')
              .setData({
            'student_registration_no':'${widget.outpassSnapshot['student_registration_no']}',
            'user_name':'${widget.outpassSnapshot['user_name']}',
            'user_profile':'${widget.outpassSnapshot['user_profile']}',
            'user_id':'${widget.outpassSnapshot['user_id']}',
            'fromDate':'${widget.outpassSnapshot['fromDate']}',
            'toDate':'${widget.outpassSnapshot['toDate']}',
            'outgoing_time':'${widget.outpassSnapshot['outgoing_time']}',
            'modeOfTransport':'${widget.outpassSnapshot['modeOfTransport']}',
            'reason':'${widget.outpassSnapshot['reason']}',
            'whereState':'${widget.outpassSnapshot['whereState']}',
            'whereCity':'${widget.outpassSnapshot['whereCity']}',
            'approved':false,
            'stage':'With Chief Warden',
            'Warden_sent_to':'Imdng0UTAQVHWL5teeFEabMcXJL2',
            'transaction':'inProgress',
            'issued_date':'${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            'teacher_id':'${teacher_uid}'
          }).whenComplete((){
            setState(() {
              updatingApproval=0;
            });
            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder:
                    (BuildContext)=>new teachers_activity(
                  teacherID: '${teacher_uid}',
                ))
            );
          });
          Navigator.of(context).pop();
        });
      }).catchError((error){
        setState(() {
          updatingApproval = 0;
        });
        Fluttertoast.showToast(
            msg: '${error}',
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.white.withOpacity(0.5),
            textColor: Colors.red
        );
      });
    }
    if(widget.whichStage==3){
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final warden_uid = user.uid;

      Firestore.instance.collection('Users')
          .document('${widget.outpassSnapshot['user_id']}')
          .collection('Outpasses').document('${widget.outpassSnapshot.documentID}')
          .updateData({
        'approved':true,
        'stage':'At Chief Warden',
        'transaction':'Finished'
      }).whenComplete((){
        Firestore.instance.collection('Teachers')
            .document('${widget.outpassSnapshot['HOD_id']}')
            .collection('studentOutpasses').document('${widget.outpassSnapshot.documentID}')
            .updateData({
          'approved':true,
          'stage':'At Chief Warden',
          'transaction':'Finished'
        }).whenComplete((){
          Firestore.instance.collection('ChiefWarden')
              .document('Imdng0UTAQVHWL5teeFEabMcXJL2')
              .collection('StudentOutpasses')
              .document('${widget.outpassSnapshot.documentID}')
              .updateData({
            'approved':true,
            'transaction':'Finished'
          }).whenComplete((){
            setState(() {
              updatingApproval=0;
            });
            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder:
                    (BuildContext)=>new chiefWardenMainActivity(
                  WardenID: '${warden_uid}',
                ))
            );
          });
          Navigator.of(context).pop();
        });
      }).catchError((error){
        setState(() {
          updatingApproval = 0;
        });
        Fluttertoast.showToast(
            msg: '${error}',
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.white.withOpacity(0.5),
            textColor: Colors.red
        );
      });
    }
  }


  Widget _outpassBody(){
    return Container(
      child: ListView(
        children: <Widget>[

          //To show profile picture and name
          Container(
//            height: 200,
//            width: 200,
            child: ListTile(
              leading: Hero(
                tag: "p1",
                child: (widget.profile!='null')?CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider('${widget.profile}'),
                  radius: 25.0,
                ):CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.yellow.withOpacity(0.85),
                  foregroundColor: Colors.yellow.withOpacity(0.85),
                  child: Center(
                    child: Text('${widget.userName}'.substring(0,1),
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
              title: Text('${widget.userName}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text('${widget.branch}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Text('${widget.course}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Text('${widget.registration_no}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                ],
              ),

              trailing: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${widget.block}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),

                  Text('${widget.room}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        fontStyle: FontStyle.normal
                    ),
                  ),
                ],
              ),

            ),
          ),

          SizedBox(height: 25.0,),

          Container(
            margin: EdgeInsets.all(10.0),
            child: Text('Travelling ..',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300
              ),
            ),
          ),

          Container(
            //margin: EdgeInsets.only(left: 5.0,right: 5.0,top: 5.0),
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
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),

                (widget.outpassSnapshot['modeOfTransport']=='Flight')?Hero(tag: "flight${widget.hero_id}", child: Icon(Icons.flight_takeoff,size: 45.0,color: Colors.white,)):
                (
                    (widget.outpassSnapshot['modeOfTransport']=='Bus')?Hero(tag: "bus${widget.hero_id}", child: Icon(Icons.directions_bus,size: 45.0,color: Colors.white,)):
                    (
                        (widget.outpassSnapshot['modeOfTransport']=='Car')?Hero(tag: "car${widget.hero_id}", child: Icon(Icons.directions_car,size: 45.0,color: Colors.white,)):
                        (
                            (widget.outpassSnapshot['modeOfTransport']=='Train')?Hero(tag: "train${widget.hero_id}", child: Icon(Icons.train,size: 45.0,color: Colors.white,)):Icons.clear
                        )
                    )
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${widget.outpassSnapshot['whereCity']},\n'
                        '${widget.outpassSnapshot['whereState']}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                  ],
                )

              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 30.0,left: 10.0,right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text('Outgoing date ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text('${widget.outpassSnapshot['fromDate']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text('Incoming date',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text('${widget.outpassSnapshot['toDate']}',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.0,
                          fontStyle: FontStyle.normal
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),


          Container(
            margin: EdgeInsets.only(top: 15.0,left: 10.0,bottom: 5.0),
            child: Text('Outgoing time',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300
              ),
            ),
          ),


          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Text('${widget.outpassSnapshot['outgoing_time']}',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 15.0,left: 10.0,bottom: 5.0),
            child: Text('Reason',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300
              ),
            ),
          ),


          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Text('${widget.outpassSnapshot['reason']}',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                  fontStyle: FontStyle.normal
              ),
            ),
          ),

          SizedBox(height: 10.0,),

          Container(
            margin: EdgeInsets.only(top: 15.0,left: 10.0,bottom: 5.0),
            child: Text('Status',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700
              ),
            ),
          ),

          (widget.whichStage==1)?Container(
            height: 100.0,
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: (widget.outpassSnapshot['approved']==true)?Colors.green:
                (widget.outpassSnapshot['approved']==false && widget.outpassSnapshot['stage']!='Cancelled')?(Colors.blue):Colors.red
              ),
              color: (widget.outpassSnapshot['approved']==true)?Colors.green:
              (widget.outpassSnapshot['approved']==false && widget.outpassSnapshot['stage']!='Cancelled')?(Colors.blue):Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (widget.outpassSnapshot['approved']==true)?Colors.green:
                  (widget.outpassSnapshot['approved']==false && widget.outpassSnapshot['stage']!='Cancelled')?(Colors.blue):Colors.red,
                  blurRadius: 5.0
                )
              ]
            ),
            child: Center(
              child:(widget.outpassSnapshot['approved']==true)?Text('APPROVED',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontStyle: FontStyle.normal,
                    //fontWeight: FontWeight.w700
                ),
              ):Text('${widget.outpassSnapshot['stage']}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700
                ),
              )
            ),
          ):((widget.whichStage==2)?Container(
              //Give two option button for teachers to approve or disaprove
              margin: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[

                  GestureDetector(
                    child: Container(
                      height: 70.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.green,
                        ),
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            blurRadius:5.0
                          )
                        ]
                      ),
                      child: Center(
                        child:(updatingApproval==0)?Text('Approve,Send to Chief Warden',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.5
                          ),
                        ):Container(
                          height: 50.0,
                          width: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    onTap:(updatingApproval==0)?()async{
                      await disapprovePrompt(1);
                    }:(){},
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  GestureDetector(
                    child: Container(
                      height: 70.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.red,
                          ),
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.red,
                                blurRadius:5.0
                            )
                          ]
                      ),
                      child: Center(
                        child:(updating==0)?Text('Not approve',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.5
                          ),
                        ):Container(
                          height: 50.0,
                          width: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    onTap: (updating==0)?()async{
                      await disapprovePrompt(0);
                    }:(){},
                  ),


                ],
              ),
            ):Container(
            margin: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                GestureDetector(
                  child: Container(
                    height: 70.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.green,
                        ),
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green,
                              blurRadius:5.0
                          )
                        ]
                    ),
                    child: Center(
                      child:(updatingApproval==0)?Text('APPROVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.5
                        ),
                      ):Container(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  ),
                  onTap:(updatingApproval==0)?()async{
                    await disapprovePrompt(1);
                  }:(){},
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                GestureDetector(
                  child: Container(
                    height: 70.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.red,
                        ),
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red,
                              blurRadius:5.0
                          )
                        ]
                    ),
                    child: Center(
                      child:(updating==0)?Text('Not approve',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.5
                        ),
                      ):Container(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  ),
                  onTap: (updating==0)?()async{
                    await disapprovePrompt(0);
                  }:(){},
                ),


              ],
            ),
          )
          ),

        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('images/background.jpg'),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.overlay)
            )
        ),
        child: Container(
          height: 290.0,
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

          child: _outpassBody(),

        ),
      ),
    );
  }
}