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
	helperDist:{
    	type:[String],
    },
	helperIds2:{
    	type:[String],
    },
	helperDist2:{
    	type:[String],
    },
    helperId:{
        type:String,
    },
    meetTitle:{
        type:String,
    },
    time:{
        type:Date,
    },
	endTime:{
    	type:Date,
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