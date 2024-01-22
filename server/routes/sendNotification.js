// // notificationRouter.js

// const express = require('express');
// const router = express.Router();

// const admin = require('firebase-admin');
// const serviceAccount = require('../serviceAccountKey.json');
// // Adjust the path accordingly
// if (!admin.apps.length) {
//   admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     messagingSenderId : '268794997426',
//   });
// }

// const ProfileData = require("../db/model/profileData.js");

// async function sendNotificationsToAll() {
//   try {
//     // Retrieve all unique tokens from the UserProfiles
//     const usersToNotify = await ProfileData.find({}, 'uniqueToken');

//     // Extract the unique tokens from the query result, excluding empty or undefined tokens
//     const registrationTokens = usersToNotify
//       .map(user => user.uniqueToken)
//       .filter(token => token && token.trim() !== '');

//     // Check if there are any tokens to send notifications to
//     if (registrationTokens.length === 0) {
//       console.log('No valid tokens found to send notifications.');
//       return;
//     }

//     // Create the FCM message
//     const message = {
//       notification: {
//         title: 'Kya Baat hai',
//         body: 'kya body hai',
//       },
//       data: {
//         key1: 'amazing',
//         key2: 'worst',
//       },
//     };

//     // Send the FCM message to each token
//     const responses = await Promise.all(
//       registrationTokens.map(async (token) => {
//         try {
//           const response = await admin.messaging().sendToDevice(token, message);
//           console.log('Successfully sent message to', token);
//           return response;
//         } catch (error) {
//           console.error('Failed to send to', token, 'Error:', error);
//           return error;
//         }
//       })
//     );

//     // Handle the responses if needed

//     console.log('Notifications sent to all valid tokens');
//   } catch (error) {
//     console.error('Error sending notifications:', error);
//   }
// }


// router.post('/send-notifications', async (req, res) => {
//   try {
//     await sendNotificationsToAll();
//     res.status(200).send('Notifications sent to all tokens');
//   } catch (error) {
//     console.error('Error sending notifications:', error);
//     res.status(500).send('Internal Server Error');
//   }
// });


// router.post('/sendLocalAssistantRequest',async(req,res)=>{
// 	try{
//     	const users = req.body['userIds'];
//     	const customMessage = req.body['message'];
//     	// Retrieve all unique tokens from the UserProfiles
// 	    const usersToNotify = await ProfileData.find({_id : {$in : users }}, 'uniqueToken');
//     	// Extract the unique tokens from the query result, excluding empty or undefined tokens
//     	const registrationTokens = usersToNotify
//       	.map(user => user.uniqueToken)
//       	.filter(token => token && token.trim() !== '');

// 	    // Check if there are any tokens to send notifications to
//    		if (registrationTokens.length === 0) {
//       		console.log('No valid tokens found to send notifications.');
//       		res.status(200).send('No One Found');
//     	}
//     	registrationTokens.map(async (token) => {
//           const response = await admin.messaging().sendToDevice(token, customMessage);
//           console.log('Successfully sent message to', token);
//       	});
//     	res.status(200).send('Notification Sended To User Succedssfully!');
//     }catch(err){
//      	console.error('Error sending notifications:', err);
//     	res.status(500).send('Internal Server Error');
//     }
// });

// module.exports = router;
