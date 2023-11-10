const mongoose = require('mongoose');

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
    }
});

const chatHistory = new mongoose.model('chatHistory',chatDetailsSchema);
module.exports = chatHistory;