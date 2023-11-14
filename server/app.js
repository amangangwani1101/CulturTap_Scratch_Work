const express = require('express');
const app = express();
const port = 8080;
require('./db/conn.js');
const UserData = require('./db/model/profileData.js');
const cors = require('cors');
const admin = require('firebase-admin');
const functions = require('firebase-functions');
const serviceAccount = require('./serviceAccountKey.json');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
// Initialize Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://culturtap-19340.firebaseio.com',
});

// Configuring FCM
const fcm = admin.messaging();

app.get('/',(req,res)=>{
       res.send('this is my flutter page');
})


app.post('/SignUp', async (req, res) => {
  try {
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const {userName,phoneNumber,latitude,longitude,uniqueToken} = req.body;
    console.log(req.body);
    const newUser = new UserData({userName,phoneNumber,latitude,longitude,uniqueToken});
    const savedData = await newUser.save();
    console.log(savedData);
    // Send a JSON response indicating success
    res.status(200).json({ message: 'User data saved successfully',id: savedData['_id']});
  } catch (error) {

    // Send a JSON response indicating an error
    console.log(error);
    res.status(501).json({ error: 'Failed to save user data' });
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
app.post('/sendNotification', async (req, res) => {
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



app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running at port ${port}`);
});
