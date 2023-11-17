const mongoose = require('mongoose');

// single story required fields schema
const singleStorySchema = new mongoose.Schema({
    videoPath : {
        type : [String],
    },
    latitude : {
        type : Number,
    },
    longitude : {
        type : Number,
    },
    location : {
        type : String,
    },
    expDescription : {
        type : String,
    },
    placeLoveDesc : {
        type : [String],
    },
    dontLikeDesc : {
        type : String,
    },
    review : {
        type : String,
    },
    starRating : {
        type :Number,
    },
    selectedVisibility : {
        type: String,
    },
    storyTitle : {
        type : String,
    },
    productDescription : {
        type : String,
    }
});


// ------------------

// genre : array of story schema
const genreStoriesSchema = new mongoose.Schema({
  key: String,
  value: [singleStorySchema], // You can specify the type of the "value" field based on your requirements
});

const genreSchema = new mongoose.Schema({
    genre : {
        type : [genreStoriesSchema],
    }
});

// --------------------

// category : array of genre
const categoryGenreStoriesSchema = new mongoose.Schema({
  key: String,
  value: genreSchema, // You can specify the type of the "value" field based on your requirements
});

const categorySchema = new mongoose.Schema({
    category : {
        type : [categoryGenreStoriesSchema],
    }
});

// ---------------

// label : array of category schema
const regularCategoryGenreStoriesSchema = new mongoose.Schema({
  key: String,
  value: categorySchema, // You can specify the type of the "value" field based on your requirements
});

const labelSchema = new mongoose.Schema({
    label : {
        type : [regularCategoryGenreStoriesSchema],
    }
});
// --------------

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

// ------------------

// rating schema
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
    phoneNumber : {
        type : Number,
    },
    latitude:{
        type: String,
    },
    longitude:{
        type: String,
    },
    profileStatus:{
        type:String,
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
    userReviewsData : {
        type : [userReviewsSchema],
    },
    userVideos : {
        type : [labelSchema],
    },
});


const profileData = new mongoose.model('profileData',userProfileSchema);

module.exports = profileData;