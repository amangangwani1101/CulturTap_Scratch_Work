const express = require('express');
const router = express.Router();
const axios = require('axios');
const serviceAccount = require('../serviceAccountKey.json');
// required db
const ProfileData = require("../db/model/profileData.js");

const admin = require('firebase-admin');

const firebaseAdmin = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


router.post("/notificationHandler",	async(req,res)=>{
	try{
    	const dataset = req.body;
    	const userIds = dataset['userIds'];
    	const payload = dataset['payload'];
    	for(let userId of userIds){
        	const user = await ProfileData.findById(userId).lean();
        	if(!user || user['uniqueToken']===undefined || user['uniqueToken']=='')  continue;
        	const userToken = user['uniqueToken'];
        	payload['token'] = userToken;
        	payload['data']['userId'] = userId;
        	try{
	            console.log(payload);
                result = await sendNotificationToUser(payload);
          	    console.log(result);
            	res.status(200).json({ message:"notification sended successfully" }); 
        	}catch(err){
            	console.error('Failed to send notification handle:', error.message);
            	res.status(501).json({ error: "Failed to send notification" }); 	
            }
        }	
    }catch(err){
    	 // Send a JSON response indicating an error
      console.error('Failed to send notification handle:', error.message);
      res.status(501).json({ error: "Failed to send notification" });
    }
});

async function sendNotificationToUser(payload) {

//  const payload = {
 	
//     "notification": {
//       "title": title,
//       "body": body,
//     },
//     "data": {
//       "type": 'local_assistant_service',
//       "meetId": meetId,
//       "state": state,
//     },
//  	"token":userToken,
//   };

  try {
    const response = await firebaseAdmin.messaging().send(payload);
    return "Notification Sended Successflly";	
  } catch (error) {
    console.error('Failed to send notification handle:', error.message);
  	return "Notification Not Sent";	
  }
}


// // Firebase Cloud Function
// const sendNotificationFunction = functions.https.onCall(async (data, context) => {

//   const title = data.title;
//   const body = data.body;
//   const image = data.image;
//   const token = data.token;

//   // ... your existing logic for sendNotification function
//   try {
//       const payload = {
//         token: token,
//         notification: {
//           title: title,
//           body: body,
//           image: image,
//         },
//         data: {
//           body: body,
//         },
//       };

//       return fcm.send(payload).then((response) => {
//         return {success: true, response: "Succefully sent message: " + response};
//       }).catch((error) => {
//         return {error: error};
//       });
//     } catch (error) {
//       throw new functions.https.HttpsError("invalid-argument", "error:" +error);
//     }
// });

module.exports = router;