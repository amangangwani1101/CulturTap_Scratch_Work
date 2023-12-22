const mongoose = require('mongoose');

const labelSchema = new mongoose.Schema({
    name: String,
    categories: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
        select : 'name'  // Select only the 'name' field from the referenced Category
    }],
});

const LabelModel = mongoose.model('Label', labelSchema);

module.exports = LabelModel;
