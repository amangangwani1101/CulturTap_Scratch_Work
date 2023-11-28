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
    res.status(200).json({  isEligible: status});
    return;
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
});


// update cards of users
router.patch('/updateCards',async(req,res)=>{
    try{
       let { userId,cards} = req.body;
       const user2 = await ProfileData.findById(userId).lean();

       if (!user2) {
         return res.status(404).json({ error: "User Not Found" });
       }

       user2['userPaymentData'] = cards;

       // Save the updated user timings
       await ProfileData.findByIdAndUpdate(userId, user2);
       res.status(200).json({ message: "User Cards updated successfully" });
    }catch(err){
        console.log('Error,',err);
        res.status(500).json({ error: "Internal server error" });
    }
});


// update profile section
router.patch('/updateProfile',async(req,res)=>{
    try{
       let updatedFields = req.body;
       console.log(updatedFields);
       const user = await ProfileData.findById(updatedFields['userId']).lean();
       if (!user) {
         return res.status(404).json({ error: "User Not Found" });
       }

       for (const key in updatedFields) {
         if (updatedFields[key]) {
            user[key] = updatedFields[key];
         }
       }
       // Save the updated user timings
       await ProfileData.findByIdAndUpdate(updatedFields['userId'], user);
       res.status(200).json({ message: "User Details updated successfully" });
    }catch(err){
        console.log('Error,',err);
        res.status(500).json({ error: "Internal server error" });
    }
});

router.get('/profileDetails/:id',async(req,res)=>{
    try{
       const userId = req.params.id;
       const user = await ProfileData.findById(userId).lean();
       if (!user) {
         return res.status(404).json({ error: "User Not Found" });
       }
        res.status(200).json(
            {
                homeCity:user['userPlace'],
                profession:user['userProfession'],
                dob:user['userAge'],
                dateOfBirth:user['userDOB'],
                gender:user['userGender'],
                imagePath:user['userPhoto'],
                name:user['userName'],
                quote:user['userQuote'],
                language:user['userLanguages']
            }
        );
    }catch(err){
        console.log('Error,',err);
        res.status(500).json({ error: "Internal server error" });
    }
});


//router.get('/professionList',async(req,res)=>{
//    try{
//        const DropDownListData = db.collection('yourCollectionName');
//    }catch(err){
//        console.log('Error,',err);
//        res.status(500).json({ error: "Internal server error" });
//    }
//});

router.get('/profileStatus/:id',async(req,res)=>{
    try{
       const userId = req.params.id;
       const user = await ProfileData.findById(userId).lean();
       console.log(user);
       if (!user) {
            return res.status(404).json({ error: "User Not Found" });
       }
       res.status(200).json({status:user['profileStatus']});
    }catch(err){
        console.log(err);
        res.status(500).json({ error: "Internal server error" });
    }
});


router.patch('/updateServices',async(req,res)=>{
    try{
       let { userId,state} = req.body;
       const user = await ProfileData.findById(userId).lean();

       if (!user) {
            return res.status(404).json({ error: "User Not Found" });
       }
       user['userServiceTripAssistantData'] = state;

       await ProfileData.findByIdAndUpdate(userId, user);
       res.status(200).json({ message: "User Services Updated Successfully" });
    }catch(err){
        console.log(err);
        res.status(500).json({ error: "Internal server error" });
    }
});
module.exports = router;