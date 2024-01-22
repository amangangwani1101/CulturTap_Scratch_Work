const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

router.get('/api/stories-by-location', async (req, res) => {
  try {
    // Retrieve user's specified location from the request
    const location = req.query.location;

    // Create a base query to filter stories based on the provided location
    const baseQuery = {};

    // Add a condition to the baseQuery to match stories with any part of the location using a case-insensitive regex
    if (location) {
      baseQuery['location'] = { $regex: location, $options: 'i' };
    }

    // Use the SingleStoryModel.find method to fetch stories based on the modified baseQuery
    const matchingStories = await SingleStoryModel.find(baseQuery)
      .populate({
        path: 'genre',
        model: 'Genre',
        select: 'name',
      });

    // Send the matching stories as a JSON response to the client
    res.json(matchingStories);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

module.exports = router;
