const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema({
    rating:{
        type:Number,
    },
    info:{
        type:String,
    },
    companyInfo:{
        type:String,
    },
});
const chatDetailsSchema = new mongoose.Schema({
    userId : {
        type:String,
    },
    helperIds : {
        type:[String],
    },
    helperId:{
        type:String,
    },
    meetTitle:{
        type:String,
    },
    time:{
        type:String,
    },
    date:{
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
    paymentStatus:{
        type:String,
    },
});

const chatHistory = new mongoose.model('LocalAssistantDetails',chatDetailsSchema);

module.exports = chatHistory;