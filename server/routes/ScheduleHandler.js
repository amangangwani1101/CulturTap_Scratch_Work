const schedule = require('node-schedule');
// required database
const ProfileData = require("../db/model/profileData.js");
const MeetData = require("../db/model/localAssistantChatDetails.js");

// schedule notification :: sending notification to more user for help of needy
const localAssistantHandler1 = function scheduler1(){
 const job1 = schedule.scheduleJob('*/1 * * * * *', async () => {
 try {
   const currentDateTime = new Date();
   const fiveMinutesAfter = new Date(currentDateTime.getTime() - 5 * 60000); // 5 minutes after current time

   const meetings = await MeetData.find({
     paymentStatus: 'initiated',
     helperIds2: { $exists: true, $ne: [] },
     time: { $lte: fiveMinutesAfter },
   });
	 for (const meeting of meetings) {
   		console.log('Sending Pings');	   	
       const helperIds = meeting.helperIds2;
       if(helperIds2.length>0){
	
         // const users = await UserData.find({ userId: { $in: helperIds2 } });
         // Extract user tokens
         // const userTokens = users.map(user => user.userToken);
         // Send notification to each user
         // for (const token of userTokens) {
         //   await sendNotification(token, 'Meeting Reminder', 'Your meeting will start soon.');
         // }
         // generate pings 
       		const date = (new Date()).toLocaleDateString('en-GB', {day: '2-digit',month: '2-digit',year: 'numeric'}); 
            const dateObject = new Date(meeting.time);
			const hours = dateObject.getHours();
			const minutes = dateObject.getMinutes();
			const time = `${hours > 12 ? hours - 12 : hours}:${minutes < 10 ? '0' : ''}${minutes} ${hours >= 12 ? 'PM' : 'AM'}`;
         	const helperIds = meeting.helperIds2;
         	const meetId = (meeting._id).toString();
         	const meetStatus = 'choose';
         	const distances = meeting.helperDist2;
         	const userName = user.userName;
         	const title = meeting.meetTitle;
         	const userPhoto = user.userPhoto;
			const message = await createPings(date,time,helperIds,meetId,meetStatus,userName,userPhoto,title,distances); 
            console.log(message);  
         }
       // Update the meeting to mark reminder as sent set it when adjust schema with 15 km parameter
       
   	   meeting.helperIds.push(...meeting.helperIds2);
       meeting.helperDist.push(...meeting.helperDist2);
       meeting.helperDist2 = [];
       meeting.helperIds2 = [];
       await meeting.save();
   }
 } catch (error) {
   console.error('Error sending meeting reminders:', error);
 }
});
 // Handle errors in the scheduler
 job1.on('error', err => {
 console.error('Scheduler error:', err);
});
}
async function createPings(userId,date,time,helperIds,meetId,meetStatus,userName,userPhoto,title,distances){
	try {
   console.log('Sending Pings');
    for (let i = 0; i < helperIds.length; i++) {
        const helperId = helperIds[i];
        const user = await ProfileData.findById(helperId).lean();
        if(!user){
            return "User Not Found";
        }
        if(!user.userServiceTripAssistantData || user.userServiceTripAssistantData === null){
            user.userServiceTripAssistantData = [];
        }
        const setCard =  {userId:helperId,title:title,time:time,date:date,distance:distances[i],meetId:meetId,meetStatus:meetStatus,userName,userPhoto};
        user.userServiceTripAssistantData.push(setCard);
        await ProfileData.findByIdAndUpdate(helperId, user);
    }
    return "Request sent successfully";
  } catch (error) {
    console.log(error);
    return "Internal Server Error";
  }
}


// remove meet if not possible to arrange helpers
const localAssistantHandler2 = function scheduler2(){
 const job1 = schedule.scheduleJob('*/1 * * * * *', async () => {
 try {
   const currentDateTime = new Date();
   const tenMinutesAfter = new Date(currentDateTime.getTime() - 10 * 60000).toISOString(); // 10 minutes after current time
   console.log(currentDateTime,tenMinutesAfter);
   const meetings = await MeetData.find({
     paymentStatus: 'initiated',
 	 helperIds: { $exists: true, $ne: [] },
   	 time: { $lte:tenMinutesAfter },	
   });	
 	console.log('checking meet');
 	console.log(meetings);
   for (const meeting of meetings) {
	   console.log('Unable To arrange meet');	   	
       const helperIds = meeting.helperIds;
	   const meetId = (meeting._id).toString();
       if(helperIds.length>0){
	
         // const users = await UserData.find({ userId: { $in: helperIds2 } });
         // Extract user tokens
         // const userTokens = users.map(user => user.userToken);
         // Send notification to each user
         // for (const token of userTokens) {
         //   await sendNotification(token, 'Meeting Reminder', 'Your meeting will start soon.');
         // }
         // generate pings 
         	const message = await removePings(helperIds,meetId); 
       		const userUpdateResult = await closeMeetStatus(meeting.userId,meetId,'cancel');
			console.log('User Update Result:', userUpdateResult);  
            console.log(message);  
         }
       // Update the meeting to mark reminder as sent set it when adjust schema with 15 km parameter
       
   	   // meeting.helperDist = [];
   	   // meeting.helperIds = [];
   	   // await meeting.save();
   }
 } catch (error) {
   console.error('Error sending meeting reminders:', error);
 }
});
 // Handle errors in the scheduler
 job1.on('error', err => {
 console.error('Scheduler error:', err);
});
}
async function removePings (listUser, meetId){
	try {
   
    for(const users of listUser){
       	await ProfileData.findByIdAndUpdate(users, { $pull: {userServiceTripAssistantData : {meetId:meetId} } });
    }
    await MeetData.findByIdAndUpdate(meetId, { $set:{'paymentStatus':'cancel'} });
    
	return "Pings removed successfully";
  } catch (error) {
    console.log(error);
    return "Internal Server Error";
  }
}
  
// schedule notification  :: reminder before closing meet in local assistants
const localAssistantHandler3 = function scheduler3() {
   const job2 = schedule.scheduleJob('*/1 * * * * *', async () => {
 try {
   const currentDateTime = new Date();
   const eightyFiveMinutesAfter = new Date(currentDateTime.getTime() - 85 * 60000); // 85 minutes after current time

   const meetingsToNotify = await MeetData.find({
     paymentStatus: { $eq: 'pending' },
     time: { $lte: eightyFiveMinutesAfter }
   });
   for (const meeting of meetingsToNotify) {
     const userId = meeting.userId;
     console.log('Meeting Closing Reminder');
     let helperId;
   	 if(meeting.helperId!==undefined){
     	helperId = meeting.helperId;
     }
     // get from firebase
     // if(user['uniqueToken']!=null){}
     // await sendNotificationToUser(token, 'Meeting Update', 'Meeting has an update');
     // Compare current time with time field of the meeting
    
   }
 } catch (error) {
   console.error('Error in meeting updates:', error);
 }
});
   job2.on('error', err => {
 console.error('Scheduler closer error:', err);
});
}


// schedule notification  :: reminder before closing meet in local assistants
const localAssistantHandler4 = function scheduler4() {
   const job2 = schedule.scheduleJob('*/1 * * * * *', async () => {
 try {
   const currentDateTime = new Date();
   const ninetyMinutesAfterMeetingTime = new Date(currentDateTime.getTime() - 90 * 60000); // 90 minutes before current time

   const meetingsToNotify = await MeetData.find({
     paymentStatus: { $eq: 'pending' },
     time: { $lte: ninetyMinutesAfterMeetingTime }
   });
   for (const meeting of meetingsToNotify) {
     const userId = meeting.userId;
     let helperId;
   	 if(meeting.helperId!==undefined){
     	helperId = meeting.helperId;
     }
     const meetId =  (meeting._id).toString();
     console.log('Closing meet');
     await MeetData.findByIdAndUpdate(meetId , { paymentStatus: 'close',time:currentDateTime });
     try {
         const userUpdateResult = await closeMeetStatus(userId,meetId,'close');
		 console.log('User Update Result:', userUpdateResult);  
         if(helperId!==undefined){
        	const helperUpdateResult = await closeMeetStatus(helperId,meetId,'close');
			console.log('User Update Result:', helperUpdateResult);  
         }
  		} catch (error) {
       console.error('Error updating meetStatus:', error);
     }
   }
 } catch (error) {
   console.error('Error in meeting updates:', error);
 }
});
   job2.on('error', err => {
 console.error('Scheduler closer error:', err);
});
}



// paymentStatus -> meetStatus -> initiated,pending,closed
// for 1st case : paymentStatus : initiated , helperIds : length>0 -> send notification after 5min
// for 2nd case : paymentStatus : pending , time exceeds 90 min case then updated paymentStaus : close


// Function to send notifications from firebase

async function closeMeetStatus(userId, meetId,status) {
  try {
  	const user = await ProfileData.findById(userId).lean();
	console.log(userId);
    if (!user) {
      return "User not found" ;
    }
   
    let savedData = user.userServiceTripAssistantData;
    for(let i=0;i<savedData.length;i++){
        if(savedData[i]['meetId']==meetId){
            savedData[i]['meetStatus'] = status;
        	const currentTime = new Date();
        	const hours = currentTime.getHours() > 12 ? currentTime.getHours() - 12 : currentTime.getHours();
        	const minutes = currentTime.getMinutes();
        	const ampm = currentTime.getHours() >= 12 ? 'PM' : 'AM';
        	savedData[i]['endTime'] = `${hours}:${minutes < 10 ? '0' : ''}${minutes} ${ampm}`;
      }
    }
  	await ProfileData.findByIdAndUpdate(userId, user);
    console.log('Pings updated successfully');
    return 'Pings updated successfully' ;
  } catch (error) {
    console.error(error);
    return 'Internal Server Error';
  }
}

async function sendNotificationToUser(userToken, title, body) {
  const data = {
    to: userToken,
    priority: 'high',
    notification: {
      title: title,
      body: body,
    },
  };

  try {
    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      body: JSON.stringify(data),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAPpVuKrI:APA91bF7BA61C5dlBD65HIs4KY1Ljw5rHZ1FyNxuqjEpQUjfnQJMkhxf71XKlk2dK3fkjRVYG7gErT4lZj2lluhZVsdaHPeyjWKGQ6AcUZlNeXLTiuKxnnVgO21EowO0ATcxKSBd2EK7',
      },
    });

    if (response.ok) {
      console.log('Notification sent successfully');
    } else {
      console.error('Failed to send notification:', response.statusText);
    }
  } catch (error) {
    console.error('Failed to send notification:', error.message);
  }
}

module.exports = {localAssistantHandler1,localAssistantHandler2,localAssistantHandler3,localAssistantHandler4};