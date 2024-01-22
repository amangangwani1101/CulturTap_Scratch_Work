const express = require('express');
const router = express.Router();

router.use(express.json());

const dummySuggestions = [
  'Tokyo', 'Delhi', 'Shanghai', 'Sao Paulo', 'Mumbai',
  'Beijing', 'Cairo', 'Dhaka', 'Osaka', 'Chongqing',
  'Istanbul', 'Lahore', 'Kinshasa', 'Seoul', 'Jakarta',
  'Guangzhou', 'Lima', 'Lagos', 'Bangkok', 'Bogota',
  'Kinshasa', 'Lahore', 'Tianjin', 'Chennai', 'Bangalore',
  'New York City', 'Karachi', 'Shenzhen', 'Ho Chi Minh City',
  'Santiago', 'Kolkata', 'Nairobi', 'Hong Kong', 'Guadalajara',
  'Wuhan', 'Tehran', 'Rio de Janeiro', 'Chittagong', 'Baghdad',
  'Jinan', 'Shijiazhuang', 'Calcutta', 'Alexandria', 'New Taipei City',
  'Busan', 'Nanjing', 'Hangzhou', 'Ahmedabad', 'Bangalore',
  'Bangkok', 'Bogota', 'Brisbane', 'Cairo', 'Cape Town',
  'Chicago', 'Dallas', 'Delhi', 'Dhaka', 'Dubai', 'Frankfurt',
  'Hong Kong', 'Istanbul', 'Jakarta', 'Johannesburg', 'Kiev',
  'Kolkata', 'Lima', 'London', 'Los Angeles', 'Madrid',
  'Manila', 'Melbourne', 'Mexico City', 'Miami', 'Milan',
  'Moscow', 'Mumbai', 'Munich', 'Nairobi', 'New York City',
  'Osaka', 'Paris', 'Perth', 'Rio de Janeiro', 'Riyadh',
  'San Francisco', 'Sao Paulo', 'Seoul', 'Shanghai',
  'Singapore', 'Sydney', 'Tokyo', 'Toronto', 'Vancouver',
  'Vienna', 'Warsaw', 'Washington, D.C.', 'Wuhan', 'Zurich',
  'Barcelona', 'Berlin', 'Copenhagen', 'Dublin', 'Edinburgh',
  'Geneva', 'Helsinki', 'Kyoto', 'Lisbon', 'Madrid',
  'Munich', 'Naples', 'Oslo', 'Prague', 'Stockholm',
  'Venice', 'Vienna',
  'India', 'China', 'Brazil', 'Egypt', 'Bangladesh',
  'United States', 'Pakistan', 'Vietnam', 'Chile', 'Nigeria',
  'Indonesia', 'Australia', 'South Africa', 'Ukraine',
  'United Kingdom', 'Philippines', 'Canada', 'Germany',
  'Japan', 'Italy', 'France', 'Spain',
  'Agra', 'Ahmedabad', 'Ajmer', 'Alappuzha', 'Allahabad',
  'Amritsar', 'Aurangabad', 'Bhopal', 'Bhubaneswar',
  'Chandigarh', 'Chennai', 'Coimbatore', 'Cuttack', 'Dehradun',
  'Faridabad', 'Gandhinagar', 'Ghaziabad', 'Goa',
  'Gurgaon', 'Guwahati', 'Hyderabad', 'Indore', 'Jaipur',
  'Jalandhar', 'Jammu', 'Jamshedpur', 'Jodhpur', 'Kanpur',
  'Kochi', 'Kolkata', 'Kozhikode', 'Lucknow', 'Ludhiana',
  'Madurai', 'Mangalore', 'Meerut', 'Mysuru',
  'Nagpur', 'Nashik', 'Navi Mumbai', 'Noida', 'Patna',
  'Pune', 'Raipur', 'Rajkot', 'Ranchi', 'Srinagar',
  'Surat', 'Thane', 'Thiruvananthapuram', 'Vadodara', 'Varanasi',
  'Vijayawada', 'Visakhapatnam', 'Warangal'
];

router.get('/suggestions', (req, res) => {
  try {
    console.log('finding suggestions');
    const query = req.query.query.toLowerCase();
    
    // Filter suggestions based on whether they start with the query
    const filteredSuggestions = dummySuggestions.filter(suggestion =>
      suggestion.toLowerCase().startsWith(query)
    );

    // If no suggestions found, try filtering based on the second letter
    if (filteredSuggestions.length === 0 && query.length > 1) {
      const secondLetter = query[1];
      const secondLetterSuggestions = dummySuggestions.filter(suggestion =>
        suggestion.toLowerCase().startsWith(secondLetter)
      );
      console.log(secondLetterSuggestions);
      res.json({ suggestions: secondLetterSuggestions });
    } else {
      console.log(filteredSuggestions);
      res.json({ suggestions: filteredSuggestions });
    }
  } catch (error) {
    console.error('Error processing suggestions:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
