const express = require('express');
const router = express.Router();

// required database
const MeetData = require("../../db/model/localAssistantChatDetails.js");


router.patch('/storeLocalMeetingConversation', async (req, res) => {
  try {
    const { meetId, conversation } = req.body;

    const meet = await MeetData.findById(meetId);

    if (!meet) {
      return res.status(404).json({ message: "Meeting Not Found" });
    }

    if (!meet.conversation) {
      meet.conversation = [];
    }

    // Assuming 'conversation' is an array, use $push to add new elements to the existing array
    meet.conversation.push(conversation);
    await meet.save();
    res.status(200).json({ message: "Conversation stored successfully" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Endpoint to fetch conversation by meetId
router.get('/fetchLocalMeetingConversation/:meetId', async (req, res) => {
  try {
    const meetId = req.params.meetId;

    const meet = await MeetData.findById(meetId);

    if (!meet) {
      return res.status(404).json({ message: "Meeting Not Found" });
    }

    // Assuming the conversation array exists within the 'meet' document
    const conversation = meet.conversation || [];

    res.status(200).json(meet);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

router.patch('/updateLocalMeetingHelperIds/:meetId', async (req, res) => {
  try {
    const meetId = req.params.meetId;
    const {paymentStatus,time} = req.body;
    const meet = await MeetData.findById(meetId);
    if (!meet) {
      return res.status(404).json({ message: "Meeting Not Found" });
    }
    console.log('Updating meeting payment status');
    meet.paymentStatus = paymentStatus;
    meet.time = time;
    await meet.save();
    res.status(200).json({ message: "Payment Status updated successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});


module.exports = router;