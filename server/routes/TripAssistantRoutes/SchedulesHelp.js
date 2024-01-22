const express = require('express');
const router = express.Router();

// required database
const ProfileData = require("../../db/model/profileData.js");
const MeetData = require("../../db/model/localAssistantChatDetails.js");

router.post("/updateLocalAssistantMeetDetails", async (req, res) => {
  try {
    const { userId, helperIds,meetTitle,paymentStatus,time,helperIds2,helperDist,helperDist2 } = req.body;
    const meet = new MeetData({userId,helperIds,meetTitle,paymentStatus,time,helperIds2,helperDist,helperDist2});
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
    const { userId, time, title ,distances,helperIds,meetId,meetStatus,userName,userPhoto,date} = req.body;

    for (let i = 0; i < helperIds.length; i++) {
        const helperId = helperIds[i];
        const user = await ProfileData.findById(helperId).lean();
        if(!user){
            return res.status(404).json({ message: "User Not Found" });
        }
        if(!user.userServiceTripAssistantData || user.userServiceTripAssistantData === null){
            user.userServiceTripAssistantData = [];
        }
        const setCard =  {userId:userId,title:title,time:time,date:date,distance:distances[i],meetId:meetId,meetStatus:meetStatus,userName,userPhoto};
        user.userServiceTripAssistantData.push(setCard);
        await ProfileData.findByIdAndUpdate(helperId, user);
    }
    res.status(200).json({ message: "Request sent successfully" });
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
        return res.status(404).json({ message: "Either userid/meetid not exist" });
    }

    let listUser = meet.helperIds;
  	let distance;
    for(let i=0;i<listUser.length;i++){
        if(listUser[i]!=userId){
            await ProfileData.findByIdAndUpdate(listUser[i], { $pull: {userServiceTripAssistantData : {meetId:meetId} } });
        }else{
            await ProfileData.updateOne(
              { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
              { $set: { 'userServiceTripAssistantData.$.meetStatus': meetStatus,} }
            );
        }
    }
	// working
  	if(meet.helperIds!==undefined){
    	if(meet.helperIds2.length>0){
    		await MeetData.findByIdAndUpdate(meetId, { $unset: { 'helperIds': 1,'helperIds2':1,'helperDist':1,'helperDist2':1},$set:{'helperId':userId}});
    	}else{
    		await MeetData.findByIdAndUpdate(meetId, { $unset: { 'helperIds': 1,'helperDist':1},$set:{'helperId':userId}});
    	}
    }
    res.status(200).json({ message: "Pings updated successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});



router.patch("/removeHelperPings", async (req, res) => {
  try {
    const {meetId} = req.body;

    const meet = await MeetData.findById(meetId);
	if(!meet){
        return res.status(404).json({ message: "Either userid/meetid not exist" });
    }
  
  	let listUser = meet['helperIds'];
  
    for(const users of listUser){
       	await ProfileData.findByIdAndUpdate(users, { $pull: {userServiceTripAssistantData : {meetId:meetId} } });
    }

    await MeetData.findByIdAndUpdate(meetId, { $set:{'paymentStatus':'cancel'} });

    res.status(200).json({ message: "Pings removed successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});


router.put("/setUpdateUserPings", async (req, res) => {
  try {
    const { userId, time, title ,distance,helperId,meetId,meetStatus,userName,userPhoto,date} = req.body;

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
            setCard =  {userId:userId,title:title,time:time,meetId:meetId,meetStatus:meetStatus,date:date};
            user.userServiceTripAssistantData.push(setCard);
            await ProfileData.findByIdAndUpdate(userId, user);
            res.status(200).json({ message: "New Meeting created successfully" });
        }
        else{
            await ProfileData.updateOne(
                { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
                { $set: { 'userServiceTripAssistantData.$.distance': distance,
                'userServiceTripAssistantData.$.userName': userName,
                'userServiceTripAssistantData.$.userPhoto': userPhoto,
                 'userServiceTripAssistantData.$.meetStatus': meetStatus,
                 'userServiceTripAssistantData.$.helperId': helperId,        
                 }}
            );
            res.status(200).json({ message: "Found helper and details updated successfully" });
        }
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "not able to create/update user meeting details" });
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

router.get("/getLocalUserPingsStatus/:userId/:meetId", async (req, res) => {
  try {
    const { userId, meetId } = req.params;
    console.log(req.params);
    const user = await ProfileData.findById(userId).lean();

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    let meetStatus;
    let savedData = user.userServiceTripAssistantData;
    for(let i=0;i<savedData.length;i++){
        if(savedData[i]['meetId']==meetId){
            meetStatus=savedData[i]['meetStatus'];
        	break;
        }
    }
//    const userData = await ProfileData.findOne(
//      { _id: userId, 'userServiceTripAssistantData.meetId': meetId },
//      { 'userServiceTripAssistantData.meetStatus': 1, _id: 0 }
//    ).lean();
//    console.log('Users Data :: ',userData);
//    if (!userData) {
//      return res.status(404).json({ message: "MeetId not found for the user" });
//    }
//
//    const meetStatus = userData.userServiceTripAssistantData[0].meetStatus;

    res.status(200).json({ meetStatus });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});




module.exports = router;