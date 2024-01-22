const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getStoriesByBusinessCategory(req, res, businessCategory) {
  try {
    console.log(`User searching for best stories in businessCategory: ${businessCategory}`);

    const getStoriesByBusinessCategory = await SingleStoryModel.find({ businessCategory: { $regex: businessCategory, $options: 'i' } })
      .sort({ likes: -1, views: -1, starRating: -1, updatedAt: -1 }); // Sort by likes, views, starRating, and updatedAt in descending order

    res.json(getStoriesByBusinessCategory);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}

router.get('/stories/best/businessCategory/:businessCategory', async (req, res) => {
  const businessCategory = req.params.businessCategory;
  await getStoriesByBusinessCategory(req, res, businessCategory);
});

module.exports = router;
