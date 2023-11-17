const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema({
    rating:{
        type:Number,
    },
    info:{
        type:String,
    }
});
const chatDetailsSchema = new mongoose.Schema({
    sendersId : {
        type:String,
    },
    receiversId : {
        type:String,
    },
    meetingTitle:{
        type:String,
    },
    scheduledDay:{
        type:String,
    },
    chosenStartTime:{
        type:String,
    },
    chosenEndTime:{
        type:String,
    },
    conversation:{
        type:[[String]],
    },
    sendersFeedback:{
        type:feedbackSchema,
    },
    receiversFeedback:{
        type:feedbackSchema,
    },
});

const chatHistory = new mongoose.model('chatHistory',chatDetailsSchema);
module.exports = chatHistory;