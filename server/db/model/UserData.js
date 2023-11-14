const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
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
    }
});

const UserData = new mongoose.model('UserData',userSchema);

module.exports = UserData;