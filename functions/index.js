/* eslint-disable promise/catch-or-return */
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
var outpassData;

exports.outPassToTeachersTrigger = functions.firestore.document(
    'Teachers/{TeacherID}/studentOutpasses/{outpassID}'
).onCreate((snapshot,context)=>{
    outpassData = snapshot.data();
    admin.firestore().collection('Teachers/{teacherID}/Tokens').get().then(async (snapshots)=>{
        var tokens = [];
        // eslint-disable-next-line promise/always-return
        if(snapshots.empty){
            console.log('No device attached');
        }
        else
        {
            for(var token of snapshots.docs){
                tokens.push(token.data().notifying_token);
            }
             var payload = {
                "notification":{
                    "title":"From "+outpassData.user_name,
                    "body":"Want approval for the Outdoor pass",
                    "sound":"default"
                },
                "data":{
                    "sendername": outpassData.user_name,
                    "message":"Request to approve the outpass"
                },
             }
             try {
                await admin.messaging().sendToDevice(token, payload);
                console.log('Send message successfully');
            }
            catch (error) {
                console.log(error);
            }
        }
    })
})