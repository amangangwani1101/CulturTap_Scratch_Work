// models/userRequest.js
const mongoose = require('mongoose');

const userRequestSchema = new mongoose.Schema({
  userID: {
    type: String,
    required: true,
  },
  userName: {
    type: String,
    required: true,
  },
  userPhoneNumber: {
    type: String,
    required: true,
  },
  body: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

const UserRequest = mongoose.model('UserRequest', userRequestSchema);

module.exports = UserRequest;
