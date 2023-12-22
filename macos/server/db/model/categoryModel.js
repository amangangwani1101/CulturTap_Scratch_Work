const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
    name: String,
    genres: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Genre',
        select: 'name' // Select only the 'name' field from the referenced Genre
    }],
});

const CategoryModel = mongoose.model('Category', categorySchema);

module.exports = CategoryModel;
