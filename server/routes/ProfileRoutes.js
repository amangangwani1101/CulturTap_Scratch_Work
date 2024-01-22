const express = require('express');
const router = express.Router();

// required db
const ProfileData = require("../db/model/profileData.js");
const MeetData = require("../db/model/localAssistantChatDetails.js");

// update profile of user first time after signup
router.put("/profileSection", async (req, res) => {
    try {
      const dataset = req.body;
      const userId = dataset['userId'];
      // Get the user data from the request body
      const user = await ProfileData.findById(userId);
      // Create a new user document and save it to the database
      if (!user) {
        return res.status(404).json({ error: "User Not Found" });
      }

        console.log(user);
      // Update existing fields with new values
      Object.keys(dataset).forEach((key) => {
      if(key=='userServiceTripCallingData' && user['userServiceTripCallingData']){
            console.log(1);
            if(dataset[key]!==null){
                user[key]['startTimeFrom'] = dataset[key].startTimeFrom;
                user[key]['endTimeTo'] = dataset[key].endTimeTo;
                user[key]['slotsChossen'] = dataset[key].slotsChossen;
            }
            else{
             }
        }
        else{
          user[key] = dataset[key];
        }
      });

      const savedData = await user.save();

      // Send a JSON response indicating success
      res.status(200).json({message: "User data saved successfully" });
    } catch (error) {
      // Send a JSON response indicating an error
      console.log(error);
      res.status(501).json({ error: "Failed to save user data" });
    }
});

async function getSortedUserData(profileId) {
  try {
    // Find the user data by profileId and populate the userServiceTripAssistantData array
    const userData = await ProfileData.findById(profileId)
      .populate({
        path: 'userServiceTripAssistantData',
        model: 'localassistantdetails', // Replace with your MeetData collection name
      })
      .lean();
      console.log(userData);  
    // Sort the userServiceTripAssistantData array in descending order based on time
    userData.userServiceTripAssistantData.sort((a, b) => new Date(b.time) - new Date(a.time));

    // Save the changes to the database
    await ProfileData.findByIdAndUpdate(profileId, { userServiceTripAssistantData: userData.userServiceTripAssistantData });

    return;
  } catch (error) {
    console.error('Error fetching, sorting, and saving user data:', error);
    throw error;
  }
}
// fetch user details
router.get("/userStoredData/:id", async (req, res) => {
    const id = req.params.id;
	const query = req.query;
    try {
      const data = await ProfileData.findOne({ _id: id });
//      console.log(data);
      if (data) {
      	if(query && query.section==='pings')
      		await getSortedUserData(id);
        res.status(200).json(data);
      } else {
        res.status(404).json({ message: "Data not found" });
      }
    } catch (error) {
      console.error("Error fetching data:", error);
      res.status(500).json({ message: "Internal server error" });
    }
});

// update user service timing : TripCallingService
router.put("/updateUserTime",async (req,res)=>{
  try{
      let { userId, startTime, endTime, slot } = req.body;
      const user = await ProfileData.findById(userId).lean();
      if (!user) {
        return res.status(404).json({ error: "User Not Found" });
      }
      if(!user.userServiceTripCallingData){
          user.userServiceTripCallingData = {};
      }
      user.userServiceTripCallingData.startTimeFrom = startTime;
      user.userServiceTripCallingData.endTimeTo = endTime;
      user.userServiceTripCallingData.slotsChossen = slot;

      // Save the updated user timings
      await ProfileData.findByIdAndUpdate(userId, user);
      res.status(200).json({ message: "User timing updated successfully" });
  }catch(err){
      console.log('Error:',err);
      res.status(501).json({ error: "Failed to update user time" });
  }
});

// Add this route to your existing code

// Update user's live location
router.put("/updateLiveLocation", async (req, res) => {
  try {
    const { userId, liveLatitude, liveLongitude } = req.body;

    // Find the user by ID
    const user = await ProfileData.findById(userId);
    
    if (!user) {
      return res.status(404).json({ error: "User Not Found" });
    }

    // Update live location fields
    user.liveLatitude = liveLatitude;
    user.liveLongitude = liveLongitude;

    // Save the updated user data
    await user.save();

    // Respond with a success message
    res.status(200).json({ message: "Live location updated successfully" });
  } catch (error) {
    // Handle errors
    console.error("Error updating live location:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

//getuser at the time of signup
router.get('/user/:userNumber', async (req, res) => {
  try {
    const userNumber = req.params.userNumber;
    
    // Query the database to find the user by phoneNumber
    const user = await ProfileData.findOne({ phoneNumber: userNumber });

    if (user) {
      // User found, send user information in the response
      res.json({
        userName: user.userName,
        userPhotoUrl: user.userPhoto,
        // Include other relevant fields as needed
      });
    } else {
      // User not found
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});


// Function to calculate distance between two sets of coordinates using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c; // Distance in kilometers
  return distance;
}

router.get("/findUserIdsAndDistancesWithin10Km", async (req, res) => {
  try {
    const { providedLatitude, providedLongitude, vardis } = req.query;

    // Find TripAssistant users within 10 km based on saved location
    const tripAssistantUsers = await ProfileData.find({
      userServiceTripAssistantStatus: true,
      latitude: { $exists: true },
      longitude: { $exists: true },
      $or: [
        { userServiceTripAssistantData: { $size: 0 } }, // Checks if the array is empty
        {
          userServiceTripAssistantData: {
            $not: {
              $elemMatch: {
                meetStatus: { $nin: ["cancel", "close", "closed", "choose"] },
              },
            },
          },
        },
      ],
    }).lean();

    const usersWithin10Km = tripAssistantUsers.map(user => {
      const distance = calculateDistance(
        parseFloat(providedLatitude),
        parseFloat(providedLongitude),
        parseFloat(user.latitude),
        parseFloat(user.longitude)
      );
      return {
        userId: user._id,
        uniqueToken: user.uniqueToken,
        distance: distance,
      };
    }).filter(user => user.distance <= vardis); // 10 km

    // Find users with live locations within 10 km
    const usersWithLiveLocations = await ProfileData.find({
      userServiceTripAssistantStatus: true,
      liveLatitude: { $exists: true },
      liveLongitude: { $exists: true },
      $or: [
        { userServiceTripAssistantData: { $size: 0 } }, // Checks if the array is empty
        {
          userServiceTripAssistantData: {
            $not: {
              $elemMatch: {
                meetStatus: { $nin: ["cancel", "close", "closed", "choose"] },
              },
            },
          },
        },
      ],
    }).lean();

    const usersWithLiveLocationsWithin10Km = usersWithLiveLocations.map(user => {
      const distance = calculateDistance(
        parseFloat(providedLatitude),
        parseFloat(providedLongitude),
        parseFloat(user.liveLatitude),
        parseFloat(user.liveLongitude)
      );
      return {
        userId: user._id,
        uniqueToken: user.uniqueToken,
        distance: distance,
      };
    }).filter(user => user.distance <= vardis); // 10 km

    // Combine results
    const allUserIdsAndDistances = [
      ...usersWithin10Km.map(user => ({ userId: user.userId, uniqueToken: user.uniqueToken, distance: user.distance })),
      ...usersWithLiveLocationsWithin10Km.map(user => ({ userId: user.userId, uniqueToken: user.uniqueToken, distance: user.distance })),
    ];

    res.status(200).json({
      allUserIdsAndDistances,
    });

  } catch (error) {
    console.error("Error finding users:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});



// clear user timing
router.put("/deleteUserTime",async (req,res)=>{
  try{
      let { userId } = req.body;
      const user = await ProfileData.findById(userId).lean();
      if (!user) {
        return res.status(404).json({ error: "User Not Found" });
      }
      if(!user.userServiceTripCallingData){
       res.status(404).json({ message: "Details Are Not Present ! Refresh Page" });
      }
      // Save the updated user timings
      const updateFields = { $unset: { 'userServiceTripCallingData.startTimeFrom': 1, 'userServiceTripCallingData.endTimeTo': 1 ,'userServiceTripCallingData.slotsChossen':1}};
      await ProfileData.findByIdAndUpdate(userId, updateFields);
      res.status(200).json({ message: "User timing updated successfully" });
  }catch(err){
      console.log('Error:',err);
      res.status(501).json({ error: "Failed to update user time" });
  }
});

const professionList = [
    'Doctor',
    'Engineer',
    'Teacher',
    'Software Developer',
    'Graphic Designer',
    'Accountant',
    'Chef',
    'Architect',
    'Lawyer',
    'Police Officer',
    'Firefighter',
    'Pilot',
    'Dentist',
    'Electrician',
    'Plumber',
    'Journalist',
    'Actor',
    'Musician',
    'Athlete',
    'Scientist',
    'Psychologist',
    'Social Worker',
    'Librarian',
    'Fashion Designer',
    'Marketing Manager',
    'Biologist',
    'Economist',
    'Mechanic',
    'Photographer',
    'Nurse',
    'Pharmacist',
    'Veterinarian',
    'Artist',
    'Carpenter',
    'Dancer',
    'Entrepreneur',
    'Hair Stylist',
    'Interior Designer',
    'Investment Banker',
    'Meteorologist',
    'Paramedic',
    'Physicist',
    'Speech Therapist',
    'Translator',
    'Zoologist',
    'Others'
  ];
const  cityList = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Kolkata',
    'Chennai',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Pimpri-Chinchwad',
    'Patna',
    'Vadodara',
    'Ghaziabad',
    'Ludhiana',
    'Agra',
    'Nashik',
    'Faridabad',
    'Meerut',
    'Rajkot',
    'Varanasi',
    'Srinagar',
    'Aurangabad',
    'Dhanbad',
    'Others'
  ];

// suggestion dropdown box
router.patch('/suggestions', (req, res) => {
  try {
    const query = req.query.query.toLowerCase();
  	const {list} =  req.body;
  	console.log(query,list); 
  if(list == 'profession'){
    const filteredSuggestions = professionList.filter(suggestion =>
      suggestion.toLowerCase().includes(query)
    );
    console.log(filteredSuggestions);
    
    res.json({ suggestions: filteredSuggestions });
  }
  else{
    const filteredSuggestions = cityList.filter(suggestion =>
      suggestion.toLowerCase().includes(query)
    );
    console.log(filteredSuggestions);
    
    res.json({ suggestions: filteredSuggestions });
  } 
  } catch (error) {
    console.error('Error processing suggestions:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
