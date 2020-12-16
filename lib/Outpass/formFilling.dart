import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:outdoor_pass/sign_up/login_page.dart';
import 'package:outdoor_pass/sign_up/sign_up_page.dart';
import 'dart:convert';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';
import 'package:cached_network_image/cached_network_image.dart';

final Firestore _mFirestore = Firestore.instance;
final FirebaseAuth _mAuth = FirebaseAuth.instance;

class formFilling extends StatefulWidget{

  final String userID;

  const formFilling({Key key, this.userID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new formFillingState();
  }

}

class formFillingState extends State<formFilling>{

  String getTeacherBranch;
  String getStudentName,getStudentProfile,getRegistrationNo;
  String HOD,HODid;

  bool uploading = false;

  String modeOfTransport = "Flight";
  bool permission = false;

  DateTime birthDate;
  final f = new DateFormat('dd-MM-yyyy');
  TimeOfDay _time = TimeOfDay.now();
  List<int> years=[];
  List months = ['January','February','March','April','May','June','July',
    'August','September','October','November','December'
  ];
  List<int> dates = [];
  int fromDate=DateTime.now().day;
  int fromMonth = DateTime.now().month;
  int fromYear = DateTime.now().year;

  int toDate=(DateTime.now().day)+1;
  int toMonth = DateTime.now().month;
  int toYear = DateTime.now().year;

  List<String> stateNames = [];
  List<String> cityNames = [];

  String currentStateSelected="Select a state";
  String currentCitySelected="Select a city";

  final TextEditingController findState = new TextEditingController();
  final TextEditingController findCity = new TextEditingController();
  final TextEditingController resonToLeave = new TextEditingController();


  void generateYears(){
    for(int i=DateTime.now().year;i<=DateTime.now().year+2;i++){
      years.add(i);
    }
  }

  void generateDates(){
    for(int i=1;i<=31;i++){
      dates.add(i);
    }
  }

  void getUserDetails(){
    Firestore.instance.collection('Users').document('${widget.userID}')
        .get().then((userDocs){
          setState(() {
            getTeacherBranch = '${userDocs['course']}';
            getStudentName = '${userDocs['name']}';
            getStudentProfile = '${userDocs['profile_pic']}';
            getRegistrationNo = '${userDocs['registrationNo']}';
          });
    });
  }

  //Selecting the Head of Department
  Future<bool> selectHOD() async{
    getUserDetails();
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                )
            ),
            child: Container(
              //height: 150.0,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.0)
                  ),
                  //color: Colors.white
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('Teachers').
                  where('course',isEqualTo: '${getTeacherBranch}')
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
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data.documents.map((DocumentSnapshot document) {

                              return GestureDetector(
                                child: Container(
                                  //margin: EdgeInsets.all(10.0),
                                  height: 100.0,
                                  width: 100.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      (document['profile_pic']!=null)?CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage: CachedNetworkImageProvider('${document['profile_pic']}'),
                                      ):Icon(Icons.account_circle,size: 100.0,color: Colors.white,),

                                      Padding(padding: EdgeInsets.all(5.0)),

                                      Text('${document['name']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                      )

                                    ],
                                  )
                                ),
                                onTap: (){
                                  setState(() {
                                    HOD = '${document['name']}';
                                    HODid = '${document.documentID}';
                                  });

                                  if(resonToLeave.text.length!=0 &&
                                      currentStateSelected!="Select a state"&&
                                      currentCitySelected!="Select a city"
                                  ){

                                    submitOutpass();

                                  }
                                  else{
                                    Fluttertoast.showToast(
                                        msg:"It seems you have not filled some fields ",
//                                            "  (i) Reason to leave"
//                                            " (ii) City you are leaving to"
//                                            "(iii) State you are leaving to",
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor: Colors.white.withOpacity(0.8),
                                        textColor: Colors.black,
                                        toastLength: Toast.LENGTH_LONG
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                              );

                            }).toList(),
                          ),
                        );

                    }
                  },
                )
            ),
          );
        }
    );
  }

  //Now dialog boxes for the users to chose their birthyear,bithmonth and birthdate
  //1- Dialog box for birthyear..
  Future<bool> YearSelection(int n) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                )
            ),
            child: Container(
              //height: 150.0,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.0)
                  ),
                  //color: Colors.white
                ),
                child: ListView.builder(
                    itemCount: years.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(left:10.0,right: 10.0,bottom:10.0),
                          height: 40.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                              border: Border.all(color: Colors.grey),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0
                                )
                              ]
                          ),
                          child: Center(
                            child: Text('${years[index]}'),
                          ),
                        ),
                        onTap: (){
                          if(n==1){
                            setState(() {
                              fromYear = years[index];
                            });
                            Navigator.of(context).pop();
                          }
                          if(n==2){
                            setState(() {
                              toYear = years[index];
                            });
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    }
                )
            ),
          );
        }
    );
  }

  //2- Dialog box for birthmonth selection.
  Future<bool> MonthSelection(int n) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                )
            ),
            child: Container(
              //height: 150.0,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.0)
                  ),
                  //color: Colors.white
                ),
                child: ListView.builder(
                    itemCount: months.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(left:10.0,right: 10.0,bottom:10.0),
                          height: 40.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                              border: Border.all(color: Colors.grey),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0
                                )
                              ]
                          ),
                          child: Center(
                            child: Text('${months[index]} (${index+1})'),
                          ),
                        ),
                        onTap: (){
                          if(n==1){
                            setState(() {
                              fromMonth = (index+1);
                            });
                            Navigator.of(context).pop();
                          }
                          if(n==2){
                            setState(() {
                              toMonth = (index+1);
                            });
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    }
                )
            ),
          );
        }
    );
  }

  //3- Dialog box for birthdate selection.
  Future<bool> DateSelection(int n) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                )
            ),
            child: Container(
              //height: 150.0,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.0)
                  ),
                  //color: Colors.white
                ),
                child: ListView.builder(
                    itemCount: dates.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(left:10.0,right: 10.0,bottom:10.0),
                          height: 40.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                              border: Border.all(color: Colors.grey),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0
                                )
                              ]
                          ),
                          child: Center(
                            child: Text('${dates[index]}'),
                          ),
                        ),
                        onTap: (){
                          if(n==1){
                            setState(() {
                              fromDate = dates[index];
                            });
                            Navigator.of(context).pop();
                          }
                          if(n==2){
                            setState(() {
                              toDate = dates[index];
                            });
                            Navigator.of(context).pop();
                          }

                        },
                      );
                    }
                )
            ),
          );
        }
    );
  }

  Future loadStatesResponse() async{
    stateNames = new List();
    String statesResult = await DefaultAssetBundle.of(context).loadString('jsonFile/states.json');
    final stateResponse = json.decode(statesResult);
    for(int i=0;i<stateResponse.length;i++){
      for(int j = 0;j<stateResponse[i]['states'].length;j++){
        stateNames.add(stateResponse[i]['states'][j].toString());
      }
    }
  }

  Future loadCitiesAccordingly(String stateName) async {
    int x = 0;
    cityNames = new List();
    stateName = stateName.trimRight().trimLeft();
    String cityResult = await DefaultAssetBundle.of(context).loadString('jsonFile/cities.json');
    final cityResponse = json.decode(cityResult);
    for (int i = 0; i < cityResponse.length; i++) {
      if(cityResponse[i]['state']=='${stateName}'){
        for(int j = 0;j < cityResponse[i]['cities'].length;j++){
          cityNames.add(cityResponse[i]['cities'][j].toString());
        }
      }
//      if (cityResponse[i]['name'] == '${countryName}') {
//        for (int j = 0; j <
//            cityResponse[i]['states']['${stateName}'].length; j++) {
//          cityNames.add(
//              cityResponse[i]['states']['${stateName}'][j].toString());
//        }
//      }
    }
  }

  //Dialog for state display
  Future<bool> showStateForSelection() async{
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
                body: ListView.builder(
                    itemCount: stateNames.length,
                    //itemExtent: 250.0,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        title: GestureDetector(
                          child: Text('${stateNames[index]}'),
                          onTap: (){
                            setState(() {
                              currentStateSelected="${stateNames[index]}";
                              //loadStatesResponse("${countryName[index]}");
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    }
                ),
              )
          );
        }
    );
  }


  //Dialog for city display
  Future<bool> showCityForSelection() async{
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
                    width: MediaQuery.of(context).size.width*(1/2),
                    child: TextField(
                      controller: findCity,
                      style: TextStyle(color: Colors.black,fontSize: 15.0),
                      decoration: new InputDecoration(
                          hintText: 'Search city name',
                          hintStyle: TextStyle(color: Colors.black)
                      ),
                      onChanged: (cityText) async{
                        cityNames = new List();
                        currentStateSelected = currentStateSelected.trimRight().trimLeft();
                        String cityResult = await DefaultAssetBundle.of(context).loadString(
                            'jsonFile/cities.json');
                        final cityResponse = json.decode(cityResult);
                        for (int i = 0; i < cityResponse.length; i++) {
                          if(cityResponse[i]['state']=='${currentStateSelected}'){
                            for(int j=0;j<cityResponse[i]['cities'].length;j++){
                              if(cityResponse[i]['cities'][j].toString().toUpperCase().contains(cityText.toUpperCase())){
                                cityNames.add(cityResponse[i]['cities'][j].toString());
                              }
                            }
                          }
                        }
                      },
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
                body: ListView.builder(
                    itemCount: cityNames.length,
                    //itemExtent: 250.0,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        title: GestureDetector(
                          child: Text('${cityNames[index]}'),
                          onTap: (){
                            setState(() {
                              currentCitySelected="${cityNames[index]}";
                              //loadStatesResponse("${countryName[index]}");
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    }
                ),
              )
          );
        }
    );
  }
  String periodOfTheDay = 'PM';
  int hour = TimeOfDay.now().hour;
  String minute = TimeOfDay.now().minute.toString();
  int m = 0;
  Future<DateTime> selectTime(BuildContext context, int n) async{
    final TimeOfDay timeChosen = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
    );
    if(timeChosen!=null && timeChosen!=TimeOfDay.now()){
      setState(() {
        _time = timeChosen;
        hour = timeChosen.hour;
        m = timeChosen.minute;
        minute = timeChosen.minute.toString();
      });
      if(m<=9){
        setState(() {
          minute = "0"+minute;
        });
      }
      if(timeChosen.period == DayPeriod.am){
        setState(() {
          periodOfTheDay = 'AM';
        });
      }
      if(timeChosen.period == DayPeriod.pm){
        setState(() {
          periodOfTheDay = 'PM';
        });
      }
    }
  }

  void submitOutpass() async{

    setState(() {
      uploading = true;
    });

    final FirebaseUser user = await _mAuth.currentUser();
    final user_uid = user.uid;

    _mFirestore.collection('Users').document('${user_uid}')
    .collection('Outpasses').add({
      'user_id':'${user_uid}',
      'student_registration_no':'${getRegistrationNo}',
      'fromDate':'${fromDate}/${fromMonth}/${fromYear}',
      'toDate':'${toDate}/${toMonth}/${toYear}',
      'outgoing_time':'${hour}:${minute} ${periodOfTheDay}',
      'modeOfTransport':'${modeOfTransport}',
      'reason':'${resonToLeave.text.toString()}',
      'whereState':'${currentStateSelected}',
      'whereCity':'${currentCitySelected}',
      'approved':false,
      'stage':'Sent to HOD',
      'HOD_sent_to':'${HOD}',
      'HOD_id':'${HODid}',
      'transaction':'inProgress',
      'issued_date':'${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
    }).then((DocumentReference doc){
         Firestore.instance.collection('Teachers')
             .document('${HODid}').collection('studentOutpasses')
             .document('${doc.documentID}').setData({
             'student_registration_no':'${getRegistrationNo}',
             'user_name':'${getStudentName}',
             'user_profile':'${getStudentProfile}',
             'user_id':'${user_uid}',
             'fromDate':'${fromDate}/${fromMonth}/${fromYear}',
             'toDate':'${toDate}/${toMonth}/${toYear}',
             'outgoing_time':'${hour}:${minute} ${periodOfTheDay}',
             'modeOfTransport':'${modeOfTransport}',
             'reason':'${resonToLeave.text.toString()}',
             'whereState':'${currentStateSelected}',
             'whereCity':'${currentCitySelected}',
             'approved':false,
             'stage':'Sent to HOD',
             'HOD_sent_to':'${HOD}',
             'transaction':'inProgress',
             'issued_date':'${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
         });
    }).
    whenComplete((){
      setState(() {
        uploading = false;
      });
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context)=>new myActivitiesPage(
        userID: '${user_uid}',
      )));

    }).catchError((error){
      setState(() {
        uploading = false;
      });
      Fluttertoast.showToast(
          msg:"${error.details}",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.white.withOpacity(0.15),
          textColor: Colors.black,
          toastLength: Toast.LENGTH_LONG
      );
    });

  }

  void initState(){
    generateDates();
    generateYears();
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Container(
        padding: EdgeInsets.only(left:20.0,right:20.0,top: 20.0,bottom: 10.0),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(Colors.black45.withOpacity(0.65), BlendMode.overlay)
            )
        ),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height-100.0,
            margin: EdgeInsets.all(10.0),
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
//              margin: EdgeInsets.all(30.0),
              child: ListView(
                children: <Widget>[
                  Container(
                  alignment: Alignment.center,
                    child: Text('From',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  ),

                  Container(
//                  padding:EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0,top: 10.0),
                    //height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),

                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        GestureDetector(
                          child: Container(
                            //margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width*(1/3),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50.0)
                                ),
                                border: Border.all(
                                    color: Colors.grey
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0
                                  )
                                ]
                            ),
                            child: Center(child: Text('${fromYear}'),),
                          ),
                          onTap: (){
                            YearSelection(1);
                          },
                        ),

                        Padding(padding: EdgeInsets.all(5.0)),

                        GestureDetector(
                          child: Container(
                            //margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            width: 50.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50.0)
                                ),
                                border: Border.all(
                                    color: Colors.grey
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0
                                  )
                                ]
                            ),
                            child: Center(child: Text('${fromMonth}'),),
                          ),
                          onTap: (){
                            MonthSelection(1);
                          },
                        ),

                        Padding(padding: EdgeInsets.all(5.0)),

                        GestureDetector(
                          child: Container(
                            //margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            width: 50.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50.0)
                                ),
                                border: Border.all(
                                    color: Colors.grey
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0
                                  )
                                ]
                            ),
                            child: Center(child: Text('${fromDate}'),),
                          ),
                          onTap: (){
                            DateSelection(1);
                          },
                        )

                      ],
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(5.0)),

                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text('Outgoing time',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left: 20.0,right: 20.0),
                      height: 35.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0
                            )
                          ]
                      ),
                      child: Center(
                        child: Text('${hour}:${minute} ${periodOfTheDay}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    ),
                    onTap: (){
                      selectTime(context, 1);
                    },
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  Container(
                    alignment: Alignment.center,
                    child: Text('To',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ),

                  Container(
//                  padding:EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0,top: 10.0),
                    //height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),

                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        GestureDetector(
                          child: Container(
                            //margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width*(1/3),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50.0)
                                ),
                                border: Border.all(
                                    color: Colors.grey
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0
                                  )
                                ]
                            ),
                            child: Center(child: Text('${toYear}'),),
                          ),
                          onTap: (){
                            YearSelection(2);
                          },
                        ),

                        Padding(padding: EdgeInsets.all(5.0)),

                        GestureDetector(
                          child: Container(
                            //margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            width: 50.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50.0)
                                ),
                                border: Border.all(
                                    color: Colors.grey
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0
                                  )
                                ]
                            ),
                            child: Center(child: Text('${toMonth}'),),
                          ),
                          onTap: (){
                            MonthSelection(2);
                          },
                        ),

                        Padding(padding: EdgeInsets.all(5.0)),

                        GestureDetector(
                          child: Container(
                            //margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            width: 50.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50.0)
                                ),
                                border: Border.all(
                                    color: Colors.grey
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0
                                  )
                                ]
                            ),
                            child: Center(child: Text('${toDate}'),),
                          ),
                          onTap: (){
                            DateSelection(2);
                          },
                        )

                      ],
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(10.0)),

                  Container(
                    alignment: Alignment.center,
                    child: Text('Where',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Padding(padding: EdgeInsets.all(10.0)),

                      GestureDetector(
                        child: Container(
                          padding:EdgeInsets.all(10.0),
                          margin: EdgeInsets.only(left: 20.0, right:20.0,top: 10.0),
                          height: 40.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(50.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0
                                ),
                              ]
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Center(
                                child: Text('${currentStateSelected}'),
                              ),

                              Icon(Icons.arrow_drop_down)
                            ],
                          ),

                        ),
                        onTap: () async{
                          await loadStatesResponse();
                          showStateForSelection();
                          currentCitySelected="Select a city";
                        },
                      ),

                      //Padding(padding: EdgeInsets.all(10.0)),

                      GestureDetector(
                        child: Container(
                          padding:EdgeInsets.all(10.0),
                          margin: EdgeInsets.only(left: 20.0, right:20.0,top: 10.0),
                          height: 40.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(50.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0
                                ),
                              ]
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Center(
                                child: Text('${currentCitySelected}'),
                              ),

                              Icon(Icons.arrow_drop_down)
                            ],
                          ),

                        ),
                        onTap: ()async{
                          await loadCitiesAccordingly(currentStateSelected);
                          showCityForSelection();
                        },
                      ),

                      Padding(padding: EdgeInsets.all(10.0)),

                      Container(
                        alignment: Alignment.center,
                        child: Text('Mode of transport',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(left: 20.0,right: 20.0,top: 5.0),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[

                            GestureDetector(
                                child: Icon(Icons.flight,
                                  color: (modeOfTransport=="Flight")?Colors.white:Colors.white54,
                                  size: (modeOfTransport=="Flight")?60.0:30.0,
                                ),
                              onTap: (){
                                  setState(() {
                                    modeOfTransport = "Flight";
                                  });
                              },
                            ),

                            GestureDetector(
                                child: Icon(Icons.train,
                                  color: (modeOfTransport=="Train")?Colors.white:Colors.white54,
                                  size: (modeOfTransport=="Train")?60.0:30.0,
                                ),
                              onTap: (){
                                  setState(() {
                                    modeOfTransport = "Train";
                                  });
                              },
                            ),


                            GestureDetector(
                              child: Icon(Icons.directions_bus,
                                color: (modeOfTransport=="Bus")?Colors.white:Colors.white54,
                                size: (modeOfTransport=="Bus")?60.0:30.0,
                              ),
                              onTap: (){
                                setState(() {
                                  modeOfTransport = "Bus";
                                });
                              },
                            ),

                            GestureDetector(
                                child: Icon(Icons.directions_car,
                                  color: (modeOfTransport=="Car")?Colors.white:Colors.white54,
                                  size: (modeOfTransport=="Car")?60.0:30.0,
                                ),
                              onTap: (){
                                  setState(() {
                                    modeOfTransport = "Car";
                                  });
                              },
                            )

                          ],
                        ),
                      ),

                      Padding(padding: EdgeInsets.all(10.0)),

                      Container(
                        margin: EdgeInsets.only(left: 20.0,right: 20.0),
                        child: TextField(
                          controller: resonToLeave,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(19.0),
                                borderSide: BorderSide(color: Colors.white)
                            ),
                            hintText: "Reason of leave",
                            hintStyle: TextStyle(
                              color: Colors.white
                            )
                          ),
                          maxLines: null,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ),

                      Padding(padding: EdgeInsets.all(10.0)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[

                          new Checkbox(
                              value: permission,
                              onChanged: (bool resp){

                                setState(() {
                                  permission = resp;
                                });

                              }),

                          Container(
                              width: MediaQuery.of(context).size.width*(1/2),
                              margin: EdgeInsets.only(right: 20.0),
                              child: Text('I have taken permission from my parents',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5
                                ),
                              )
                          ),
                        ],
                      ),

                      Padding(padding: EdgeInsets.all(10.0)),

                      (uploading == false)?(
                          (permission==true)?GestureDetector(
                            child:Container(
                                height: 45.0,
                                margin: EdgeInsets.only(bottom: 20.0),
                                width:MediaQuery.of(context).size.width*(3/4),
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
                                  child:Text('FORWARD TO YOUR HOD',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),
                                )
                            ),
                            onTap: () async {
                              //Reason should not be empty
//                          currentStateSelected="Select a state";
                              //  String currentCitySelected="Select a city";
                              await selectHOD();

//                              if(resonToLeave.text.length!=0 &&
//                                  currentStateSelected!="Select a state"&&
//                                  currentCitySelected!="Select a city"
//                              ){
//
//                                submitOutpass();
//
//                              }
//                              else{
//                                Fluttertoast.showToast(
//                                    msg:"It seems you have not filled one of the following fields : "
//                                        "  (i) Reason to leave"
//                                        " (ii) City you are leaving to"
//                                        "(iii) State you are leaving to",
//                                    gravity: ToastGravity.CENTER,
//                                    backgroundColor: Colors.white.withOpacity(0.8),
//                                    textColor: Colors.black,
//                                    toastLength: Toast.LENGTH_LONG
//                                );
//                              }
//                            },
                            }
                          ):Container()
                      ):Container(
                        height: 25.0,
                        width: 25.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )

                    ],
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}