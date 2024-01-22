const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getBestCategoryStory(location, category) {
  try {
    console.log(`User searching for best stories in location: ${location} and category: ${category}`);

    const query = {
      location: { $regex: location, $options: 'i' },
      category: { $regex: category, $options: 'i' }
    };

    const bestStories = await SingleStoryModel.find(query)
      .sort({ likes: -1, views: -1, starRating: -1, updatedAt: -1 });

    return bestStories;
  } catch (err) {
    console.error(err);
    throw new Error('Server error');
  }
}

router.get('/stories/best/category/:category/location/:location', async (req, res) => {
  const location = req.params.location;
  const category = req.params.category;

  if (!location || !category) {
    return res.status(400).json({ error: 'Location and category are required.' });
  }

  try {
    const bestStories = await getBestCategoryStory(location, category);
    res.json(bestStories);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
});

module.exports = router;
