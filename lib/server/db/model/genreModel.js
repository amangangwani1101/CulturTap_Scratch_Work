const mongoose = require('mongoose');

const genreSchema = new mongoose.Schema({
    name: String,
    stories: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'SingleStory' // Reference the model name for single stories
    }],
});

const GenreModel = mongoose.model('Genre', genreSchema);

module.exports = GenreModel;
