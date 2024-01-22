// routes/userRequestRoutes.js
const express = require('express');
const router = express.Router();
const UserRequest = require('../db/model/UserRequest.js');


router.post('/saveUserRequest', async (req, res) => {
  try {
    const { userID, userName, userPhoneNumber, body } = req.body;

    // Save the user request data to MongoDB
    const newUserRequest = new UserRequest({
      userID,
      userName,
      userPhoneNumber,
      body,
    });
    await newUserRequest.save();

    res.status(200).json({ message: 'User request saved successfully' });
  } catch (error) {
    console.error('Error saving user request:', error);
    res.status(500).json({ error: 'Error saving user request' });
  }
});

module.exports = router;
