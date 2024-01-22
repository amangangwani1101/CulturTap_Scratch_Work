const express = require('express');
const router = express.Router();
const { ObjectId } = require("mongodb");
// required database
const MeetData = require("../../db/model/localAssistantChatDetails.js");
const ProfileData = require("../../db/model/profileData.js");

const newId = new ObjectId();
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

//update feedback meeting
router.get("/closedMeetingFeedback/:userId", async (req, res) => {
    try{
        const userId = req.params.userId;
    	
        const meetId = req.query.meeting;
    
		const user = await ProfileData.findById(userId).lean();
    
    	const localAssist = user.userServiceTripAssistantData;
    	
    	for(let i=0;i<localAssist.length;i++){
        	if(localAssist[i]['meetId']===meetId){
              const dataset = localAssist[i];
              dataset['photo'] = user.userPhoto;
              dataset['index'] = i; 	
              res.status(200).json({dataset });
              return; 
           }
        }

        res.status(200).json({});
    
    }catch (error) {
     console.log(error);
     res.status(500).json({});
   }
});

//update feedback meeting
router.patch("/updateLocalAssistFeedback", async (req, res) => {
    try{
        const { meetId,rating,info,type,companyInfo} = req.body;

        const meet = await MeetData.findById(meetId);

        if(!meet){
            return res.status(404).json({ message: "Meeting Not Found" });
        }

        if(type=='user'){
            if(!meet.sendersFeedback){
                meet.sendersFeedback = {
                    rating:null,
                    info:null,
                    companyInfo:null,
                }
            }
            meet.sendersFeedback.rating = rating;
            meet.sendersFeedback.info = info;
            meet.sendersFeedback.companyInfo = companyInfo;
        }
        else{
            if(!meet.receiversFeedback){
                meet.receiversFeedback = {
                    rating:null,
                    info:null,
                }
            }
            meet.receiversFeedback.rating = rating;
            meet.receiversFeedback.info = info;
        }
        await meet.save();
        res.status(200).json({ message: "Meeting status updated successfully" });
    }catch (error) {
     console.log(error);
     return res.status(500).json({ message: "Internal Server Error" });
   }
});


module.exports = router;