const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getStoriesByGenres(req, res, userID, genres) {
  try {
    console.log(`User searching for stories created by userID ${userID} in genres ${genres}`);

    const userStories = await SingleStoryModel.find({ userID: userID, genre: { $in: genres } })
      .sort({ updatedAt: -1 }); // Sort by the last updated date in descending order

    res.json(userStories);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}

router.get('/stories/user/:userID/genres/:genres', async (req, res) => {
  const userID = req.params.userID;
  const genres = req.params.genres.split(','); // Assuming genres are comma-separated in the URL
  await getStoriesByGenres(req, res, userID, genres);
});

module.exports = router;
