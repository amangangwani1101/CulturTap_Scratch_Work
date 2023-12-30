const express = require('express');
const router = express.Router();
const axios= require('axios');
const Razorpay = require('razorpay');
var instance = new Razorpay({ key_id: 'rzp_test_CYEWfqfiMe4qhr', key_secret: 'QMU316OsyMAE1IOFSXfmWBWW' });

//const createBankAccount = async () => {
//  try {
//    const response = await instance.bankAccount.create({
//      bank_account: {
//        name: 'John Doe',
//        account_number: '12345678908',
//        ifsc: 'SBIN0001781',
//        bank_name: 'Example Bank',
//        branch: 'Example Branch',
//        address: 'Example Address',
//        city: 'Example City',
//        state: 'Example State',
//        country: 'IN'
//      }
//    });
//
//    const bankAccount = response.data;
//    return bankAccount;
//  } catch (error) {
//    console.error('Error creating bank account:', error);
//    throw error;
//  }
//};
//
//// Example usage
//createBankAccount()
//  .then((bankAccount) => {
//    console.log('Bank Account:', bankAccount);
//  })
//  .catch((error) => {
//    console.error('Error:', error);
//  });

const createPaymentLink = async (amount) => {
  try {
   var options = {
       amount: 2000,
       currency: "INR",
       account:"acc_NHyU9rpR3B62fY"
//       capture:1
//       accept_partial: false,
//       description: "For XYZ purpose",
//       customer: {
//         name: "Gaurav Kumar",
//         email: "gaurav.kumar@example.com",
//         contact: "+919000090000"
//       },
//       notify: {
//         sms: true,
//         email: true
//       },
//       reminder_enable: true,
//       options: {
//         order: [
//           {
//             account: "acc_NHyU9rpR3B62fY",
//             amount: 500,
//             currency: "INR",
//           }
//         ]
//       }
     };

//    var options ={
//                   "email": "gauriagain.kumar@example.org",
//                   "phone": "9000090000",
//                   "legal_business_name": "Acme Corp",
//                   "business_type": "partnership",
//                   "customer_facing_business_name": "Example",
//                   "profile": {
//                     "category": "healthcare",
//                     "subcategory": "clinic",
//                     "description": "Healthcare E-commerce platform",
//                     "addresses": {
//                       "operation": {
//                         "street1": "507, Koramangala 6th block",
//                         "street2": "Kormanagala",
//                         "city": "Bengaluru",
//                         "state": "Karnataka",
//                         "postal_code": 560047,
//                         "country": "IN"
//                       },
//                       "registered": {
//                         "street1": "507, Koramangala 1st block",
//                         "street2": "MG Road",
//                         "city": "Bengaluru",
//                         "state": "Karnataka",
//                         "postal_code": 560034,
//                         "country": "IN"
//                       }
//                     },
//                     "business_model": "Online Clothing ( men, women, ethnic, modern ) fashion and lifestyle, accessories, t-shirt, shirt, track pant, shoes."
//                   },
//                   "legal_info": {
//                     "pan": "AAACL1234C",
//                     "gst": "18AABCU9603R1ZM"
//                   },
//                   "brand": {
//                     "color": "FFFFFF"
//                   },
//                   "notes": {
//                     "internal_ref_id": "123123"
//                   },
//                   "contact_name": "Gaurav Kumar",
//                   "contact_info": {
//                     "chargeback": {
//                       "email": "cb@example.org"
//                     },
//                     "refund": {
//                       "email": "cb@example.org"
//                     },
//                     "support": {
//                       "email": "support@example.org",
//                       "phone": "9999999998",
//                       "policy_url": "https://www.google.com"
//                     }
//                   },
//                   "apps": {
//                     "websites": [
//                       "https://www.example.org"
//                     ],
//                     "android": [
//                       {
//                         "url": "playstore.example.org",
//                         "name": "Example"
//                       }
//                     ],
//                     "ios": [
//                       {
//                         "url": "appstore.example.org",
//                         "name": "Example"
//                       }
//                     ]
//                   }
//                 };
    const response = await instance.payments.transfer('pay_NI63fwcmQx6bFv',{
    "transfers":[{
    amount: 2000,
   currency: "INR",
    account:"acc_NHyU9rpR3B62fY"
    }]});

//    const response = await instance.paymentLink.create(options);
//      const response = await instance.accounts.create(options);
//    const response = await instance.customers.create(options);
    return response;
  } catch (error) {
    console.error('Error creating payment link:', error);
    throw error;
  }
};

const createToken = async (customerId, cardDetails) => {
  try {
    const response = await axios.post(`https://api.razorpay.com/v1/customers/${customerId}/tokens`, {
      method: 'card',
      card: cardDetails,
    }, {
      auth: {
        username: 'rzp_test_CYEWfqfiMe4qhr',
        password: 'QMU316OsyMAE1IOFSXfmWBWW',
      },
    });

    const token = response.data;
    return token;
  } catch (error) {
    console.error('Error creating token:', error.response.data);
    throw error;
  }
};

// Example usage
const customerId = 'cust_NHwITIZ9T74qwP';
const cardDetails = {
  number: '4111111111111111',
  name: 'John Doe',
  expiry_month: '12',
  expiry_year: '2023',
};


const initiatePayout = async (amount, accountNumber, ifsc, beneficiaryName) => {
  try {
    const response = await axios.post('https://api.razorpay.com/v1/payouts', {
      account_number: accountNumber,
      ifsc,
      amount,
      currency: 'INR',
      purpose: 'payout',
      mode: 'IMPS',
      method: 'bank_transfer',
      recipient: {
        name: beneficiaryName,
        account_type: 'bank_account',
      },
    }, {
      auth: {
       username: 'rzp_test_QjYe0NMTmgIj40',
       password: 'jz3yIZoouIpNRt6v5gbvuF63',
      },
    });

    const payout = response.data;
    return payout;
  } catch (error) {
    console.error('Error initiating payout:', error.response.data);
    throw error;
  }
};

// Example usage
const amount = 1000; // Amount in paise (e.g., 1000 paise = ₹10)
const accountNumber = '39355213698';
const ifsc = 'SBN0001781';
const beneficiaryName = 'John Doe';


//const initiateTransfer = async (amount, accountNumber, ifsc, beneficiaryName) => {
//  try {
//    const response = await axios.post('https://api.razorpay.com/v1/transfers', {
//      account: accountNumber,
//      amount,
//      currency: 'INR',
//      notes: {
//        beneficiary_name: beneficiaryName,
//      },
//      linked_account_notes: {
//        ifsc_code: ifsc,
//      },
//    }, {
//      auth: {
//         username: 'rzp_test_QjYe0NMTmgIj40',
//         password: 'jz3yIZoouIpNRt6v5gbvuF63',
//      },
//    });
//
//    const transfer = response.data;
//    return transfer;
//  } catch (error) {
//    console.error('Error initiating transfer:', error);
//    throw error;
//  }
//};


//const token = await createToken(customerId, cardDetails);
//console.log('Token:', token);




// Function to create a merchant account
const createMerchantAccount = async (merchantName, email, bankAccountNumber, ifscCode) => {
  try {
    const response = await axios.post('https://api.razorpay.com/v1/beta/accounts', {
      name: merchantName,
      email,
      tnc_accepted:true,
      account_details:{
        business_name:"aman",
        business_type:"individual"
      },
      bank_account: {
        account_number: bankAccountNumber,
        ifsc_code: ifscCode,
        beneficiary_name:"aman",
        account_type:"current"
      },
    }, {
      auth: {
       username: 'rzp_test_CYEWfqfiMe4qhr',
       password: 'QMU316OsyMAE1IOFSXfmWBWW',
      },
    });

    const merchantAccount = response.data;
    return merchantAccount;
  } catch (error) {
    console.error('Error creating merchant account:', error.response.data);
    throw error;
  }
};

// Function to initiate a transfer
const initiateTransfer = async (amount, merchantAccountId) => {
  try {
    const response = await axios.post('https://api.razorpay.com/v1/transfers', {
      account: merchantAccountId,
      amount,
      currency: 'INR',
    }, {
      auth: {
        username: 'rzp_test_CYEWfqfiMe4qhr',
        password: 'QMU316OsyMAE1IOFSXfmWBWW',
      },
    });

    const transfer = response.data;
    return transfer;
  } catch (error) {
    console.error('Error initiating transfer:', error.response.data);
    throw error;
  }
};

// Example usage
const merchantName = 'John Doe';
const email = 'john.doe@example.com';
const bankAccountNumber = '39123453212';
const ifscCode = 'SBIN0001781';
const transferAmount = 1000; // Amount in paise (e.g., 1000 paise = ₹10)

// Create merchant account




// API endpoint to create a payment link
router.post('/create-payment-link', async (req, res) => {
  const { amount } = req.body;

  try {
    const paymentLink = await createPaymentLink(amount);
    res.json({ paymentLink });
//    const token = await createToken(customerId, cardDetails);
//    res.json({token});
//    const payout = await initiatePayout(amount, accountNumber, ifsc, beneficiaryName);
//    res.json({payout});

//        const transfer = await initiateTransfer(amount, accountNumber, ifsc, beneficiaryName);
//        res.json({transfer});
//    const merchantAccount = await createMerchantAccount(merchantName, email, bankAccountNumber, ifscCode);
//    console.log('Merchant Account:', merchantAccount);
//
//    // Initiate transfer
//    const transfer = await initiateTransfer(transferAmount, "acc_NHyU9rpR3B62fY");
//    console.log('Transfer:', transfer);

  } catch (error) {
    console.error('Error creating payment link:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
module.exports = router;