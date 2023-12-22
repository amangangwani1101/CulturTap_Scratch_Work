const express = require('express');
const router = express.Router();
const GenreModel = require('../db/model/genreModel');
const SingleStoryModel = require('../db/model/singleStoryModel');

// Define a route to get nearby fashion places
router.get('/api/nearby-fashion-places', async (req, res) => {
  console.log('user fashion dekhne aya hai');
  try {
    // Retrieve user's live location (latitude and longitude) from the request
    const userLatitude = parseFloat(req.query.latitude);
    const userLongitude = parseFloat(req.query.longitude);

    // Calculate the maximum distance in degrees for approximately 20 kilometers
    const maxDistanceDegrees = 20 / 111; // 20 kilometers / 111 kilometers per degree

    // Query MongoDB to find nearby fashion places within the 20 km range
    const fashionGenre = await GenreModel.findOne({ name: 'Fashion' });

    if (!fashionGenre) {
      res.status(404).json({ error: 'Fashion genre not found' });
      return;
    }

    const nearbyFashionPlaces = await SingleStoryModel.find({
      _id: { $in: fashionGenre.stories }, // Filter by the references in the "Fashion" genre
      latitude: { $gte: userLatitude - maxDistanceDegrees, $lte: userLatitude + maxDistanceDegrees },
      longitude: { $gte: userLongitude - maxDistanceDegrees, $lte: userLongitude + maxDistanceDegrees },
    });

    // Group nearby fashion places by a 100m range
    const groupedPlaces = {};

    nearbyFashionPlaces.forEach((place) => {
      const key = `${Math.floor(place.latitude * 1000) / 1000}-${Math.floor(place.longitude * 1000) / 1000}`;
      if (!groupedPlaces[key]) {
        groupedPlaces[key] = {
          ratings: [],
          location: key,
          latitude: place.latitude,
          longitude: place.longitude,
          stories: [], // Add an array to store complete story data
        };
      }
      groupedPlaces[key].ratings.push(place.starRating);
      groupedPlaces[key].stories.push(place.toObject()); // Add complete story data
    });

    // Calculate the average rating for each place and add distance
    const placesWithAvgRating = Object.values(groupedPlaces).map((place) => {
      const ratings = place.ratings.flat(); // Flatten the ratings array
      const avgRating = ratings.length > 0 ? ratings.reduce((acc, rating) => acc + rating, 0) / ratings.length : 0;

      // Calculate the distance to the place
      const distance = calculateDistance(userLatitude, userLongitude, place.latitude, place.longitude);

      return place.stories.map((story) => ({
        _id: story._id,
        videoPath: story.videoPath,
        latitude: story.latitude,
        longitude: story.longitude,
        location: story.location,
        expDescription: story.expDescription,
        placeLoveDesc: story.placeLoveDesc,
        dontLikeDesc: story.dontLikeDesc,
        review: story.review,
        starRating: story.starRating,
        selectedVisibility: story.selectedVisibility,
        storyTitle: story.storyTitle,
        productDescription: story.productDescription,
        category: story.category,
        genre: story.genre,
        __v: story.__v,
      }));
    });

    // Send the sorted nearby fashion places with complete story data as a JSON response
    console.log(placesWithAvgRating.flat());
    res.json(placesWithAvgRating.flat());
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

// Function to calculate the distance between two sets of latitude and longitude
function calculateDistance(lat1, lon1, lat2, lon2) {
  // Implementation of Haversine formula to calculate distance
  const radlat1 = (Math.PI * lat1) / 180;
  const radlat2 = (Math.PI * lat2) / 180;
  const theta = lon1 - lon2;
  const radtheta = (Math.PI * theta) / 180;
  let dist =
    Math.sin(radlat1) * Math.sin(radlat2) +
    Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
  dist = Math.acos(dist);
  dist = (dist * 180) / Math.PI;
  dist = dist * 60 * 1.1515; // Distance in miles
  dist = dist * 1.609344; // Distance in kilometers
  return dist;
}

module.exports = router;
