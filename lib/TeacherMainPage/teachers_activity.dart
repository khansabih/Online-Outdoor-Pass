import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';
import 'package:outdoor_pass/sign_up/welcom_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_pass/outpass_display/full_outpass_display.dart';
import 'teacher_profile.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

class teachers_activity extends StatefulWidget{

  final String teacherID;

  const teachers_activity({Key key, this.teacherID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new teachers_activityState();
  }

}

class teachers_activityState extends State<teachers_activity>{

  String techerName,teacherBranch,teacherCourse,teacherRegNo,teacherMobileNo,teacherProfile;
  String user_id,profile_pic,userName,block,branch,course,mobile,registration_no,room;

  //For outpass details
  String fromDate,toDate,outgoing_time,mode_of_transport,reason,whereState,whereCity,stage,
        HOD_name,transaction;
  bool approved;
  
  //To search a student
  final TextEditingController registrationNoOfStudent = new TextEditingController();

  //To get the student's details
  Future getStudentDetails(String userID,DocumentSnapshot outPass) async{
    Firestore.instance.collection('Users')
        .document('${userID}').get().then((studentDoc){
        setState(() {
          user_id = '${userID}';
          profile_pic = '${studentDoc['profile_pic']}';
          userName = '${studentDoc['name']}';
          block = '${studentDoc['block']}';
          branch = '${studentDoc['branch']}';
          course = '${studentDoc['course']}';
          mobile = '${studentDoc['mobile']}';
          registration_no = '${studentDoc['registrationNo']}';
          room = '${studentDoc['room']}';
        });
    }).whenComplete((){
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context)=>new full_outpass_display(
            outpassSnapshot: outPass,
            userName:'${userName}',
            block:'${block}',
            branch:'${branch}',
            course:'${course}',
            mobile:'${mobile}',
            registration_no:'${registration_no}',
            room:'${room}',
            profile:'${profile_pic}',
            hero_id: '${outPass.documentID}',
            whichStage: 2,
          )));
    });
  }

  //To get teachers info
  void getTeacherInfo(){
    Firestore.instance.collection('Teachers')
        .document('${widget.teacherID}')
        .get().then((teacherDocument){
      setState(() {
        techerName = '${teacherDocument['name']}';
        teacherRegNo = '${teacherDocument['registrationNo']}';
        teacherBranch = '${teacherDocument['branch']}';
        teacherCourse = '${teacherDocument['course']}';
        teacherProfile = '${teacherDocument['profile_pic']}';
        teacherMobileNo = '${teacherDocument['mobile']}';
      });
    });
  }

  void getOutpassDetails(String outpassID,String userID){
    Firestore.instance.collection('Users')
        .document('${userID}').collection('Outpasses')
        .document('${outpassID}').get().then((doc){
          setState(() {
            fromDate = '${doc['fromDate']}';
            toDate = '${doc['toDate']}';
            outgoing_time = '${doc['outgoing_time']}';
            mode_of_transport = '${doc['mode_of_transport']}';
            reason = '${doc['reason']}';
            whereState = '${doc['whereState']}';
            whereCity = '${doc['whereCity']}';
            approved = false;
            stage = '${doc['stage']}';
            HOD_name = '${doc['HOD_sent_to']}';
            transaction = '${doc['transaction']}';
          });
    });
  }


  Widget _mainTeacherPage(){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Teachers').
      document('${widget.teacherID}')
          .collection('studentOutpasses')
          .where('transaction',isEqualTo: 'inProgress')
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
          default:
            return Container(
              child: new ListView(
                //shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  return GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left:5.0,right: 5.0,top: 6.5,bottom: 5.0),
//                    padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: Colors.white.withOpacity(0.34)
                      ),
                      child: Container(
                        padding: EdgeInsets.all(7.5),
                        height: 150.0,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.54),
                            borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10.0,right: 10.0),
                                child: Row(
                                  children: <Widget>[

                                    (document['user_profile']!=null)?CircleAvatar(
                                      backgroundImage: CachedNetworkImageProvider('${document['user_profile']}'),
                                      radius: 17.5,
                                    ):CircleAvatar(
                                      backgroundColor: Colors.black.withOpacity(0.5),
                                    ),

                                    Container(
                                      padding: EdgeInsets.only(left: 7.5),
                                      child: Text('${document['user_name']}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.5
                                        ),
                                      ),
                                    ),
                                  ],
                            ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Padding(padding: EdgeInsets.all(3.0)),

                                  Container(
                                    margin: EdgeInsets.only(left: 10.0,right: 15.0,top: 5.0),
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
                                            Container(
                                              width:MediaQuery.of(context).size.width*(1/3),
                                              child: Text('${document['whereCity']},\n'
                                                  '${document['whereState']}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold
                                                ),
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
                            ]
                        )
                      ),
                    ),
                    onTap: () async{
                      await getStudentDetails('${document['user_id']}',document);
                    },
                  );
                }).toList(),
              ),
            );

        }
      },
    );
  }
  
  Widget _onlyForSearch(String registrationNumber){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Teachers').
      document('${widget.teacherID}')
          .collection('studentOutpasses')
          .where('student_registration_no',isEqualTo: '${registrationNumber}')
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
          default:
            return Container(
              child: new ListView(
                //shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  return GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left:5.0,right: 5.0,top: 6.5),
//                    padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: Colors.white.withOpacity(0.34)
                      ),
                      child: Container(
                          padding: EdgeInsets.all(7.5),
                          height: 190.0,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.54),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                Container(
                                  margin: EdgeInsets.only(left: 10.0,right: 10.0),
                                  child: Row(
                                    children: <Widget>[

                                      (document['user_profile']!=null)?CircleAvatar(
                                        backgroundImage: CachedNetworkImageProvider('${document['user_profile']}'),
                                        radius: 17.5,
                                      ):CircleAvatar(
                                        backgroundColor: Colors.black.withOpacity(0.5),
                                      ),

                                      Container(
                                        padding: EdgeInsets.only(left: 7.5),
                                        child: Text('${document['user_name']}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.5
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Padding(padding: EdgeInsets.all(3.0)),

                                    Container(
                                      margin: EdgeInsets.only(left: 10.0,right: 15.0,top: 5.0),
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

                                          Container(
                                            width: MediaQuery.of(context).size.width*(1/3),
                                            child: Column(
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
                                            ),
                                          )

                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ]
                          )
                      ),
                    ),
                    onTap: () async{
                      await getStudentDetails('${document['user_id']}',document);
                    },
                  );
                }).toList(),
              ),
            );

        }
      },
    );
  }
  
  //Only if the teacher wants to search a particular student
  Future searchParticularStudent() async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    )
                  ]
              ),
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0.0,
                  centerTitle: false,
                  title: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width*(3/4),
                    child: TextField(
                      controller: registrationNoOfStudent,
                      style: TextStyle(color: Colors.black,fontSize: 15.0),
                      decoration: new InputDecoration(
                          hintText: "Enter Student Registration Number",
                          hintStyle: TextStyle(color: Colors.black)
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
                body: _onlyForSearch(registrationNoOfStudent.text.toString().trimLeft().trimRight()),
              )
          );
        }
    );
  }

//  final FirebaseMessaging _firebaseTeacherMessaging = FirebaseMessaging();

//  void saveDeviceToken()async{
//    FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    String fcmToken = await _firebaseTeacherMessaging.getToken();
//  }

  @override
  void initState() {
    getTeacherInfo();
//    _firebaseTeacherMessaging.getToken().then((tokenValue){
//      Firestore.instance.collection('Teachers')
//          .document('${widget.teacherID}').collection('Tokens').add({
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
          onPressed: () async{
            //Search the registration number
            await searchParticularStudent();
          },
        child: Center(
          child: Icon(Icons.search, size: 30.0, color: Colors.black,),
        ),
        backgroundColor: Colors.yellow.withOpacity(0.85),
      ),

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
            child:_mainTeacherPage(),
          ),

          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              //height: 85.0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                toolbarOpacity: 0.0,
                title:Text('Outdoor passes',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
                centerTitle: false,

                actions: <Widget>[

                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Hero(
                        tag: "p1",
                        child: (teacherProfile!=null)?CircleAvatar(
                          radius: 18.5,
                          backgroundImage:CachedNetworkImageProvider('${teacherProfile}'),
                        ):CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                        )
                      ),
                      onTap: (){
                        Navigator.of(context).push(new MaterialPageRoute(
                          //transitionDuration: const Duration(milliseconds:500),
                            builder: (BuildContext context){
                              return new teacher_profile(
                                user_Name:'${techerName}',
                                user_branch:'${teacherBranch}',
                                user_course:'${teacherCourse}',
                                user_mobile:'${teacherMobileNo}',
                                user_registration_no:'${teacherRegNo}',
                                user_profile_pic:'${teacherProfile}',
                              );
                            }
                        ));
                        //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new user_profile()));
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
//                        try{
//                          FirebaseAuth.instance.signOut();
//                          //Navigator.of(context).pop();
//                          //Navigator.of(context).pop();
//                          Navigator.of(context).pushReplacement(
//                              new MaterialPageRoute(
//                                  builder: (BuildContext context)=>new welcome_screen()
//                              )
//                          );
//                        }catch(e){
//
//                        }
                      },
                    ),
                  )

                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}