const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

// Define a route to get trending nearby places
router.get('/api/trending-nearby-places', async (req, res) => {
  try {
    // Retrieve user's live location (latitude and longitude) from the request
    const userLatitude = parseFloat(req.query.latitude);
    const userLongitude = parseFloat(req.query.longitude);

    // Define the proximity range (100 meters)
    const proximityRangeMeters = 100;

    // Query MongoDB to find nearby stories within the proximity range
    const nearbyStories = await SingleStoryModel.find({
      latitude: { $gte: userLatitude - proximityRangeMeters / 111300, $lte: userLatitude + proximityRangeMeters / 111300 },
      longitude: { $gte: userLongitude - proximityRangeMeters / (111300 * Math.cos(userLatitude)), $lte: userLongitude + proximityRangeMeters / (111300 * Math.cos(userLatitude)) },
    });

    // Calculate the aggregate star rating and distance for each place
    let placesWithAvgRating = [];

    if (nearbyStories.length > 1) {
      // Group stories by location for aggregate rating calculation
      const groupedPlaces = {};

      nearbyStories.forEach((story) => {
        const key = `${story.latitude}-${story.longitude}`;
        if (!groupedPlaces[key]) {
          groupedPlaces[key] = {
            ratings: [],
            location: key,
            latitude: story.latitude,
            longitude: story.longitude,
          };
        }
        groupedPlaces[key].ratings.push(story.starRating);
      });

      // Calculate the average rating for each place and add distance
      placesWithAvgRating = Object.values(groupedPlaces).map((place) => {
        const ratings = place.ratings;
        const avgRating = ratings.reduce((acc, rating) => acc + rating, 0) / ratings.length;

        // Calculate the distance to the place
        const distance = calculateDistance(userLatitude, userLongitude, place.latitude, place.longitude);

        return { location: place.location, avgRating, distance };
      });

      // Sort the places by average star rating in descending order and then by distance
      placesWithAvgRating.sort((a, b) => {
        if (a.avgRating !== b.avgRating) {
          return b.avgRating - a.avgRating;
        }
        return a.distance - b.distance;
      });
    }

    // Send the sorted nearby places with average ratings and distance as a JSON response
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
