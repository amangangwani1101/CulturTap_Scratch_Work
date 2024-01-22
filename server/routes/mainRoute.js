const express = require('express');
const router = express.Router();
const CategoryModel = require('../db/model/categoryModel');
const GenreModel = require('../db/model/genreModel');
const LabelModel = require('../db/model/labelModel');
const SingleStoryModel = require('../db/model/singleStoryModel');
const ProfileModel = require('../db/model/profileData');
const multer = require('multer');
const path = require('path');
const ffmpeg = require('fluent-ffmpeg');
const sharp = require('sharp');
const fs = require('fs');
//const ProfileModel = require('./ProfileRoutes');

const imageStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, '/root/profile_images');
  },
  filename: (req, file, cb) => {
    cb(null, file.originalname);
  },
});

const uploadImage = multer({ storage: imageStorage });

// Handle POST request for image upload
router.post('/api/uploadImage', uploadImage.single('image'), (req, res) => {
  res.send('Image uploaded successfully!');
});




const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, '/root/videos');
  },
  filename: (req, file, cb) => {
   
    const uniqueFilename = `${(file.originalname)}`;
    cb(null, uniqueFilename);
  },
});

const upload = multer({ storage: storage });

// Function to generate thumbnails
const generateThumbnail = async (videoPath, thumbnailPath, quality = 30) => {
  return new Promise((resolve, reject) => {
    ffmpeg(videoPath)
      .on('end', () => {
        resolve();
      })
      .on('error', (err) => {
        reject(err);
      })
      .screenshots({
        count: 1,
        folder: thumbnailPath,
        filename: 'thumbnail-%b.webp',
        quality : quality,
      });
  });
};

const compressVideo = async (videoPath, quality = 30) => {
  return new Promise((resolve, reject) => {
    const tempVideoPath = videoPath.replace('.mp4', '_temp.mp4'); // Temporary file

    ffmpeg(videoPath)
      .outputOptions([
        '-c:v libx264',
        '-c:a aac',
        '-strict experimental',
        `-b:a 192k`,
        '-preset veryfast',
        '-movflags +faststart'
      ])
      .save(tempVideoPath) // Save to a temporary file
      .on('end', async () => {
        // Remove the original file
        fs.unlink(videoPath, (unlinkErr) => {
          if (unlinkErr) {
            reject(unlinkErr);
          } else {
            // Rename the temporary file to the original file
            fs.rename(tempVideoPath, videoPath, (renameErr) => {
              if (renameErr) {
                reject(renameErr);
              } else {
                resolve();
              }
            });
          }
        });
      })
      .on('error', (err) => {
        reject(err);
      });
  });
};


// POST endpoint for handling video uploads
router.post('/api/uploadVideos', upload.array('videos', 10), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).send('No video files uploaded');
    }

    const videoPaths = req.files.map((file) => path.join('/root/videos', file.filename));

    // Compress videos
    for (let i = 0; i < videoPaths.length; i++) {
      const videoPath = videoPaths[i];
      const thumbnailPath = path.join('/root/thumbnails');
      await generateThumbnail(videoPath, thumbnailPath);
      await compressVideo(videoPath);
    }

    res.status(201).send('Videos uploaded and compressed successfully');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});


router.post('/api/publish', async (req, res) => {

  try {
    const { singleStoryData, label, category, genre, userID } = req.body;
  
    console.log(userID);

    
    // Create a new single story with the received data
    const newStory = new SingleStoryModel(singleStoryData);

    // Find or create the label
    let labelDoc = await LabelModel.findOne({ name: label });
    if (!labelDoc) {
      labelDoc = new LabelModel({ name: label });
    }else{

    }

    // Find or create the category within the label
    let categoryDoc = await CategoryModel.findOne({name : category});

    if (!categoryDoc) {
      categoryDoc = new CategoryModel({ name:  category });
      labelDoc.categories.push(categoryDoc);
    }else{
        labelDoc.categories.push(categoryDoc);
    }

    // Find or create the genre within the category
    let genreDoc = await GenreModel.findOne({name : genre});
    if (!genreDoc) {
      genreDoc = new GenreModel({ name: genre });
      categoryDoc.genres.push(genreDoc);
    }else{
        categoryDoc.genres.push(genreDoc);
    }


    // Save the single story and associate it with the genre
    genreDoc.stories.push(newStory);


    await genreDoc.save();
    await categoryDoc.save();
    await labelDoc.save();
    await newStory.save();
  
    let userProfile = await ProfileModel.findOne({_id : userID});

     if (userProfile) {
        userProfile.labels.push(labelDoc);
        await userProfile.save();
      }
  
   
    if (userProfile) {
      userProfile.stories.push(newStory._id);
      await userProfile.save();
    }


    res.status(201).send('Story published successfully');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});




// Function to calculate the distance between two sets of latitude and longitude coordinates
function calculateDistance(lat1, lon1, lat2, lon2) {
  const earthRadius = 6371; // Radius of the Earth in kilometers

  // Convert latitude and longitude from degrees to radians
  const radLat1 = (Math.PI * lat1) / 180;
  const radLon1 = (Math.PI * lon1) / 180;
  const radLat2 = (Math.PI * lat2) / 180;
  const radLon2 = (Math.PI * lon2) / 180;

  // Haversine formula
  const dLat = radLat2 - radLat1;
  const dLon = radLon2 - radLon1;

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(radLat1) * Math.cos(radLat2) * Math.sin(dLon / 2) ** 2;

  const c = 2 * Math.asin(Math.sqrt(a));

  // Calculate the distance
  const distance = earthRadius * c;
  return distance;
}

// Function to calculate the average star rating
function calculateAverageRating(starRatings) {
  if (starRatings.length === 0) {
    return 0; // Return 0 if there are no ratings
  }

  const sum = starRatings.reduce((total, rating) => total + rating, 0);
  return sum / starRatings.length;
}


router.get('/api/trending-nearby-places', async (req, res) => {
  try {
    const userLatitude = parseFloat(req.query.latitude);
    const userLongitude = parseFloat(req.query.longitude);

    console.log('user aya hai');
    console.log(`lat : ${userLatitude} longi : ${userLongitude}`);

    const maxDistanceDegrees = 20 / 111;

    const nearbyPlaces = await SingleStoryModel.find({
      latitude: { $gte: userLatitude - maxDistanceDegrees, $lte: userLatitude + maxDistanceDegrees },
      longitude: { $gte: userLongitude - maxDistanceDegrees, $lte: userLongitude + maxDistanceDegrees },
    });

    // Sort the places by individual star ratings in descending order
    nearbyPlaces.sort((a, b) => b.starRating - a.starRating);
    console.log(nearbyPlaces);
    res.json(nearbyPlaces);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});






module.exports = router;



