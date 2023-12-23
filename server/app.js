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

//    // When users join a video call room
//    socket.on("joinVideoCallRoom", (roomId) => {
//        socket.join(roomId); // Join the room
//    // Logic to handle users joining a room
//    // Emit 'videoCallStarted' to the room when both users are ready
//    io.to(roomId).emit('videoCallStarted', { message: 'Video call is starting...' });
//    });
//
//    // Handle signaling between peers
//      socket.on('SDPOffer', (data) => {
//        // Handle SDP Offer and signal to the remote peer
//        io.to(roomId).emit('SDPOffer', data);
//      });
//
//      socket.on('answerCall', (data) => {
//        // Handle SDP Answer and signal to the caller
//        io.to(roomId).emit('callAnswered', data);
//      });
//      socket.on('newICECandidate', (data) => {
//        // Handle ICE candidates and signal to the other peer
//        io.to(roomId).emit('newICECandidate', data);
//      });
//
//    socket.on("disconnect", () => {
//      console.log("A user disconnected");
//      // Leave the room when a user disconnects
//      if (socket.room) {
//        socket.leave(socket.room);
//      }
//    });


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
      else{
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

//    // When users join a video call room
//    socket.on("joinVideoCallRoom", (roomId) => {
//        socket.join(roomId); // Join the room
//    // Logic to handle users joining a room
//    // Emit 'videoCallStarted' to the room when both users are ready
//    io.to(roomId).emit('videoCallStarted', { message: 'Video call is starting...' });
//    });
//
//    // Handle signaling between peers
//      socket.on('SDPOffer', (data) => {
//        // Handle SDP Offer and signal to the remote peer
//        io.to(roomId).emit('SDPOffer', data);
//      });
//
//      socket.on('answerCall', (data) => {
//        // Handle SDP Answer and signal to the caller
//        io.to(roomId).emit('callAnswered', data);
//      });
//      socket.on('newICECandidate', (data) => {
//        // Handle ICE candidates and signal to the other peer
//        io.to(roomId).emit('newICECandidate', data);
//      });
//
//    socket.on("disconnect", () => {
//      console.log("A user disconnected");
//      // Leave the room when a user disconnects
//      if (socket.room) {
//        socket.leave(socket.room);
//      }
//    });


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
