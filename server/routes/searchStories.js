// const express = require('express');
// const router = express.Router();
// const SingleStoryModel = require('../db/model/singleStoryModel');

// async function searchStories(keyword, userLocation) {
//   try {
//     const keyword = req.params.keyword.toLowerCase();
//     print(keyword);

//     console.log(`User searching for stories with keyword: ${keyword} near ${userLocation.latitude}, ${userLocation.longitude}`);

//     const query = {
//       $or: [
//         { title: { $regex: keyword, $options: 'i' } },
//         { expDescription: { $regex: keyword, $options: 'i' } },
//         { placeLoveDesc: { $regex: keyword, $options: 'i' } },
//         { review: { $regex: keyword, $options: 'i' } },
//         { productDescription: { $regex: keyword, $options: 'i' } },
//         { category: { $regex: keyword, $options: 'i' } },
//         { genre: { $regex: keyword, $options: 'i' } },
//       ],
//     };

//     const matchingStories = await SingleStoryModel.find( { title: { $regex: keyword, $options: 'i' } },);
//     console.log('Matching Stories:', matchingStories);

//     // Calculate distance for each matching story
//     const storiesWithDistance = matchingStories.map((story) => {
//       const distance = calculateDistance(userLocation.latitude, userLocation.longitude, story.latitude, story.longitude);
//       return { ...story.toObject(), distance };
//     });

//     // Sort stories by distance
//     const sortedStories = storiesWithDistance.sort((a, b) => a.distance - b.distance);

//     return sortedStories;
//   } catch (err) {
//     console.error(err);
//     throw new Error('Server error');
//   }
// }

// router.get('/stories/:keyword', async (req, res) => {
//   const keyword = req.params.keyword;
//   const userLocation = {
//     latitude: parseFloat(req.query.latitude),
//     longitude: parseFloat(req.query.longitude),
//   };

//   if (!keyword || isNaN(userLocation.latitude) || isNaN(userLocation.longitude)) {
//     return res.status(400).json({ error: 'Keyword and valid location coordinates are required for search.' });
//   }

//   try {
//     const matchingStories = await searchStories(keyword, userLocation);
//     res.json(matchingStories);
//   } catch (error) {
//     console.error(error);
//     res.status(500).send('Server error');
//   }
// });

// // Function to calculate the distance between two sets of latitude and longitude
// function calculateDistance(lat1, lon1, lat2, lon2) {
//   const radlat1 = (Math.PI * lat1) / 180;
//   const radlat2 = (Math.PI * lat2) / 180;
//   const theta = lon1 - lon2;
//   const radtheta = (Math.PI * theta) / 180;
//   let dist = Math.sin(radlat1) * Math.sin(radlat2) +
//     Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
//   dist = Math.acos(dist);
//   dist = (dist * 180) / Math.PI;
//   dist = dist * 60 * 1.1515; // Distance in miles
//   dist = dist * 1.609344; // Distance in kilometers
//   return dist;
// }

// module.exports = router;


const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function searchStories(req, res, keyword) {

  console.log('printing keyword' + keyword);
  try {
      console.log(`User searching for stories with keyword: ${keyword} `);

    const bestStories = await SingleStoryModel.find({ storyTitle: { $regex: keyword, $options: 'i' } })
      .sort({ likes: -1, views: -1, starRating: -1, updatedAt: -1 }); 
  
    console.log('best stories : using storyTitle' + bestStories);
    res.json(bestStories);
  
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}

router.get('/stories/:keyword', async (req, res) => {
  const keyword = req.params.keyword;
  await searchStories(req, res, keyword);
});

module.exports = router;


