const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');
const GenreModel = require('../db/model/genre'); // Import the GenreModel

// Define a route to get nearby festivals
router.get('/api/nearby-festivals-with-ratings', async (req, res) => {
  try {
    // Retrieve user's live location (latitude and longitude) from the request
    const userLatitude = parseFloat(req.query.latitude);
    const userLongitude = parseFloat(req.query.longitude);

    // Calculate the maximum distance in degrees for approximately 20 kilometers
    const maxDistanceDegrees = 20 / 111; // 20 kilometers / 111 kilometers per degree

    // Query MongoDB to find nearby festivals with the "festival" genre
    const festivalGenre = await GenreModel.findOne({ name: 'festival' });

    if (!festivalGenre) {
      res.status(404).json({ error: 'Festival genre not found' });
      return;
    }

    const nearbyFestivals = await SingleStoryModel.find({
      _id: { $in: festivalGenre.stories }, // Filter by the references in the "festival" genre
      latitude: { $gte: userLatitude - maxDistanceDegrees, $lte: userLatitude + maxDistanceDegrees },
      longitude: { $gte: userLongitude - maxDistanceDegrees, $lte: userLongitude + maxDistanceDegrees },
    });

    // Calculate the average star rating for each nearby festival
    const festivalsWithAvgRating = nearbyFestivals.map((festival) => {
      const starRatings = festival.starRating;
      const avgRating = starRatings.reduce((acc, rating) => acc + rating, 0) / starRatings.length;
      return { ...festival.toObject(), avgRating };
    });

    // Sort the nearby festivals by average star rating in descending order
    festivalsWithAvgRating.sort((a, b) => b.avgRating - a.avgRating);

    // Send the sorted nearby festivals as a JSON response
    res.json(festivalsWithAvgRating);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});


router.get('/api/nearby-festivals', async (req, res) => {
  try {
    // Retrieve user's live location (latitude and longitude) from the request
    const userLatitude = parseFloat(req.query.latitude);
    const userLongitude = parseFloat(req.query.longitude);

    // Calculate the maximum distance in degrees for approximately 20 kilometers
    const maxDistanceDegrees = 20 / 111; // 20 kilometers / 111 kilometers per degree

    // Query MongoDB to find nearby festivals with the "festival" genre
    const festivalGenre = await GenreModel.findOne({ name: 'festival' });

    if (!festivalGenre) {
      res.status(404).json({ error: 'Festival genre not found' });
      return;
    }

    const nearbyFestivals = await SingleStoryModel.find({
      _id: { $in: festivalGenre.stories }, // Filter by the references in the "festival" genre
      latitude: { $gte: userLatitude - maxDistanceDegrees, $lte: userLatitude + maxDistanceDegrees },
      longitude: { $gte: userLongitude - maxDistanceDegrees, $lte: userLongitude + maxDistanceDegrees },
    });

    // Send the nearby festivals as a JSON response
    res.json(nearbyFestivals);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

module.exports = router;
