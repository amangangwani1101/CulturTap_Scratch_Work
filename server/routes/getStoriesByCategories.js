const express = require('express');
const router = express.Router();
const SingleStoryModel = require('../db/model/singleStoryModel');

async function getStoriesByCategory(req, res, userID, category) {
  try {
    console.log(`User searching for stories created by userID ${userID} in category ${category}`);

    const userStories = await SingleStoryModel.find({ userID: userID, category: category })
      .sort({ updatedAt: -1 }); // Sort by the last updated date in descending order

    res.json(userStories);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
}

router.get('/stories/user/:userID/category/:category', async (req, res) => {
  const userID = req.params.userID;
  const category = req.params.category;
  await getStoriesByCategory(req, res, userID, category);
});

module.exports = router;
