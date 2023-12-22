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
    const meetingStatus = meetDayPlan.meetingStatus;

    // Convert chosen time to 24-hour format
    const convertTo24Hour = (time) => {
      const [hour, minute, period] = time.split(/:| /);
      const isPM = period.toUpperCase() === "PM";
      const adjustedHour = isPM && hour !== "12" ? parseInt(hour, 10) + 12 : parseInt(hour, 10);
      return `${adjustedHour.toString().padStart(2, "0")}:${minute}`;
    };

    const chosenStart24 = convertTo24Hour(chosenStartTime);
    const chosenEnd24 = convertTo24Hour(chosenEndTime);

    // Function to add 10 minutes to a given time
    function add10Minutes(time) {
      const [hours, minutes] = time.split(':').map(Number);
      const totalMinutes = hours * 60 + minutes + 10;
      const newHours = Math.floor(totalMinutes / 60) % 24;
      const newMinutes = totalMinutes % 60;
      return `${String(newHours).padStart(2, '0')}:${String(newMinutes).padStart(2, '0')}`;
    }

    // Function to subtract 10 minutes from a given time
    function subtract10Minutes(time) {
      const [hours, minutes] = time.split(':').map(Number);
      const totalMinutes = hours * 60 + minutes - 10;
      const newHours = (totalMinutes < 0 ? 24 + Math.floor(totalMinutes / 60) : Math.floor(totalMinutes / 60)) % 24;
      const newMinutes = (totalMinutes + 1440) % 60; // Ensure positive minutes
      return `${String(newHours).padStart(2, '0')}:${String(newMinutes).padStart(2, '0')}`;
    }

    // Check for time overlap with existing meetings and 10-minute gaps
    for (let i = 0; i < meetStartTimes.length; i++) {
    if(meetingStatus[i]!='close' && meetingStatus[i]!='cancel'){
          const existingStartTime24 = subtract10Minutes(convertTo24Hour(meetStartTimes[i]));
          const existingEndTime24 = add10Minutes(convertTo24Hour(meetEndTimes[i]));
    //      console.log(subtract10Minutes(existingStartTime24),add10Minutes(existingEndTime24));
          // Check if chosen time overlaps with existing meetings
          if (
            (chosenStart24 <= existingEndTime24 && chosenStart24 >= existingStartTime24) ||
            (chosenEnd24 >= existingStartTime24 && chosenEnd24 <= existingEndTime24)
          ) {
            return res.status(200).json({ isOverlap: true, message: "Meeting time overlaps with existing meetings." });
          }
          }
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