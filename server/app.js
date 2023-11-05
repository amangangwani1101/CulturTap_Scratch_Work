const express = require("express");
const app = express();
const port = 8080;
require("./db/conn.js");
const ProfileData = require("./db/model/profileData.js");
const MeetingsData = require("./db/model/chatDetailsData.js");
const cors = require("cors");
const { ObjectId } = require("mongodb"); // Import ObjectId for querying by ID
const { MongoClient } = require("mongodb");
const http = require("http");
const socketIo = require("socket.io");
const mongoose = require("mongoose");
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

const server = app.listen(port, "0.0.0.0", () => {
  console.log(`Server is running at port ${port}`);
});

const io = socketIo(server);

app.get("/", (req, res) => {
  res.send("this is my flutter page");
});

app.get("/userStoredData/:id", async (req, res) => {
  const id = req.params.id;

  try {
    const data = await ProfileData.findOne({ _id: id });
    if (data) {
      //            console.log(data);
      res.status(200).json(data);
    } else {
      res.status(404).json({ message: "Data not found" });
    }
  } catch (error) {
    console.error("Error fetching data:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

app.post("/profileSection", async (req, res) => {
  try {
    console.log("I am", req.body);
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const newUser = await ProfileData(req.body);
    const savedData = await newUser.save();

    // Send a JSON response indicating success
    res
      .status(200)
      .json({ _id: savedData["_id"], message: "User data saved successfully" });
  } catch (error) {
    // Send a JSON response indicating an error
    console.log(error);
    res.status(501).json({ error: "Failed to save user data" });
  }
});

app.post("/checkMeetingTime", async (req, res) => {
  try {
    let { userId, chosenDate, chosenStartTime, chosenEndTime } = req.body;
    const user2 = await ProfileData.findById(userId).lean();
//    const user2 = user.lean();
    console.log(chosenDate);
    if (!user2) {
      return res.status(404).json({ error: "User Not Found" });
    }
    const key = user2.userServiceTripCallingData;
    console.log(Object.keys(user2.userServiceTripCallingData));

    if (!user2.userServiceTripCallingData.dayPlans || !user2.userServiceTripCallingData.dayPlans[chosenDate]) {
      return res.status(200).json({ isOverlap: false });
    }
    console.log(1);
    // Extract existing meetStartTimes and meetEndTimes for the chosen date
    console.log("Start Time:", chosenStartTime);
    console.log("End Time:", chosenEndTime);
    console.log(user2.userServiceTripCallingData.dayPlans);
    const meetStartTimes =
      user2.userServiceTripCallingData.dayPlans[chosenDate]
        .meetStartTime;
    console.log(meetStartTimes);
    const meetEndTimes =
      user2.userServiceTripCallingData.dayPlans[chosenDate].meetEndTime;
    console.log(meetEndTimes);
    // Check for time overlap
    for (let i = 0; i < meetStartTimes.length; i++) {
      const existingStartTime = meetStartTimes[i];
      const existingEndTime = meetEndTimes[i];
      if (
        (chosenStartTime <= existingEndTime &&
          chosenStartTime >= existingStartTime) ||
        (chosenEndTime >= existingStartTime && chosenEndTime <= existingEndTime)
      ) {
        return res.status(200).json({ isOverlap: true });
      }
      console.log(2);
    }
    // No overlap found, return true
    res.status(200).json({ isOverlap: false });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/scheduleMeeting", async (req, res) => {
  try {
    console.log("I am", req.body);
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const newUser = await MeetingsData(req.body);
    console.log(newUser);
    const savedData = await newUser.save();

    // Send a JSON response indicating success
    res
      .status(200)
      .json({ _id: savedData["_id"], message: "User data saved successfully" });
  } catch (error) {
    // Send a JSON response indicating an error
    console.log(error);
    res.status(501).json({ error: "Failed to save user data" });
  }
});


//require some modification
app.post("/updateUserDayPlans", async (req, res) => {
  try {
    const { userId, date, startTime, endTime, meetingId,meetingStatus,meetingTitle,id,meetingType } = req.body;

    const user = await ProfileData.findById(userId).lean();

    if (!user) {
      return res.status(404).json({ message: "User Not Found" });
    }
    if(!user.userServiceTripCallingData){
        user.userServiceTripCallingData = {
            dayPlans:null,
        }
    }
    console.log(Object.keys(user.userServiceTripCallingData));
    if (!user.userServiceTripCallingData.dayPlans) {
        user.userServiceTripCallingData.dayPlans ={};
    }
    if (!user.userServiceTripCallingData.dayPlans[date]) {
      // If date does not exist, create a new entry with the provided data
      user.userServiceTripCallingData.dayPlans[date] = {
        meetStartTime: [startTime],
        meetEndTime: [endTime],
        meetingId: [meetingId],
        meetingStatus:[meetingStatus],
        meetingTitle:[meetingTitle],
        userId:[id],
        meetingType:[meetingType],
      };
      console.log(user.userServiceTripCallingData.dayPlans[date]);
    } else {
      // If date exists, push new data to the existing arrays
      console.log(user.userServiceTripCallingData.dayPlans[date]);
      user.userServiceTripCallingData.dayPlans[date].meetStartTime.push(startTime);
      user.userServiceTripCallingData.dayPlans[date].meetEndTime.push(endTime);
      user.userServiceTripCallingData.dayPlans[date].meetingId.push(meetingId);
      user.userServiceTripCallingData.dayPlans[date].meetingStatus.push(meetingStatus);
      user.userServiceTripCallingData.dayPlans[date].meetingTitle.push(meetingTitle);
      user.userServiceTripCallingData.dayPlans[date].userId.push(id);
      user.userServiceTripCallingData.dayPlans[date].meetingType.push(meetingType);
    }

    // Sort the dates in decreasing order before saving
   const sortedDayPlans = Object.fromEntries(
     Object.entries(user.userServiceTripCallingData.dayPlans)
       .sort((a, b) => new Date(b[0]) - new Date(a[0]))
   );

   user.userServiceTripCallingData.dayPlans = sortedDayPlans;

    // Save the updated user data
      await ProfileData.findByIdAndUpdate(userId, user);
//    console.log(user.userServiceTripCallingData.dayPlans);
    res.status(200).json({ message: "User dayPlans updated successfully" });
  } catch (e) {
    console.log(e);
    return;
  }
});

//cacncel meet request
app.patch("/cancelMeeting", async (req, res) => {
  try {
    const { userId, date, index ,setStatus,user2Id,set2Status} = req.body;
    console.log('Am',req.body);
    const user = await ProfileData.findById(userId).lean();
    const user2 = await ProfileData.findById(user2Id).lean();
    console.log(userId);
    console.log(user2Id);
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
app.patch("/updateMeetingChats", async (req, res) => {
    try{
        const { meetId, sender, receiver} = req.body;
        console.log('Am',req.body);
        const meet = await MeetingsData.findById(meetId);
        console.log(meet);
        meet.sendersMsg = sender;
        meet.receiversMsg = receiver;

        await meet.save();
        res.status(200).json({ message: "Meeting status updated successfully" });
    }catch (error) {
     console.log(error);
     return res.status(500).json({ message: "Internal Server Error" });
   }
});

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
      if (meetingIdVerification === null && !meetingIdVerification._id) {
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
