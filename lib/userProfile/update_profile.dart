import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_pass/mainPage/myActivitiesPage.dart';

class update_profile extends StatefulWidget{

  final String user_Name,user_block,user_branch,user_course,user_mobile,user_registration_no,user_room,user_profile_pic;

  const update_profile({Key key, this.user_Name, this.user_block, this.user_branch, this.user_course, this.user_mobile, this.user_registration_no, this.user_room, this.user_profile_pic}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new update_profileState();
  }

}

class update_profileState extends State<update_profile>{

  String name,regNo,block,room,branch,course,mobile,profile;
  TextEditingController n,reg,bl,rm,br,cou,mob,pr;

  String _currentBranchSelected;
  String _currentCourseSelected;
  String _currentBlockSelected;
  String _currentRoomSelected;

  List blocks = ['G1','G2','G3','G4','B1','B2','B3','B4','B5','B6','B7'];

  void getInfo(){
    setState(() {
      name = '${widget.user_Name}';
      regNo = '${widget.user_registration_no}';
      block = '${widget.user_block}';
      room = '${widget.user_room}';
      branch = '${widget.user_branch}';
      course = '${widget.user_course}';
      mobile = '${widget.user_mobile}';
      profile = '${widget.user_profile_pic}';
    });
    textControllers();
  }

  void textControllers(){
    setState(() {
      n = new TextEditingController(text: '${name}');
      bl = new TextEditingController(text: '${block}');
      rm = new TextEditingController(text: '${room}');
      br = new TextEditingController(text: '${branch}');
      cou = new TextEditingController(text: '${course}');
      mob = new TextEditingController(text: '${mobile}');
      pr = new TextEditingController(text: '${profile}');
    });
    extrasSetups();
  }

  void extrasSetups(){
    setState(() {
      _currentBranchSelected = branch;
      _currentCourseSelected = course;
      _currentBlockSelected = block;
      _currentRoomSelected = room;
    });
  }

  //For updating profile image
  File _profileImage;
  File result;
  bool uploading=false;
  bool uploadingPic=false;
  int progressState=0;
  String downloadURL;

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
      radius: 40.0,
      backgroundImage: FileImage(_profileImage),
    );
  }

  Widget setTempProfilePicture(){
    return Container(
      height: 300.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          image: DecorationImage(image: FileImage(_profileImage),
            fit: BoxFit.cover
          ),
      ),
    );
  }

  //Finally to upload all the user details to firebase and take the user back
  //to the login page as well as tell the user to verify the verification mail

  Future uploadProfilePic(String user_id) async{
    setState(() {
      uploadingPic=true;
    });
    StorageReference picRef = FirebaseStorage.instance.ref().child('profileimages/${user_id}.png');

    StorageUploadTask task = picRef.putFile(_profileImage);
    task.events.listen((progress){
      setState(() {
        progressState = ((progress.snapshot.bytesTransferred.toDouble() / progress.snapshot.totalByteCount.toDouble())*100.0).round();
      });
    }).onError((error){
      setState(() {
        uploadingPic=false;
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

    updateOnlyPic(user_id);
  }

  void updateOnlyPic(String id) async{
    Firestore.instance.collection('Users').document('${id}')
        .updateData({
      'profile_pic':'${downloadURL}'
    }).whenComplete((){
      setState(() {
        uploadingPic=false;
      });
    });

  }


  //For branch selection..
  List branches = ['B.TECH',
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
                      itemCount: branches.length,
                      //itemExtent: 250.0,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: Container(
                            child: GestureDetector(
                              child: Text('${branches[index]}'),
                              onTap: (){
                                setState(() {
                                  _currentBranchSelected="${branches[index]}";
                                  //loadStatesResponse("${countryName[index]}");
                                  _currentCourseSelected = 'Select a course';
                                });
                                Navigator.of(context).pop();
                              },
                            ),
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

  //For courses selection...
  List<String> courses = [];

  //Loading the courses
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
                                _currentCourseSelected="${courses[index]}";
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
                      itemCount: blocks.length,
                      //itemExtent: 250.0,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: GestureDetector(
                            child: Text('${blocks[index]}'),
                            onTap: (){
                              setState(() {
                                _currentBlockSelected="${blocks[index]}";
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

  void updateProfilePic() async{
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: (_profileImage==null)?(
                (widget.user_profile_pic!='null')?Container(
                  height: 300.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    image: DecorationImage(
                        image: CachedNetworkImageProvider('${widget.user_profile_pic}'),
                        fit: BoxFit.cover
                    )
                  ),
                ):Container(
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.85)
                    ),
                  child: Center(
                    child: Text('${widget.user_Name}'.substring(0,1),
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                  ),
                )
            ):setTempProfilePicture(),
          ),
          backgroundColor: Colors.transparent,
          actions: <Widget>[

            GestureDetector(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[

                      Icon(Icons.edit,color: Colors.white, size: 25.0,),
                      Text(
                        'Edit',
                        style: TextStyle(
                            color: Colors.white
                            ,fontSize: 15.0
                        ),
                      )

                    ],
                  ),
                ),
              ),
              onTap:() async{
                PictureSelection();
              },
            ),

            GestureDetector(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[

                      Icon(Icons.cancel,color: Colors.white, size: 25.0,),
                      Text('Cancel',style: TextStyle(color: Colors.white,fontSize: 15.0),)

                    ],
                  ),
                ),
              ),
              onTap: (){
                if(_profileImage!=null){
                  setState(() {
                    _profileImage=null;
                  });
                }
                Navigator.of(context).pop();
              },
            ),

            GestureDetector(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[

                      Icon(Icons.done,color: Colors.white, size: 25.0,),
                      Text('OK',style: TextStyle(color: Colors.white,fontSize: 15.0),)

                    ],
                  ),
                ),
              ),
              onTap: (){
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      }
    );
  }

  void updateDetails(int x) async{

    if(_currentCourseSelected!='Select a course'){
      setState(() {
        uploading=true;
      });
      final FirebaseUser updatedUser = await FirebaseAuth.instance.currentUser();
      final upUser = updatedUser.uid;

      if(_profileImage==null){
        Firestore.instance.collection('Users')
            .document('${upUser}').updateData({
          'name':'${n.text.toString().trim()}',
          'branch':'${_currentBranchSelected}',
          'course':'${_currentCourseSelected}',
          'block':'${_currentBlockSelected}',
          'room':'${rm.text.toString().trim()}',
          'profile_pic':'${widget.user_profile_pic}'
        }).whenComplete((){
          setState(() {
            uploading=false;
          });
          if(x==1){
            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new myActivitiesPage(
              userID: upUser,
            )));
          }
          if(x==0){

          }
        }).catchError((error){
          setState(() {
            uploading=false;
          });
          Fluttertoast.showToast(
              msg: '${error}',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG
          );
        });
      }
      else{
        await uploadProfilePic(upUser);
        Firestore.instance.collection('Users')
            .document('${upUser}').updateData({
          'name':'${n.text.toString().trim()}',
          'branch':'${_currentBranchSelected}',
          'course':'${_currentCourseSelected}',
          'block':'${_currentBlockSelected}',
          'room':'${rm.text.toString().trim()}',
        }).whenComplete((){
          setState(() {
            uploading=false;
          });
          if(x==1){
            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new myActivitiesPage(
              userID: upUser,
            )));
          }
          if(x==0){

          }

        }).catchError((error){
          setState(() {
            uploading=false;
          });
          Fluttertoast.showToast(
              msg: '${error}',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG
          );
        });
      }
    }
    else{
      Fluttertoast.showToast(
          msg: 'It seems a category is left blank',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG
      );
    }
  }


  @override
  void initState() {
    getInfo();
    loadCoursesResponse(_currentBranchSelected);
    super.initState();
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
          child: ListView(
            children: <Widget>[

              //To edit the profile pic
              Container(
                //height: 50.0,
                //width: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 3.5
                  )
                ),
                child: Center(
                  child:GestureDetector(
                    child: (_profileImage==null)?(
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
                        )
                    ):setProfilePic(),
                    onTap: (){
//                      PictureSelection();
                        updateProfilePic();
                    },
                  ),
                )
              ),

              Padding(padding: EdgeInsets.all(15.0)),

              //To get the name..
              Container(
                margin: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 5.0),
                child: TextField(
                  controller: n,
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
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),

              //For the user to select his/her branch
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*(3/4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white
                  ),
                  borderRadius: BorderRadius.circular(30.0)
                ),
                margin: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 5.0,top: 10.0),
                child: Container(
                  child: GestureDetector(
                    child: Container(
                      height: 30.0,
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
                      child: Container(
                        padding: EdgeInsets.only(top:7.0),
                        child: Center(
                          child: Text('${_currentBranchSelected}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: (uploading==false)?() async{
                      await showBranchForSelection();
                      loadCoursesResponse('${_currentBranchSelected}');
                    }:(){},
                  ),
                ),
              ),

              //For user to select his/her course
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*(3/4),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white
                    ),
                    borderRadius: BorderRadius.circular(30.0)
                ),
                margin: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 5.0,top: 10.0),
                child: Container(
                  child: GestureDetector(
                    child: Container(
                      height: 25.0,
                      padding: EdgeInsets.only(top:7.0),
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
                      child: Center(
                        child: Text('${_currentCourseSelected}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    ),
                    onTap:(uploading==false)?() async{
                      await showCoursesForSelection();
                    }:(){},
                  ),
                ),
              ),


              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*(3/4),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white
                    ),
                    borderRadius: BorderRadius.circular(30.0)
                ),
                margin: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 5.0,top: 10.0),
                child: Container(
                  width: 100.0,
                  child: GestureDetector(
                    child: Container(
                      height: 25.0,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top:7.0),
                      margin: EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
//                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                        border: Border.all(
//                            color: Colors.white.withOpacity(0.75),
//                            width: 0.5
//                        )
                      ),
                      child: Text('${_currentBlockSelected}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal
                        ),
                      ),
                    ),
                    onTap: (uploading==false)?() async{
                      await showBlockForSelection();
                    }:(){},
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0,top: 10.0),
                child: TextField(
                  controller: rm,
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
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left:10.0, right:10.0,bottom: 10.0),
                child: TextField(
                  controller: mob,
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
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
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
                          child: (uploading==false)?Text('UPDATE',
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
                        if(mob.text.toString()!=widget.user_mobile){
                          updateDetails(0);
                        }
                        else{
                          updateDetails(1);
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
              ),


            ],
          ),
        ),
      )
    );
  }
}
