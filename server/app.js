const express = require('express');
const app = express();
const cors = require('cors');
const { ObjectId } = require("mongodb"); // Import ObjectId for querying by ID
const { MongoClient } = require("mongodb");
const http = require("http");
const socketIo = require("socket.io");
const mongoose = require("mongoose");
const nearByPlacesRouter = require('./routes/nearByPlaceRouter.js');
const getStoriesByUsers = require('./routes/getStoriesByUser.js');
const getStoriesByCategory = require('./routes/getStoriesByCategories.js');
const getStoriesByGenre = require('./routes/getStoriesByGenre.js');
const getStoriesByGenres = require('./routes/getStoriesByGenres.js');
const multer = require('multer');
const path = require('path');
const axios = require('axios');
const schedule = require('node-schedule');

const videosFolder = path.join(__dirname, '../videos');
const thumbnailsFolder = path.join(__dirname, '../thumbnails');

app.use('/videos', express.static(videosFolder));
app.use('/thumbnails', express.static(thumbnailsFolder));

const port = 8080;
require('./db/conn.js');


const mainRoute = require('./routes/mainRoute.js');



// const streetFoods = require('./routes/streetFoods.js');
// const homePageRoute = require('./routes/homePageRoute.js');
// const nationalParks = require('./routes/nearByNationalParks.js');
// const riverSide = require('./routes/nearByRiverside.js');
// const aquaticEcosystem = require('./routes/nearByAquaticEcosystem.js');
// const island = require('./routes/nearByIsland.js');
const searchBar = require('./routes/searchBar.js');


const MeetingsData = require('./db/model/chatDetailsData.js');
// router files declaration
const {SignUp} = require('./routes/LoginSignUpRoutes.js');
const ProfileRoutes = require('./routes/ProfileRoutes.js');
const SettingRoutes = require('./routes/SettingRoutes.js');
const MeetData = require("./db/model/localAssistantChatDetails.js");
const ScheduleMeet = require('./routes/TripPlaningRoutes/ScheduleMeet.js');
const ConfirmMeet = require('./routes/TripPlaningRoutes/ConfirmSetMeet.js');
const UpdateMeetStatus = require('./routes/TripPlaningRoutes/UpdateStatusMeet.js');
const PaymentSection = require('./routes/TripPlaningRoutes/PaymentSection.js');
const LocalAssisatntUpdates = require('./routes/TripAssistantRoutes/SchedulesHelp.js');
const LocalAssisatntChatsUpdates = require('./routes/TripAssistantRoutes/ChatsUpdates.js');
const UserData = require('./db/model/UserData.js');
const LocalAssisatntPings = require('./routes/TripAssistantRoutes/PingsChecker.js')
const localAssistantPayment = require('./routes/TripAssistantRoutes/LocalAssistantPaymentSection.js');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));



// app.use('/main', mainRoute);
// app.use('/food',streetFoods);
// app.use('/parks',nationalParks);
// app.use('/riverside', riverSide);
// app.use('/ecosystem',aquaticEcosystem);
// app.use('/island',island);
app.use('/search',searchBar);


app.use('/main', require('./routes/mainRoute.js'));
app.use('/api', nearByPlacesRouter);
app.use('/api', getStoriesByUsers);
app.use('/api', getStoriesByCategory);
app.use('/api', getStoriesByGenre);
app.use('/api', getStoriesByGenres);

// app.use('/food', require('./routes/streetFoods.js'));
// app.use('/parks', require('./routes/nearByNationalParks.js'));
// app.use('/riverside', require('./routes/nearByRiverside.js'));
// app.use('/ecosystem', require('./routes/nearByAquaticEcosystem.js'));
// app.use('/festival', require('./routes/FestivalNearYou.js'));
// app.use('/island', require('./routes/nearByIsland.js'));





// app.post('/SignUp', async (req, res) => {
//   try {

//     const newUser = await UserData({userName : req.body.userName,phoneNumber : req.body.phoneNumber});
//     const savedData = await newUser.save();

//     // Send a JSON response indicating success
//     res.status(200).json({ message: 'User data saved successfully' });
//   } catch (error) {

//     // Send a JSON response indicating an error
//     console.log(error);
//     res.status(501).json({ error: 'Failed to save user data' });
//   }
// });




const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running at port ${port}`);
});




// Trip Planning Socket Connector
const io = socketIo(server);
const tripPlanningNamespace = io.of('/localAssistan');
const localAssistantNamespace = io.of('/localAssistant');

app.get("/", (req, res) => {
  res.send("I'm On!!");
});

// SignUp Routes
app.use('/SignUp',SignUp);

//Profile Section Routes
app.use('/',ProfileRoutes);

// Trip Planing Routes includes meeting details , check for overlapping meets
app.use('/',ScheduleMeet);

//Settings Section Routes
app.use('/',SettingRoutes);

// Trip Planing Routes includes user day plans and updation , update meeting conversation ,feedback
app.use('/',ConfirmMeet);

// Trip Planing Routes Update Meet Status , notification sender
app.use('/',UpdateMeetStatus);

// handle stripe payment gateway
app.use('/',PaymentSection);

// local assistant meet and status updates
app.use('/',LocalAssisatntUpdates);

// local assistant chats updates
app.use('/',LocalAssisatntChatsUpdates);

// local assitant pings check
app.use('/',LocalAssisatntPings);

// payment link section in local assistant
app.use('/',localAssistantPayment);




// socket connection and chat functions and features
tripPlanningNamespace.on("connection", (socket) => {

  console.log("A user connected");

  // Listen for incoming messages from clients
  try {
    // Listen for incoming messages from clients
    socket.on("message", (data) => {
      // 'data' should contain the multiple parameters passed from the client
      console.log(data);
      const { message, user1, user2 } = data;

      console.log("Message:", message);
      console.log("User1:", user1);
      console.log("User2:", user2);

      // Broadcast the message to all connected clients in the same room based on 'user1' and 'user2'
      if (user1 === '') {
        io.to(socket.room).emit("message", { message: message, user: "receiver" });
      } else {
        io.to(socket.room).emit("message", { message: message, user: "sender" });
      }
    });

    // Join the room using MongoDB ID as a unique identifier
    socket.on("join", async (uniqueIdentifier, senderId, receiverId) => {
      // Check if the MongoDB ID is valid
      const meetingIdVerification = await MeetingsData.findById(
        uniqueIdentifier
      );
      console.log("Qwe:", meetingIdVerification);
      if (meetingIdVerification === null && !meetingIdVerification._id) {
        socket.emit("roomNotFound", "Invalid room identifier");
        console.log("Meeting not found or invalid");
        return;
      }

       // Trip Planning Chat Join Handler
      // Check if the sender and receiver exist in your MongoDB records
      let senderExists, receiverExists;
      if (senderId != "") senderExists = meetingIdVerification.sendersId;
      if (receiverId != "") receiverExists = meetingIdVerification.receiversId;

      if (
        (senderId != "" && senderId == senderExists) ||
        (receiverId != "" && receiverId == receiverExists)
      ) {
        socket.join(uniqueIdentifier);
        console.log(uniqueIdentifier);
        socket.room = uniqueIdentifier;
      } else {
        socket.emit("roomNotFound", "Sender or receiver not found.");
        console.log("Room is not for u!");
        socket.leave(socket.room);
      }
    });




    // voice call functioanlity
    socket.on('offer', (data) => {
    console.log(data);
    // Broadcast the offer to everyone in the room except the sender
    socket.to(socket.room).emit('offer', data);
      });

      socket.on('answer', (data) => {
        // Broadcast the answer to everyone in the room except the sender
        socket.to(socket.room).emit('answer', data);
      });

      socket.on('iceCandidate', (data) => {
        // Broadcast ICE candidates to everyone in the room except the sender
        socket.to(socket.room).emit('iceCandidate', data.candidate);
      });
  } catch (e) {
    console.log(e);
  }
});

// socket connection and chat functions and features
localAssistantNamespace.on("connection", (socket) => {

  console.log("Local Assistant user connected");

  // Listen for incoming messages from clients
  try {
    // Listen for incoming messages from clients
    socket.on("message", (data) => {
      // 'data' should contain the multiple parameters passed from the client
      console.log(data);
      const { message, user1, user2 } = data;

      console.log("Message:", message);
      console.log("User1:", user1);
      console.log("User2:", user2);

      // Broadcast the message to all connected clients in the same room based on 'user1' and 'user2'
      if (user1 === '' && user2==='helper') {
        localAssistantNamespace.to(socket.room).emit("message", { message: message, user: "helper" });
      } else if(user1==='user' && user2===''){
        localAssistantNamespace.to(socket.room).emit("message", { message: message, user: "user" });
      }
      else {
        localAssistantNamespace.to(socket.room).emit("message", { message: message, user: user1 });
      }
    });

    // Local Assistant Chat Handler
    // Join the room using MongoDB ID as a unique identifier
    socket.on("join", async (uniqueIdentifier) => {
      // Check if the MongoDB ID is valid
      const meetingIdVerification = await MeetData.findById(
        uniqueIdentifier
      );
      console.log("Qwe:", meetingIdVerification);
      if (meetingIdVerification === null) {
        socket.emit("roomNotFound", "Invalid room identifier");
        console.log("Meeting not found or invalid");
        return;
      }

        socket.join(uniqueIdentifier);
        console.log(uniqueIdentifier);
        socket.room = uniqueIdentifier;
    });


    // voice call functioanlity
    socket.on('offer', (data) => {
    console.log(data);
    // Broadcast the offer to everyone in the room except the sender
    socket.to(socket.room).emit('offer', data);
      });

      socket.on('answer', (data) => {
        // Broadcast the answer to everyone in the room except the sender
        socket.to(socket.room).emit('answer', data);
      });

      socket.on('iceCandidate', (data) => {
        // Broadcast ICE candidates to everyone in the room except the sender
        socket.to(socket.room).emit('iceCandidate', data.candidate);
      });
  } catch (e) {
    console.log(e);
  }
});

// video call connection
io.use((socket, next) => {
  if (socket.handshake.query) {
    let callerId = socket.handshake.query.callerId;
    socket.user = callerId;
    next();
  }
});
io.on("connection", (socket) => {
  console.log(socket.user, "Connected");
  socket.join(socket.user);

  socket.on("makeCall", (data) => {
    let calleeId = data.calleeId;
    let sdpOffer = data.sdpOffer;
    let section = data.section;
    let imageOwn = data.imageOwn;
    let imageOther = data.imageOther;

    socket.to(calleeId).emit("newCall", {
      callerId: socket.user,
      sdpOffer: sdpOffer,
      section:section,
      imageOwn:imageOwn,
      imageOther:imageOther
    });
  });

  socket.on("answerCall", (data) => {
    let callerId = data.callerId;
    let sdpAnswer = data.sdpAnswer;

    socket.to(callerId).emit("callAnswered", {
      callee: socket.user,
      sdpAnswer: sdpAnswer,
    });
  });

  socket.on("IceCandidate", (data) => {
    let calleeId = data.calleeId;
    let iceCandidate = data.iceCandidate;

    socket.to(calleeId).emit("IceCandidate", {
      sender: socket.user,
      iceCandidate: iceCandidate,
    });
  });

  socket.on('leaveCall',(data)=>{
    let id = data.id;
    socket.to(id).emit('leaveCall',{});
  });
});


// schedule notification :: sending notification to more user for help of needy
const job = schedule.scheduleJob('*/1 * * * *', async () => {
  try {
    const currentDateTime = new Date();
    const fiveMinutesAfter = new Date(currentDateTime.getTime() + 5 * 60000); // 5 minutes after current time

    const meetings = await MeetData.find({
      paymentStatus: 'pending',
      helperIds: { $exists: true, $ne: [] }
//      time: { $gte: fiveMinutesAfter },
    });
    console.log(meetings);
    for (const meeting of meetings) {
      const helperIds = meeting.helperIds;
        if(helperIds.length>0){

          const users = await UserData.find({ userId: { $in: helperIds } });
          // Extract user tokens
          const userTokens = users.map(user => user.userToken);
          // Send notification to each user
          for (const token of userTokens) {
            await sendNotification(token, 'Meeting Reminder', 'Your meeting will start soon.');
          }
        // Update the meeting to mark reminder as sent
        // meeting.reminderSent = true;
        // await meeting.save();
       }
    }
  } catch (error) {
    console.error('Error sending meeting reminders:', error);
  }
});
// Handle errors in the scheduler
job.on('error', err => {
  console.error('Scheduler error:', err);
});

// schedule notification  :: reminder before closing meet in local assistants
const job2 = schedule.scheduleJob('*/1 * * * *', async () => {
  try {
    const currentDateTime = new Date();
    const eightyFiveMinutesAfter = new Date(currentDateTime.getTime() + 2 * 60000); // 85 minutes after current time

    const meetingsToNotify = await MeetData.find({
      paymentStatus: { $eq: 'pending' },
//      time: { $gte: eightyFiveMinutesAfter }
    });
    console.log('Current Time:', currentDateTime);
    console.log('Eighty-Five Minutes After:', eightyFiveMinutesAfter);

    for (const meeting of meetingsToNotify) {
      const userId = meeting.userId;
      console.log('Meeting Time from DB:', meeting.time);
      const helperId = meeting.helperId;

      // get from firebase
      // if(user['uniqueToken']!=null){}
      // await sendNotificationToUser(token, 'Meeting Update', 'Meeting has an update');
      // Compare current time with time field of the meeting
       const ninetyMinutesAfterMeetingTime = new Date(meeting.time.getTime() + 3 * 60000);
       const meetId =  (meeting._id).toString();
       if (currentDateTime >= ninetyMinutesAfterMeetingTime) {
        await MeetData.findByIdAndUpdate(meeting._id, { paymentStatus: 'close' });
        try {
          const userUpdateResult = await UserData.updateOne(
            { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
            { $set: { 'userServiceTripAssistantData.$.meetStatus': 'close' } }
          );

          console.log('User Update Result:', userUpdateResult);

          const helperUpdateResult = await UserData.updateOne(
            { _id: helperId, 'userServiceTripAssistantData.meetId': meetId },
            { $set: { 'userServiceTripAssistantData.$.meetStatus': 'close' } }
          );

          console.log('Helper Update Result:', helperUpdateResult);
        } catch (error) {
          console.error('Error updating meetStatus:', error);
        }
       }
    }
  } catch (error) {
    console.error('Error in meeting updates:', error);
  }
});
job2.on('error', err => {
  console.error('Scheduler closer error:', err);
});


// paymentStatus -> meetStatus -> initiated,pending,closed
// for 1st case : paymentStatus : initiated , helperIds : length>0 -> send notification after 5min
// for 2nd case : paymentStatus : pending , time exceeds 90 min case then updated paymentStaus : close


// Function to send notifications from firebase
async function sendNotificationToUser(userToken, title, body) {
  const data = {
    to: userToken,
    priority: 'high',
    notification: {
      title: title,
      body: body,
    },
  };

  try {
    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      body: JSON.stringify(data),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAPpVuKrI:APA91bF7BA61C5dlBD65HIs4KY1Ljw5rHZ1FyNxuqjEpQUjfnQJMkhxf71XKlk2dK3fkjRVYG7gErT4lZj2lluhZVsdaHPeyjWKGQ6AcUZlNeXLTiuKxnnVgO21EowO0ATcxKSBd2EK7',
      },
    });

    if (response.ok) {
      console.log('Notification sent successfully');
    } else {
      console.error('Failed to send notification:', response.statusText);
    }
  } catch (error) {
    console.error('Failed to send notification:', error.message);
  }
}