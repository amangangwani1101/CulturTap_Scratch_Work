const express = require('express');
const router = express.Router();

// required db
const ProfileData = require("../db/model/profileData.js");


// update profile of user first time after signup
router.put("/profileSection", async (req, res) => {
    try {
      const dataset = req.body;
      const userId = dataset['userId'];
      // Get the user data from the request body
      const user = await ProfileData.findById(userId);
      // Create a new user document and save it to the database
      if (!user) {
        return res.status(404).json({ error: "User Not Found" });
      }

        console.log(user);
      // Update existing fields with new values
      Object.keys(dataset).forEach((key) => {
      if(key=='userServiceTripCallingData' && user['userServiceTripCallingData']){
            console.log(1);
            if(dataset[key]!==null){
                user[key]['startTimeFrom'] = dataset[key].startTimeFrom;
                user[key]['endTimeTo'] = dataset[key].endTimeTo;
                user[key]['slotsChossen'] = dataset[key].slotsChossen;
            }
            else{
             }
        }
        else{
          user[key] = dataset[key];
        }
      });

      const savedData = await user.save();

      // Send a JSON response indicating success
      res.status(200).json({message: "User data saved successfully" });
    } catch (error) {
      // Send a JSON response indicating an error
      console.log(error);
      res.status(501).json({ error: "Failed to save user data" });
    }
});


// fetch user details
router.get("/userStoredData/:id", async (req, res) => {
    const id = req.params.id;
    try {
      const data = await ProfileData.findOne({ _id: id });
//      console.log(data);
      if (data) {
        res.status(200).json(data);
      } else {
        res.status(404).json({ message: "Data not found" });
      }
    } catch (error) {
      console.error("Error fetching data:", error);
      res.status(500).json({ message: "Internal server error" });
    }
});

// update user service timing : TripCallingService
router.put("/updateUserTime",async (req,res)=>{
  try{
      let { userId, startTime, endTime, slot } = req.body;
      const user = await ProfileData.findById(userId).lean();
      if (!user) {
        return res.status(404).json({ error: "User Not Found" });
      }
      if(!user.userServiceTripCallingData){
          user.userServiceTripCallingData = {};
      }
      user.userServiceTripCallingData.startTimeFrom = startTime;
      user.userServiceTripCallingData.endTimeTo = endTime;
      user.userServiceTripCallingData.slotsChossen = slot;

      // Save the updated user timings
      await ProfileData.findByIdAndUpdate(userId, user);
      res.status(200).json({ message: "User timing updated successfully" });
  }catch(err){
      console.log('Error:',err);
      res.status(501).json({ error: "Failed to update user time" });
  }
});


// Add this route to your existing code

// Update user's live location
router.put("/updateLiveLocation", async (req, res) => {
  try {
    const { userId, liveLatitude, liveLongitude } = req.body;

    // Find the user by ID
    const user = await ProfileData.findById(userId);
    
    if (!user) {
      return res.status(404).json({ error: "User Not Found" });
    }

    // Update live location fields
    user.liveLatitude = liveLatitude;
    user.liveLongitude = liveLongitude;

    // Save the updated user data
    await user.save();

    // Respond with a success message
    res.status(200).json({ message: "Live location updated successfully" });
  } catch (error) {
    // Handle errors
    console.error("Error updating live location:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});


// clear user timing
router.put("/deleteUserTime",async (req,res)=>{
  try{
      let { userId } = req.body;
      const user = await ProfileData.findById(userId).lean();
      if (!user) {
        return res.status(404).json({ error: "User Not Found" });
      }
      if(!user.userServiceTripCallingData){
       res.status(404).json({ message: "Details Are Not Present ! Refresh Page" });
      }
      // Save the updated user timings
      const updateFields = { $unset: { 'userServiceTripCallingData.startTimeFrom': 1, 'userServiceTripCallingData.endTimeTo': 1 ,'userServiceTripCallingData.slotsChossen':1}};
      await ProfileData.findByIdAndUpdate(userId, updateFields);
      res.status(200).json({ message: "User timing updated successfully" });
  }catch(err){
      console.log('Error:',err);
      res.status(501).json({ error: "Failed to update user time" });
  }
});


module.exports = router;