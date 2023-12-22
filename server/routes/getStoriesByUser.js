const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');


async function getStoriesByUser(req, res, userID) {
  try {
    console.log(`User searching for stories created by userID ${userID}`);

    const userStories = await SingleStoryModel.find({ userID: userID })
      .sort({ createdAt: -1 });


    res.json(userStories);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}


router.get('/stories/user/:userID', async (req, res) => {
  const userID = req.params.userID; 
  await getStoriesByUser(req, res, userID);
});


module.exports = router;
