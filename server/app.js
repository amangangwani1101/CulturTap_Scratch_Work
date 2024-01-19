const express = require('express');
const app = express();
const mainRoute = require('./routes/mainRoute.js');
const homePageRoute = require('./routes/homePageRoute.js');
const nationalParks = require('./routes/nearByNationalParks.js');
const riverSide = require('./routes/nearByRiverside.js');
const aquaticEcosystem = require('./routes/nearByAquaticEcosystem.js');
const festival = require('./routes/FestivalNearYou.js');
const island = require('./routes/nearByIsland.js');



const streetFoods = require('./routes/streetFoods.js');
const port = 8080;
require('./db/conn.js');
const UserData = require('./db/model/UserData.js');
const cors = require('cors');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use('/main', mainRoute);
app.use('/food',streetFoods);
app.use('/parks',nationalParks);
app.use('/riverside', riverSide);
app.use('/ecosystem',aquaticEcosystem);
app.use('/festival',festival);
app.use('/island',island);
app.use('/festival',festival);



app.post('/SignUp', async (req, res) => {
  try {

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


