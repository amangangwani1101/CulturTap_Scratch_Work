const mongoose = require('mongoose');


// trip calling service section complete schema
const dayPlansSchema = new mongoose.Schema({
  meetStartTime: [String],
  meetEndTime: [String],
  meetingId: [String],
  meetingStatus:[String],
  meetingTitle:[String],
  userId:[String],
  meetingType:[String],
  userName:[String],
  userPhoto:[String],
});

const userTripCallingSchema = new mongoose.Schema({
    startTimeFrom :{
        type : String,
    },
    endTimeTo :{
        type : String,
    },
    slotsChossen : {
        type : String,
    },
    dayPlans:{
        type: Map, of: dayPlansSchema
    },
});

const userTripAssistantSchema = new mongoose.Schema({
    userId : {
        type : String,
    },
    time : {
        type: String,
    },
    title : {
        type : String,
    },
    distance:{
        type:String,
    },
    meetId: String,
    meetStatus:String,
    userName:String,
    userPhoto:String,
});

// ------------------

// rating schema
const userPaymentSchema = new mongoose.Schema({
    name : {
        type : String,
    },
    cardNo : {
        type: String,
    },
    month : {
        type: String,
    },
    year : {
        type : String,
    },
    cvv : {
        type : String,
    },
});


const userReviewsSchema = new mongoose.Schema({
    ratersName : {
        type : String,
    },
    ratersStar : {
        type: Number,
    },
    ratersComment : {
        type : String,
    }
});
// -----------------------

// user profile - major schema description
const userProfileSchema = new mongoose.Schema({
    userPhoto:{
        type : String,
    },
    userName : {
        type : String,
    },
    userEmailId:{
        type:String,
    },
    phoneNumber : {
        type : Number,
    },
    latitude:{
        type: String,
    },
    longitude:{
        type: String,
    },
    liveLatitude:{
        type: String,
    },
    liveLongitude:{
        type: String,
    },
    profileStatus:{
        type:String,
    },
    userDOB:{
        type:Date,
    },
    pings:{
        type:Number,
    },
    uniqueToken:{
        type:String,
    },
    userQuote : {
        type : String,
    },
    userFollowers : {
        type : Number,
    },
    userFollowing : {
        type : Number,
    },
    userExploredLocations: {
        type : Number,
    },
    userPlace : {
        type : String,
    },
    userProfession : {
        type : String,
    },
    userAge : {
        type : String,
    },
    userGender : {
        type : String,
    },
    userLanguages : {
        type : Array,
    },
    userServiceTripCallingData : {
        type :userTripCallingSchema,
    },
    userServiceTripAssistantData:{
        type:[userTripAssistantSchema],
    },
    userReviewsData : {
        type : [userReviewsSchema],
    },
    userPaymentData : {
        type : [userPaymentSchema],
    },


    labels : [{
        type : mongoose.Schema.Types.ObjectId,
        ref : 'Label',  // Assuming 'Label' is the model name for labelSchema
    }],

    stories: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'SingleStory' // Reference the model name for single stories
    }],


});


const profileData = new mongoose.model('profileData',userProfileSchema);

module.exports = profileData;