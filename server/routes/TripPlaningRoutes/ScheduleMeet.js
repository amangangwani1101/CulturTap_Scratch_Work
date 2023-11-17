const express = require('express');
const router = express.Router();

//required db
const ProfileData = require("../../db/model/profileData.js");
const MeetingsData = require("../../db/model/chatDetailsData.js");

// overlapping meeting or not
router.post("/checkMeetingTime", async (req, res) => {
  try {
    let { userId, chosenDate, chosenStartTime, chosenEndTime } = req.body;
    const user2 = await ProfileData.findById(userId).lean();

    if (!user2) {
      return res.status(404).json({ error: "User Not Found" });
    }

    if (!user2.userServiceTripCallingData || !user2.userServiceTripCallingData.dayPlans) {
      return res.status(200).json({ isOverlap: false });
    }

    const meetDayPlan = user2.userServiceTripCallingData.dayPlans[chosenDate];

    if (!meetDayPlan || !meetDayPlan.meetStartTime || !meetDayPlan.meetEndTime) {
      return res.status(200).json({ isOverlap: false });
    }

    const meetStartTimes = meetDayPlan.meetStartTime;
    const meetEndTimes = meetDayPlan.meetEndTime;

    // Convert chosen time to 24-hour format
    const convertTo24Hour = (time) => {
      const [hour, minute, period] = time.split(/:| /);
      const isPM = period.toUpperCase() === "PM";
      const adjustedHour = isPM && hour !== "12" ? parseInt(hour, 10) + 12 : parseInt(hour, 10);
      return `${adjustedHour.toString().padStart(2, "0")}:${minute}`;
    };

    const chosenStart24 = convertTo24Hour(chosenStartTime);
    const chosenEnd24 = convertTo24Hour(chosenEndTime);

    // Check for time overlap
    for (let i = 0; i < meetStartTimes.length; i++) {
      const existingStartTime24 = convertTo24Hour(meetStartTimes[i]);
      const existingEndTime24 = convertTo24Hour(meetEndTimes[i]);

      if (
        (chosenStart24 <= existingEndTime24 && chosenStart24 >= existingStartTime24) ||
        (chosenEnd24 >= existingStartTime24 && chosenEnd24 <= existingEndTime24)
      ) {
        return res.status(200).json({ isOverlap: true });
      }
    }

    const userPrefferedStartTime = convertTo24Hour(user2.userServiceTripCallingData.startTimeFrom);
    const userPrefferedEndTime = convertTo24Hour(user2.userServiceTripCallingData.endTimeTo);

    if (!((chosenStart24 <= userPrefferedEndTime && chosenStart24 >= userPrefferedStartTime) ||
        (chosenEnd24 >= userPrefferedStartTime && chosenEnd24 <= userPrefferedEndTime))) {
        return res.status(200).json({ isOverlap: true });
      }
    // No overlap found, return false
    res.status(200).json({ isOverlap: false });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// schedule meeting
router.post("/scheduleMeeting", async (req, res) => {
  try {
    console.log("I am", req.body);
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const newUser = await MeetingsData(req.body);
    console.log(newUser);
    const savedData = await newUser.save();

    // Send a JSON response indicating success
    res.status(200).json({ _id: savedData["_id"], message: "User data saved successfully" });
  } catch (error) {
    // Send a JSON response indicating an error
    console.log(error);
    res.status(501).json({ error: "Failed to save user data" });
  }
});

module.exports = router;