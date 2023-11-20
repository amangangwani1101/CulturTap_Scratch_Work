const express = require("express");
const app = express();
const cors = require('cors');
const { ObjectId } = require("mongodb"); // Import ObjectId for querying by ID
const { MongoClient } = require("mongodb");
const http = require("http");
const socketIo = require("socket.io");
const mongoose = require("mongoose");

// port
const port = 8080;

// database connection
require('./db/conn.js');
const MeetingsData = require("./db/model/chatDetailsData.js");

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// router files declaration
const {SignUp} = require('./routes/LoginSignUpRoutes.js');
const ProfileRoutes = require('./routes/ProfileRoutes.js');
const ScheduleMeet = require('./routes/TripPlaningRoutes/ScheduleMeet.js');
const ConfirmMeet = require('./routes/TripPlaningRoutes/ConfirmSetMeet.js');
const UpdateMeetStatus = require('./routes/TripPlaningRoutes/UpdateStatusMeet.js');
const PaymentSection = require('./routes/TripPlaningRoutes/PaymentSection.js');

// server connection
const server = app.listen(port, "0.0.0.0", () => {
  console.log(`Server is running at port ${port}`);
});

const io = socketIo(server);


app.get("/", (req, res) => {
  res.send("I'm On!!");
});

// SignUp Routes
app.use('/SignUp',SignUp);

//Profile Section Routes
app.use('/',ProfileRoutes);

// Trip Planing Routes includes meeting details , check for overlapping meets
app.use('/',ScheduleMeet);

// Trip Planing Routes includes user day plans and updation , update meeting conversation ,feedback
app.use('/',ConfirmMeet);

// Trip Planing Routes Update Meet Status , notification sender
app.use('/',UpdateMeetStatus);

// handle stripe payment gateway
app.use('/',PaymentSection);

// socket connection and chat functions and features
io.on("connection", (socket) => {

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
      if (meetingIdVerification === null || !meetingIdVerification._id) {
        socket.emit("roomNotFound", "Invalid room identifier");
        console.log("Meeting not found or invalid");
        return;
      }

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




