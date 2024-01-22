const express = require('express');
const router = express.Router();

// required database
const ProfileData = require("../../db/model/profileData.js");
const MeetData = require("../../db/model/localAssistantChatDetails.js");



router.get("/checkLocalUserEligible/:id", async (req, res) => {
  try {
    const userId = req.params.id;

    const user = await ProfileData.findById(userId).lean();
    if(!user){
        return res.status(404).json({ message: "User Not Found" });
    }


    let listOfCheckerPage = user.userServiceTripAssistantData;
    
  	// helper trying to take local assist sevice action irrespective of a request of meet present in its pings
  	for(let i=0;i<listOfCheckerPage.length;i++){
    	if(listOfCheckerPage[i].userId!==userId && listOfCheckerPage[i].meetStatus==='choose'){
        	 await ProfileData.findByIdAndUpdate(user, { $pull: {userServiceTripAssistantData : {meetId:listOfCheckerPage[i].meetId} } });
        }
    }
  	res.status(200).json({message:'yours ongoingss meets pings are deleted successfully'});
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});



router.get("/checkLocalUserPings/:id", async (req, res) => {
  try {
    const userId = req.params.id;

    const user = await ProfileData.findById(userId).lean();
    if(!user){
        return res.status(404).json({ message: "User Not Found" });
    }

  	let listOfCheckerPage = user.userServiceTripAssistantData;
  	if(listOfCheckerPage===undefined){
    	res.status(200).json({message:'clear'});
    	return;
    }
  
    console.log('List',listOfCheckerPage);
  	let conclusion = false;
    
  	for(let i=0;i<listOfCheckerPage.length;i++){
    	if(listOfCheckerPage[i].userId!==userId && listOfCheckerPage[i].meetStatus==='choose'){
        	res.status(200).json({ eligible:false});
       		return;
        }
    }
  
  	let isUserHavePendingCalls = false,pendingMeetId;
  
    
  
    for(let i=0;i<listOfCheckerPage.length;i++){
        // user trying to again take local assist service check ist there any pending meet
        if(listOfCheckerPage[i].userId===userId && listOfCheckerPage[i].meetStatus==='pending'){
            isUserHavePendingCalls = true;
        	pendingMeetId = listOfCheckerPage[i].meetId;
        	break;
        }
        // helper trying to again take local assist service check ist there any ongoing meet other than choose
        else if(listOfCheckerPage[i].userId!==userId && listOfCheckerPage[i].meetStatus!=='cancel' && listOfCheckerPage[i].meetStatus!=='close'){
            res.status(200).json({ state: "helper",meetId:listOfCheckerPage[i].meetId});
            return;
        }
    }
  
    // user trying to again take local assist service check ist there any ongoing meet other than pending
  	for(let i=0;i<listOfCheckerPage.length;i++){
        if(listOfCheckerPage[i].userId===userId && listOfCheckerPage[i].meetStatus!=='pending' &&listOfCheckerPage[i].meetStatus!=='cancel' && listOfCheckerPage[i].meetStatus!=='close'){
            if(isUserHavePendingCalls){
        		res.status(200).json({ state: "user",meetId:pendingMeetId});
        	    return;
            }else{
            	res.status(200).json({ state: "user"});
        	    return;
            }
        }
    }
  	if(isUserHavePendingCalls){
   		res.status(200).json({ state: "ongoing",meetId:pendingMeetId});
    	return;
    }
    res.status(200).json({message:'clear'});
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;