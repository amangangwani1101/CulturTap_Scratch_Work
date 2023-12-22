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

    for(let i=0;i<listOfCheckerPage.length;i++){
        if(listOfCheckerPage[i].meetStatus=='pending'){
            res.status(200).json({ message: "Check Pings",meetId:listOfCheckerPage[i].meetId});
            return;
        }
    }

    res.status(200).json({ message: "Checked Pings",meetId:'' });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;