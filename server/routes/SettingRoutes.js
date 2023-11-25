const express = require('express');
const router = express.Router();

//required db
const ProfileData = require("../db/model/profileData.js");
const MeetingsData = require("../db/model/chatDetailsData.js");

// overlapping meeting or not
router.patch("/checkServiceStatus", async (req, res) => {
  try {
    let { userId} = req.body;
    const user2 = await ProfileData.findById(userId).lean();

    if (!user2) {
      return res.status(404).json({ error: "User Not Found" });
    }

    if (!user2.userServiceTripCallingData.dayPlans) {
      const updateFields = { $unset: { 'userServiceTripCallingData.startTimeFrom': 1, 'userServiceTripCallingData.endTimeTo': 1 ,'userServiceTripCallingData.slotsChossen':1}};
      await ProfileData.findByIdAndUpdate(userId, updateFields);
      res.status(200).json({ isEligible: true });
      return;
    }

    const dayPlans = user2.userServiceTripCallingData.dayPlans;

    console.log(dayPlans);
    let status = true;
    for (const [, value] of Object.entries(dayPlans)) {
        const meetings = value['meetingStatus'];
        for (let i = 0; i < meetings.length; i++) {
            if(meetings[i]!=='closed' && meetings[i]!=='cancel'){
                status = false;
            }
        }
        if(!status){
            break;
        }
    };
    if(status){
        const updateFields = { $unset: { 'userServiceTripCallingData.startTimeFrom': 1, 'userServiceTripCallingData.endTimeTo': 1 ,'userServiceTripCallingData.slotsChossen':1}};
        await ProfileData.findByIdAndUpdate(userId, updateFields);
    }
    res.status(200).json({  isEligible: status});
    return;
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;