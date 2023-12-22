const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getStoriesByGenre(req, res, userID, genre) {
  try {
    console.log(`User searching for stories created by userID ${userID} in genre ${genre}`);

    const userStories = await SingleStoryModel.find({ userID: userID, genre: genre })
      .sort({ updatedAt: -1 }); // Sort by the last updated date in descending order

    res.json(userStories);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}

router.get('/stories/user/:userID/genre/:genre', async (req, res) => {
  const userID = req.params.userID;
  const genre = req.params.genre;
  await getStoriesByGenre(req, res, userID, genre);
});

module.exports = router;
