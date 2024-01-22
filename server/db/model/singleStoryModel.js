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
    liveLocation: String,
    productPrice: String,
    transportationPricing: String,
    selectedOption: String,
    label: String,
    category: String,
    businessCategory: String,
    genre: String,
    userID: String,
    userName: String,
    views: { type: Number, default: 0 },
    likes: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now },
});



const SingleStoryModel = mongoose.model('SingleStory', singleStorySchema);

module.exports = SingleStoryModel;

