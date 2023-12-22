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
    views: { type: Number, default: 0 },
    likes: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now },
});

singleStorySchema.pre('save', function (next) {
    // 'this' refers to the document being saved
    const keys = Object.keys(this._doc);

    keys.forEach((key) => {
        const value = this[key];
        if (typeof value === 'string') {
            this[key] = value.toLowerCase();
        } else if (Array.isArray(value) && value.length > 0 && typeof value[0] === 'string') {
            // If the field is an array of strings, lowercase each element
            this[key] = value.map((item) => item.toLowerCase());
        }
    });

    // Continue with the save operation
    next();
});

const SingleStoryModel = mongoose.model('SingleStory', singleStorySchema);

module.exports = SingleStoryModel;

