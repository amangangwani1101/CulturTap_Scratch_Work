const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema({
    userPhoto:{
        type : String,
    },
    userName : {
        type : String,
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
});

const profileData = new mongoose.model('profileData',userProfileSchema);

module.exports = profileData;