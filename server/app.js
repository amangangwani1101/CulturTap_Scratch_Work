const express = require('express');
const app = express();
const port = 8080;
require('./db/conn.js');
const UserData = require('./db/model/UserData.js');
const cors = require('cors');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.get('/',(req,res)=>{
       res.send('this is my flutter page');
})

// Define the /api/publish route
app.post('/api/publish', async (req, res) => {
  try {
    const { singleStoryData, label, category, genre } = req.body;

    // Create a new single story with the received data
    const newStory = new SingleStoryModel(singleStoryData);

    // Find or create the label
    let labelDoc = await LabelModel.findOne({ name: label });
    if (!labelDoc) {
      labelDoc = new LabelModel({ name: label });
      labelDoc = await labelDoc.save();
    }

    // Find or create the category within the label
    let categoryDoc = labelDoc.categories.find((cat) => cat.name === category);
    if (!categoryDoc) {
      categoryDoc = new CategoryModel({ name: category });
      labelDoc.categories.push(categoryDoc);
      labelDoc = await labelDoc.save();
    }

    // Find or create the genre within the category
    let genreDoc = categoryDoc.genres.find((gen) => gen.name === genre);
    if (!genreDoc) {
      genreDoc = new GenreModel({ name: genre });
      categoryDoc.genres.push(genreDoc);
      labelDoc = await labelDoc.save();
    }

    // Save the single story and associate it with the genre
    genreDoc.stories.push(newStory);
    await labelDoc.save();
    await newStory.save();

    res.status(201).send('Story published successfully');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});


app.post('/SignUp', async (req, res) => {
  try {
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const newUser = await UserData({userName : req.body.userName,phoneNumber : req.body.phoneNumber});
    const savedData = await newUser.save();

    // Send a JSON response indicating success
    res.status(200).json({ message: 'User data saved successfully' });
  } catch (error) {

    // Send a JSON response indicating an error
    console.log(error);
    res.status(501).json({ error: 'Failed to save user data' });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running at port ${port}`);
});
