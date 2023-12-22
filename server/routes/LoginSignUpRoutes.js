const express = require('express');
const router = express.Router();
const UserData = require('../db/model/profileData.js');



// save new user in database during signup
const SignUp = router.post('/', async (req, res) => {
  try {
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const {userName,phoneNumber,latitude,longitude,uniqueToken,profileStatus,pings} = req.body;
    console.log(req.body);
    const newUser = new UserData({userName,phoneNumber,latitude,longitude,uniqueToken,profileStatus,pings});
    const savedData = await newUser.save();
    console.log(savedData);
    // Send a JSON response indicating success
    res.status(200).json({ message: 'User data saved successfully',id: savedData['_id']});
  } catch (error) {

    // Send a JSON response indicating an err   or
    console.log(error);
    res.status(501).json({ error: 'Failed to save user data' });
  }
});

module.exports = {SignUp};

