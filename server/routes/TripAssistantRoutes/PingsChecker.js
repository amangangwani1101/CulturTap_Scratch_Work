const express = require('express');
const router = express.Router();

// required database
const ProfileData = require("../../db/model/profileData.js");
const MeetData = require("../../db/model/localAssistantChatDetails.js");


router.get("/checkLocalUserPings/:id", async (req, res) => {
  try {
    const userId = req.params.id;

    const user = await ProfileData.findById(userId).lean();
    if(!user){
        return res.status(404).json({ message: "User Not Found" });
    }


    let listOfCheckerPage = user.userServiceTripAssistantData;
    console.log('List',listOfCheckerPage);
    for(let i=0;i<listOfCheckerPage.length;i++){
        if(listOfCheckerPage[i].userId===userId && listOfCheckerPage[i].meetStatus==='pending'){
            res.status(200).json({ state: "user",meetId:listOfCheckerPage[i].meetId});
            return;
        }
        else if(listOfCheckerPage[i].userId!==userId && listOfCheckerPage[i].meetStatus!=='cancel' && listOfCheckerPage[i].meetStatus!=='close'){
            res.status(200).json({ state: "helper",meetId:listOfCheckerPage[i].meetId});
            return;
        }
    }
    for(let i=0;i<listOfCheckerPage.length;i++){
        if(listOfCheckerPage[i].userId===userId && listOfCheckerPage[i].meetStatus!=='cancel' && listOfCheckerPage[i].meetStatus!=='close'){
            res.status(200).json({ state: "user"});
            return;
        }
    }
    res.status(200).json({message:'clear'});
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;