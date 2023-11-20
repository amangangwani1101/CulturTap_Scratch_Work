const express = require('express');
const router = express.Router();
const ProfileData = require("../../db/model/profileData.js");

// firebase modules
const admin = require('firebase-admin');
const functions = require('firebase-functions');
const serviceAccount = require('../../serviceAccountKey.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://culturtap-19340.firebaseio.com',
});

// Configuring FCM
const fcm = admin.messaging();



//cacncel meet request
router.patch("/cancelMeeting", async (req, res) => {
  try {
    const { userId, date, index ,setStatus,user2Id,set2Status} = req.body;

    const user = await ProfileData.findById(userId).lean();
    const user2 = await ProfileData.findById(user2Id).lean();

    if (!user || !user2) {
      return res.status(404).json({ message: "User Not Found" });
    }

    if (!user.userServiceTripCallingData.dayPlans || !user.userServiceTripCallingData.dayPlans[date]) {
      return res.status(404).json({ message: "Meeting not found for the given date" });
    }

    if (!user2.userServiceTripCallingData.dayPlans || !user2.userServiceTripCallingData.dayPlans[date]) {
      return res.status(404).json({ message: "Meeting not found for the given date" });
    }

    const { meetingStatus } = user.userServiceTripCallingData.dayPlans[date];
    const { meeting2Status } = user2.userServiceTripCallingData.dayPlans[date];
    if (index < 0 || index >= meetingStatus.length) {
      return res.status(404).json({ message: "Invalid index" });
    }

    // Update the meeting status to "close" at the specified index
    user.userServiceTripCallingData.dayPlans[date].meetingStatus[index] =setStatus;
    user2.userServiceTripCallingData.dayPlans[date].meetingStatus[index] =set2Status;
    // Save the updated user data
    await ProfileData.findByIdAndUpdate(userId, user);
    await ProfileData.findByIdAndUpdate(user2Id, user2);

    res.status(200).json({ message: "Meeting status updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});


//close meet request after feedback
router.patch("/closeMeeting", async (req, res) => {
  try {
    const { userId, date, index} = req.body;

    const user = await ProfileData.findById(userId).lean();

    if (!user) {
      return res.status(404).json({ message: "User Not Found" });
    }

    if (!user.userServiceTripCallingData.dayPlans || !user.userServiceTripCallingData.dayPlans[date]) {
      return res.status(404).json({ message: "Meeting not found for the given date" });
    }


    const { meetingStatus } = user.userServiceTripCallingData.dayPlans[date];
    if (index < 0 || index >= meetingStatus.length) {
      return res.status(404).json({ message: "Invalid index" });
    }

    // Update the meeting status to "close" at the specified index
    user.userServiceTripCallingData.dayPlans[date].meetingStatus[index] = 'closed';
    // Save the updated user data
    await ProfileData.findByIdAndUpdate(userId, user);
    res.status(200).json({ message: "Meeting status updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

// Firebase Cloud Function
const sendNotificationFunction = functions.https.onCall(async (data, context) => {

  const title = data.title;
  const body = data.body;
  const image = data.image;
  const token = data.token;

  // ... your existing logic for sendNotification function
  try {
      const payload = {
        token: token,
        notification: {
          title: title,
          body: body,
          image: image,
        },
        data: {
          body: body,
        },
      };

      return fcm.send(payload).then((response) => {
        return {success: true, response: "Succefully sent message: " + response};
      }).catch((error) => {
        return {error: error};
      });
    } catch (error) {
      throw new functions.https.HttpsError("invalid-argument", "error:" +error);
    }
});

// Route for calling the sendNotification Cloud Function
router.post('/sendNotification', async (req, res) => {
  try {
    const { title, body, image, token } = req.body;

    // Call the Firebase Cloud Function
    const response = await sendNotificationFunction({ title, body, image, token });

    // Respond to the client with the result
    res.status(200).json(response);
  } catch (error) {
    console.error('Error calling sendNotification Cloud Function:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


module.exports  =router;