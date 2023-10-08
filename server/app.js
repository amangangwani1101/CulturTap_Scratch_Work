const express = require('express');
const app = express();
const port = 8080;
require('./db/conn.js');
const ProfileData = require('./db/model/profileData.js');
const cors = require('cors');
const { ObjectId } = require('mongodb'); // Import ObjectId for querying by ID
const { MongoClient } = require('mongodb');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.get('/',(req,res)=>{
       res.send('this is my flutter page');
})

app.get('/userStoredData/:id',async(req,res)=>{
    const id = req.params.id;

    try {
        const data = await ProfileData.findOne({ _id: id });
        if (data) {
          res.status(200).json(data);
        } else {
          res.status(404).json({ message: 'Data not found' });
        }
      } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).json({ message: 'Internal server error' });
      }
})

app.post('/profileSection', async (req, res) => {
  try {
    console.log('I am',req.body);
    // Get the user data from the request body

    // Create a new user document and save it to the database
    const newUser = await ProfileData(req.body);
    const savedData = await newUser.save();

    // Send a JSON response indicating success
    res.status(200).json({ _id: savedData['_id'],message: 'User data saved successfully' });
  } catch (error) {

    // Send a JSON response indicating an error
    console.log(error);
    res.status(501).json({ error: 'Failed to save user data' });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running at port ${port}`);
});