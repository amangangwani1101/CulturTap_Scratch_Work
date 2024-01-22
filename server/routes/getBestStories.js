const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getBestStories(req, res, location) {
  try {
    console.log(`User searching for best stories in location: ${location}`);

    const bestStories = await SingleStoryModel.find({ location: { $regex: location, $options: 'i' } })
      .sort({ likes: -1, views: -1, starRating: -1, updatedAt: -1 }); // Sort by likes, views, starRating, and updatedAt in descending order

    res.json(bestStories);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}

router.get('/stories/best/location/:location', async (req, res) => {
  const location = req.params.location;
  await getBestStories(req, res, location);
});

module.exports = router;
