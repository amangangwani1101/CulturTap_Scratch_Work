const mongoose = require('mongoose');

const singleStorySchema = new mongoose.Schema({
    videoPath: [String],
    latitude: Number,
    longitude: Number,
    location: String,
    expDescription: String,
    placeLoveDesc: [String],
    dontLikeDesc: String,
    review: String,
    starRating: Number,
    selectedVisibility: String,
    storyTitle: String,
    productDescription: String,
    category:String,
    genre: String,
});

const SingleStoryModel = mongoose.model('SingleStory', singleStorySchema);

module.exports = SingleStoryModel;

