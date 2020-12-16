import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'login_page.dart';

final FirebaseAuth _mAuth = FirebaseAuth.instance;
final Firestore _mFirestore = Firestore.instance;

class sign_up_page extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new sign_up_pageState();
  }

}

class sign_up_pageState extends State<sign_up_page>{

  String passwordState = "Just to confirm";

  //For the room number of the user....
  List block = ['G1','G2','G3','G4','B1','B2','B3','B4','B5','B6','B7'];
  String currentBlockSelected="Block";

  //For block selection
  Future<bool> showBlockForSelection() async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.transparent,
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
                body: Container(
                  color: Colors.white.withOpacity(0.75),
                  child: ListView.builder(
                      itemCount: block.length,
                      //itemExtent: 250.0,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: GestureDetector(
                            child: Text('${block[index]}'),
                            onTap: (){
                              setState(() {
                                currentBlockSelected="${block[index]}";
                                //loadStatesResponse("${countryName[index]}");
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                  ),
                ),
              )
          );
        }
    );
  }

  //For the users branch..
  List branch = ['B.TECH',
    'MBA',
    'B.TECH {LATERAL}',
    'B.SC {HONS.}',
    'B.A {HONS.}',
    'B.DES',
    'B.ARCH',
    'BPES',
    'BA',
    'B.COM',
    'B.F.A',
    'BBA + L.L.B {HONS.}',
    'L.L.B',
    'BALLB {HONS.}',
    'BHM',
    'BBA',
    'B.COM {HONS.}',
    'BCA',
    'M.TECH',
    'M.SC',
    'L.L.M',
    'M.C.A',
    'M.A',
    'M.COM',
    'M.ARCH',
    'PH.D'];

  List<String> courses = [];
  String currentBranchSelected = "Select a branch";
  String currentCourseSelected = "Select a course";

  Future loadCoursesResponse(String branchChosen) async{
    courses = new List();
    branchChosen = branchChosen.trimLeft().trimRight();
    String courseResult = await DefaultAssetBundle.of(context).loadString('jsonFile/courses.json');
    final courseResponse = json.decode(courseResult);
    for(int i=0;i<courseResponse.length;i++){
      if(courseResponse[i]['Branch'].toString().contains(branchChosen)){
        for(int j=0;j<courseResponse[i]['courses'].length;j++){
          courses.add(courseResponse[i]['courses'][j].toString());
        }
        break;
      }
    }
  }

  //To show the branch selection when prompted
  Future<bool> showBranchForSelection() async{
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
                body: Container(
                  color: Colors.white.withOpacity(0.75),
                  child: ListView.builder(
                      itemCount: branch.length,
                      //itemExtent: 250.0,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: GestureDetector(
                            child: Text('${branch[index]}'),
                            onTap: (){
                              setState(() {
                                currentBranchSelected="${branch[index]}";
                                //loadStatesResponse("${countryName[index]}");
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                  ),
                ),
              )
          );
        }
    );
  }

  //To show the course selection accordingly.
  Future<bool> showCoursesForSelection() async{
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
                body: Container(
                  color: Colors.white.withOpacity(0.75),
                  child: ListView.builder(
                      itemCount: courses.length,
                      //itemExtent: 250.0,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: GestureDetector(
                            child: Text('${courses[index]}'),
                            onTap: (){
                              setState(() {
                                currentCourseSelected="${courses[index]}";
                                //loadStatesResponse("${countryName[index]}");
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                  ),
                ),
              )
          );
        }
    );
  }


  //To the profile pic image
  File _profileImage;
  File result;
  bool uploading=false;
  int progressState=0;

  //To get the download url of the profile pic.
  String downloadURL;

  //For the user details..
  final TextEditingController name = new TextEditingController();
  final TextEditingController regNo = new TextEditingController();
  final TextEditingController course = new TextEditingController();
  final TextEditingController room = new TextEditingController();
  final TextEditingController mobile = new TextEditingController();
  final TextEditingController password = new TextEditingController();
  final TextEditingController confirmPassword = new TextEditingController();


  //Now for user's profile pic..
  //1 - Display a dialogue box to let the user chose whether it wants to click in realtime
  // or it wants to upload it from the gallery
  Future<bool> PictureSelection() async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                )
            ),
            child: Container(
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.0)
                  ),
                  //color: Colors.white
                ),
                child: Column(
                  children: <Widget>[

                    //Prompt talking
                    Container(
                        margin: EdgeInsets.all(10.0),
                        child: Text('Select how would you like to upload',
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal
                          ),
                        )
                    ),

                    Padding(padding: EdgeInsets.all(10.0)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        GestureDetector(
                          child: Icon(Icons.camera_alt,size: 50.0),
                          onTap: (){
                            takePicture(1);
                            Navigator.of(context).pop();
                          },
                        ),

                        Padding(padding: EdgeInsets.all(20.0)),

                        GestureDetector(
                          child: Icon(Icons.image,size: 50.0),
                          onTap: (){
                            takePicture(2);
                            Navigator.of(context).pop();
                          },
                        ),

                      ],
                    ),
                  ],
                )
            ),
          );
        }
    );
  }

  //2 - Take him/her to wherever the PictureSelection function gives you..
  Future takePicture(int n) async{
    if(n==1){
      var _image = await ImagePicker.pickImage(source: ImageSource.camera);
      result = await FlutterImageCompress.compressAndGetFile(
      _image.path,
        _image.path,
        quality: 50,
      );
      setState(() {
        _profileImage = result;
      });
    }

    if(n==2){
      var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
      result = await FlutterImageCompress.compressAndGetFile(
        _image.path,
        _image.path,
        quality: 50,
      );
      setState(() {
        _profileImage = result;
      });
    }
  }

  //To set the selected image in the place of the icon
  Widget setProfilePic(){
    return CircleAvatar(
      radius: 50.0,
      backgroundImage: FileImage(_profileImage),
    );
  }

  //Finally to upload all the user details to firebase and take the user back
  //to the login page as well as tell the user to verify the verification mail

  Future uploadProfilePic(String user_id) async{
    StorageReference picRef = FirebaseStorage.instance.ref().child('profileimages/${user_id}.png');
    
    StorageUploadTask task = picRef.putFile(_profileImage);
    task.events.listen((progress){
      setState(() {
        progressState = ((progress.snapshot.bytesTransferred.toDouble() / progress.snapshot.totalByteCount.toDouble())*100.0).round();
      });
    }).onError((error){
      setState(() {
        uploading=false;
      });
      Fluttertoast.showToast(
          msg: '${error}',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.blue.withOpacity(0.8),
          textColor: Colors.white
      );
    });
    StorageTaskSnapshot completed = await task.onComplete;
    String url = await completed.ref.getDownloadURL();
    setState(() {
      downloadURL = url;
    });
  }

  void uploadDetails() async {
    _mAuth.createUserWithEmailAndPassword(
        email: '${regNo.text.toString().trimLeft().trimRight()}@manipal.com',
        password: password.text.toString().trimLeft().trimRight()
    ).then((user) async{
      if(_profileImage==null){
        setState(() {
          uploading=true;
        });
        //Do registration without uploading profile pic
        Firestore.instance.collection('Users')
            .document('${user.user.uid}').setData({
          'name':'${name.text.toString().trim()}',
          'registrationNo':'${regNo.text.toString().trim()}',
          'branch':'${currentBranchSelected}',
          'course':'${currentCourseSelected}',
          'mobile':'${mobile.text.toString().trim()}',
          'block':'${currentBlockSelected}',
          'room':'${room.text.toString().trim()}',
          'profile_pic':null
        }).then((value){
          setState(() {
            uploading=false;
          });
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(
                  builder: (BuildContext context)=> new login_page()
              )
          );
        }).catchError((error){
          setState(() {
            uploading=false;
          });
          Fluttertoast.showToast(
              msg: '${error}',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.blue.withOpacity(0.8),
              textColor: Colors.white
          );
        });
      }
      else{
        await uploadProfilePic('${user.user.uid}');
        Firestore.instance.collection('Users')
            .document('${user.user.uid}').setData({
          'name':'${name.text.toString().trim()}',
          'registrationNo':'${regNo.text.toString().trim()}',
          'branch':'${currentBranchSelected}',
          'course':'${currentCourseSelected}',
          'mobile':'${mobile.text.toString().trim()}',
          'block':'${currentBlockSelected}',
          'room':'${room.text.toString().trim()}',
          'profile_pic':'${downloadURL}'
        }).then((value){
          setState(() {
            uploading=false;
          });

          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(
                  builder: (BuildContext context)=> new login_page()
              )
          );
        }).catchError((error){
          setState(() {
            uploading=false;
          });
          Fluttertoast.showToast(
              msg: '${error}',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.blue.withOpacity(0.8),
              textColor: Colors.white
          );
        });
      }
    }).catchError((error){
      setState(() {
        uploading=false;
      });
      Fluttertoast.showToast(
          msg: '${error}',
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
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                //For the profile pic
                Center(
                  child: (_profileImage==null)?GestureDetector(
                    child:Icon(Icons.account_circle, size: 80.0, color: Colors.white.withOpacity(0.75),),
                    onTap:(uploading==false)?(){
                      PictureSelection();
                    }:(){},
                  ):GestureDetector(
                    child: setProfilePic(),
                    onTap:(uploading==false)?(){
                      PictureSelection();
                    }:(){},
                  ),
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                TextField(
                  controller: regNo,
                  decoration: InputDecoration(
                      hintText: "REGISTRATION NUMBER",
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
                  enabled: (uploading==false)?true:false,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal
                  ),
                  keyboardType: TextInputType.number,
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                TextField(
                  controller: name,
                  decoration: InputDecoration(
                      hintText: "NAME",
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
                  enabled: (uploading==false)?true:false,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal
                  ),
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                //For the user to select his/her branch
                GestureDetector(
                  child: Container(
                    height: 40.0,
                    //padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
//                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                      border: Border.all(
//                        color: Colors.white.withOpacity(0.75),
//                        width: 0.5
//                      )
                    ),
                    child: Text('${currentBranchSelected}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  onTap: () async{
                    await showBranchForSelection();
                    loadCoursesResponse('${currentBranchSelected}');
                  },
                ),

                //To select the course according to the branch
                (courses.length!=0)?GestureDetector(
                  child: Container(
                    height: 40.0,
                    //padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
//                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                        border: Border.all(
//                            color: Colors.white.withOpacity(0.75),
//                            width: 0.5
//                        )
                    ),
                    child: Text('${currentCourseSelected}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  onTap: () async{
                    await showCoursesForSelection();
                  },
                ):Container(),

                //Padding(padding: EdgeInsets.all(10.0)),

                GestureDetector(
                  child: Container(
                    height: 40.0,
                    //padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
//                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                        border: Border.all(
//                            color: Colors.white.withOpacity(0.75),
//                            width: 0.5
//                        )
                    ),
                    child: Text('${currentBlockSelected}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  onTap: () async{
                    await showBlockForSelection();
                  },
                ),

                TextField(
                  controller: room,
                  decoration: InputDecoration(
                      hintText: "ROOM NO.",
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
                  maxLength: 3,
                  enabled: (uploading==false)?true:false,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal
                  ),
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                TextField(
                  controller: mobile,
                  decoration: InputDecoration(
                      hintText: "MOBILE",
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
                  enabled: (uploading==false)?true:false,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal
                  ),
                ),

                Padding(padding: EdgeInsets.all(10.0)),

                TextField(
                  controller: password,
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
                  enabled: (uploading==false)?true:false,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal
                  ),
                  obscureText: true,
                ),

                Padding(padding: EdgeInsets.all(15.0)),

                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                      hintText: "CONFIRM PASSWORD",
                      hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white
                          )
                      ),
                     helperText: '${passwordState}'
                  ),
                  enabled: (uploading==false)?true:false,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal
                  ),
                  obscureText: true,
                ),

                Padding(padding: EdgeInsets.all(5.0)),

                Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
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

                        child: Center(
                          child: (uploading==false)?Text('REGISTER',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal
                            ),
                          ):CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),

                      onTap: (uploading==false)?(){
                        if(name.text.length!=0&&
                          regNo.text.length!=0&&
                          mobile.text.length!=0&&
                          currentBranchSelected!="Select a branch" &&
                            currentCourseSelected!="Select a course"&&
                            currentBlockSelected!="Block"&&
                          room.text.length!=0&&
                          password.text.length!=0&&
                          confirmPassword.text.length!=0
                        )
                        {

                          if(confirmPassword.text.trimRight().trimLeft()==
                              password.text.trimLeft().trimRight())
                          {

                            setState(() {
                              uploading=true;
                            });
                            uploadDetails();

                          }

                        }
                      }:(){},

                    ),

                    Padding(padding: EdgeInsets.all(8.0)),

                    (uploading==true)?Text('${progressState}% done..',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0
                      ),
                    ):Container()

                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}