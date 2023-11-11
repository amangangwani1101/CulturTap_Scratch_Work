const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

// Define a route to get nearby street foods
router.get('/api/nearby-street-foods', async (req, res) => {
  try {
  console.log('user khana lene aya hai');
    // Retrieve user's live location (latitude and longitude) from the request
    const userLatitude = parseFloat(req.query.latitude);
    const userLongitude = parseFloat(req.query.longitude);

    // Calculate the maximum distance in degrees for approximately 20 kilometers
    const maxDistanceDegrees = 20 / 111; // 20 kilometers / 111 kilometers per degree

    // Query MongoDB to find nearby street foods within the 20 km range
    const nearbyStreetFoods = await SingleStoryModel.find({
      latitude: { $gte: userLatitude - maxDistanceDegrees, $lte: userLatitude + maxDistanceDegrees },
      longitude: { $gte: userLongitude - maxDistanceDegrees / Math.cos(userLatitude), $lte: userLongitude + maxDistanceDegrees / Math.cos(userLatitude) },
    });

    // Group stories by location for aggregate rating calculation
    const groupedPlaces = {};

    nearbyStreetFoods.forEach((story) => {
      const distance = calculateDistance(userLatitude, userLongitude, story.latitude, story.longitude);
      const key = `${story.latitude}-${story.longitude}`;

      if (distance <= 0.1) { // 100 meters in degrees
        if (!groupedPlaces[key]) {
          groupedPlaces[key] = {
            ratings: [],
            location: key,
            latitude: story.latitude,
            longitude: story.longitude,
          };
        }
        groupedPlaces[key].ratings.push(story.starRating);
      }
    });

    // Calculate the average rating for each place
    const placesWithAvgRating = Object.values(groupedPlaces).map((place) => {
      const ratings = place.ratings;
      const avgRating = ratings.reduce((acc, rating) => acc + rating, 0) / ratings.length;
      return { location: place.location, avgRating };
    });

    // Sort the places by average star rating in descending order
    placesWithAvgRating.sort((a, b) => b.avgRating - a.avgRating);

    // Send the sorted nearby street food places with average ratings as a JSON response
    res.json(placesWithAvgRating);
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
