const express = require('express');
const router = express.Router();

// required database
const ProfileData = require("../../db/model/profileData.js");
const MeetingsData = require("../../db/model/chatDetailsData.js");

// update user day plans
router.post("/updateUserDayPlans", async (req, res) => {
  try {
    const { userId, date, startTime, endTime, meetingId,meetingStatus,meetingTitle,id,meetingType,userName,userPhoto } = req.body;

    const user = await ProfileData.findById(userId).lean();

    if (!user) {
      return res.status(404).json({ message: "User Not Found" });
    }
    if(!user.userServiceTripCallingData){
        user.userServiceTripCallingData = {
            dayPlans:null,
        }
    }

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
        userName:[userName],
        userPhoto:[userPhoto],
      };
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
      user.userServiceTripCallingData.dayPlans[date].userName.push(userName);
      user.userServiceTripCallingData.dayPlans[date].userPhoto.push(userPhoto);
    }

    // Sort the dates in decreasing order before saving
   const sortedDayPlans = Object.fromEntries(
     Object.entries(user.userServiceTripCallingData.dayPlans)
       .sort((a, b) => new Date(b[0]) - new Date(a[0]))
   );

   user.userServiceTripCallingData.dayPlans = sortedDayPlans;

  // Save the updated user data
  await ProfileData.findByIdAndUpdate(userId, user);
   res.status(200).json({ message: "User dayPlans updated successfully" });
  } catch (e) {
    console.log(e);
    return;
  }
});

// store meeting conversation
router.patch('/storeMeetingConversation', async (req, res) => {
  try {
    const { meetId, conversation } = req.body;

    const meet = await MeetingsData.findById(meetId);

    if (!meet) {
      return res.status(404).json({ message: "Meeting Not Found" });
    }

    if (!meet.conversation) {
      meet.conversation = conversation;
    }

    await meet.save();
    res.status(200).json({ message: "Conversation stored successfully" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

//update feedback meeting
router.patch("/updateMeetingFeedback", async (req, res) => {
    try{
        const { meetId,rating,info,type} = req.body;

        const meet = await MeetingsData.findById(meetId);

        if(!meet){
            return res.status(404).json({ message: "Meeting Not Found" });
        }

        if(type=='sender'){
            if(!meet.sendersFeedback){
                meet.sendersFeedback = {
                    rating:null,
                    info:null,
                }
            }
            meet.sendersFeedback.rating = rating;
            meet.sendersFeedback.info = info;
        }
        else{
            if(!meet.receiversFeedback){
                meet.receiversFeedback = {
                    rating:null,
                    info:null,
                }
            }
            meet.receiversFeedback.rating = rating;
            meet.receiversFeedback.info = info;
        }
        await meet.save();
        res.status(200).json({ message: "Meeting status updated successfully" });
    }catch (error) {
     console.log(error);
     return res.status(500).json({ message: "Internal Server Error" });
   }
});


module.exports  = router;