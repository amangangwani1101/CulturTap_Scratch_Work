const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getBestCategoryGenreStory(location, category, genre) {
  try {
    console.log(`User searching for best stories in location: ${location}, category: ${category}, and genre: ${genre}`);

    const query = {
      location: { $regex: location, $options: 'i' },
      category: { $regex: category, $options: 'i' },
      genre: { $regex: genre, $options: 'i' }
    };

    const bestStories = await SingleStoryModel.find(query)
      .sort({ likes: -1, views: -1, starRating: -1, updatedAt: -1 });

    return bestStories;
  } catch (err) {
    console.error(err);
    throw new Error('Server error');
  }
}

router.get('/stories/best/category/:category/genre/:genre/location/:location', async (req, res) => {
  const location = req.params.location;
  const category = req.params.category;
  const genre = req.params.genre;

  if (!location || !category || !genre) {
    return res.status(400).json({ error: 'Location, category, and genre are required.' });
  }

  try {
    const bestStories = await getBestCategoryGenreStory(location, category, genre);
    res.json(bestStories);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
});

module.exports = router;
