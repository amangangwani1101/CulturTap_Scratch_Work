const express = require('express');
const router = express.Router();

// required database
const ProfileData = require("../../db/model/profileData.js");
const MeetData = require("../../db/model/localAssistantChatDetails.js");

router.post("/updateLocalAssistantMeetDetails", async (req, res) => {
  try {
    const { userId, helperIds,meetTitle } = req.body;
    const meet = new MeetData({userId,helperIds,meetTitle});
    const meetData = await meet.save();
    console.log(meetData);
    res.status(200).json({ message: 'Meets saved successfully',id: meetData['_id']});
  } catch (e) {
    console.log(e);
    return;
  }
});

router.post("/setLocalHelpersPings", async (req, res) => {
  try {
    const { userId, time, title ,distances,helperIds,meetId,meetStatus,userName,userPhoto} = req.body;

    for (let i = 0; i < helperIds.length; i++) {
        const helperId = helperIds[i];
        const user = await ProfileData.findById(helperId).lean();
        if(!user){
            return res.status(404).json({ message: "User Not Found" });
        }
        if(!user.userServiceTripAssistantData || user.userServiceTripAssistantData === null){
            user.userServiceTripAssistantData = [];
        }
        const setCard =  {userId:userId,title:title,time:time,distance:distances[i],meetId:meetId,meetStatus:meetStatus,userName,userPhoto};
        user.userServiceTripAssistantData.push(setCard);
        await ProfileData.findByIdAndUpdate(helperId, user);
    }
    res.status(200).json({ message: "Pings updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});




router.patch("/updateLocalHelpersPings", async (req, res) => {
  try {
    const { userId, meetId,meetStatus} = req.body;

    const meet = await MeetData.findById(meetId);
    const user = await ProfileData.findById(userId).lean();


    if(!user || !meet){
        return res.status(404).json({ message: "Something Gone Wrong!" });
    }


    let listUser = meet.helperIds;

    for(const users of listUser){
        if(users!=userId){
            await ProfileData.findByIdAndUpdate(users, { $pull: {userServiceTripAssistantData : {meetId:meetId} } });
        }else{
            await ProfileData.updateOne(
              { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
              { $set: { 'userServiceTripAssistantData.$.meetStatus': meetStatus } }
            );
        }
    }

    await MeetData.findByIdAndUpdate(meetId, { $unset: { 'helperIds': 1 },$set:{'helperId':userId} });

    res.status(200).json({ message: "Pings updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

router.put("/setUpdateUserPings", async (req, res) => {
  try {
    const { userId, time, title ,distance,helperId,meetId,meetStatus,userName,userPhoto} = req.body;

        const user = await ProfileData.findById(userId).lean();
        console.log(user);
        if(!user){
            return res.status(404).json({ message: "User Not Found" });
        }
        if(!user.userServiceTripAssistantData){
            user.userServiceTripAssistantData = [];
        }

        let setCard;
        if(!userName){
            setCard =  {userId:userId,title:title,time:time,meetId:meetId,meetStatus:meetStatus};
            user.userServiceTripAssistantData.push(setCard);
            await ProfileData.findByIdAndUpdate(userId, user);
        }else{
            await ProfileData.updateOne(
                { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
                { $set: { 'userServiceTripAssistantData.$.distance': distance,'userServiceTripAssistantData.$.userName': userName,'userServiceTripAssistantData.$.userPhoto': userPhoto, }}
            );
        }
        res.status(200).json({ message: "Pings updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});




router.patch("/updateLocalUserPings", async (req, res) => {
  try {
    const { userId,meetId,meetStatus} = req.body;

    const user = await ProfileData.findById(userId).lean();


    if(!user){
        return res.status(404).json({ message: "Something Gone Wrong!" });
    }

    await ProfileData.updateOne(
        { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
        { $set: { 'userServiceTripAssistantData.$.meetStatus': meetStatus } }
    );
    res.status(200).json({ message: "Pings updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});



module.exports = router;