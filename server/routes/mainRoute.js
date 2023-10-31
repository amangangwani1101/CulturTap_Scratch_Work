const express = require('express');
const router = express.Router();
const CategoryModel = require('../db/model/categoryModel');
const GenreModel = require('../db/model/genreModel');
const LabelModel = require('../db/model/labelModel');
const SingleStoryModel = require('../db/model/singleStoryModel');

router.post('/api/publish', async (req, res) => {
  try {
    const { singleStoryData, label, category, genre } = req.body;

    // Create a new single story with the received data
    const newStory = new SingleStoryModel(singleStoryData);

    // Find or create the label
    let labelDoc = await LabelModel.findOne({ name: label });
    if (!labelDoc) {
      labelDoc = new LabelModel({ name: label });
    }else{

    }

    // Find or create the category within the label
    let categoryDoc = await CategoryModel.findOne({name : category});

    if (!categoryDoc) {
      categoryDoc = new CategoryModel({ name:  category });
      labelDoc.categories.push(categoryDoc);
    }else{
        labelDoc.categories.push(categoryDoc);
    }

    // Find or create the genre within the category
    let genreDoc = await GenreModel.findOne({name : genre});
    if (!genreDoc) {
      genreDoc = new GenreModel({ name: genre });
      categoryDoc.genres.push(genreDoc);
    }else{
        categoryDoc.genres.push(genreDoc);
    }


    // Save the single story and associate it with the genre
    genreDoc.stories.push(newStory);


    await genreDoc.save();
    await categoryDoc.save();
    await labelDoc.save();
    await newStory.save();

    res.status(201).send('Story published successfully');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});



 router.get('/api/videos', async (req, res) => {
   try {
     // Use the `find` method to search for stories with a starRating of 5
     const videos = await SingleStoryModel.find().sort({starRating: 1});

     // Send the results as a JSON response
     res.json(videos);
   } catch (err) {
     console.error(err);
     res.status(500).send('Server error');
   }
 });

module.exports = router;



